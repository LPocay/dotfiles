import importlib.util
import json
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch


spec = importlib.util.spec_from_file_location("network", Path(__file__).parents[1] / ".config/quickshell/services/network.py")
network = importlib.util.module_from_spec(spec)
spec.loader.exec_module(network)


def interface(name, address="192.168.1.86", family="inet", state="UP"):
    return {"ifname": name, "flags": ["UP"], "operstate": state,
            "addr_info": [{"family": family, "scope": "global", "local": address}]}


class NetworkTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)
        (self.root / "wlan0" / "wireless").mkdir(parents=True)
        self.interfaces = [interface("wlan0")]
        self.routes = [{"dev": "wlan0", "metric": 600}]
        self.routes6 = []
        self.station = "\x1b[0m            Connected network     Casa: Wi-Fi | 5G    \n"
        self.nm_name = ""
        mock = patch.object(network, "run", side_effect=self.run_command)
        self.addCleanup(mock.stop)
        mock.start()

    def run_command(self, command):
        if command == ["ip", "-j", "address", "show"]:
            return json.dumps(self.interfaces)
        if command == ["ip", "-j", "route", "show", "default"]:
            return json.dumps(self.routes)
        if command == ["ip", "-j", "-6", "route", "show", "default"]:
            return json.dumps(self.routes6)
        if command[0] == "iwctl":
            return self.station
        if command[0] == "nmcli":
            return self.nm_name
        raise AssertionError(command)

    def test_iwd_wifi_without_networkmanager_preserves_ssid(self):
        self.assertEqual(network.scan(self.root), {"name": "Casa: Wi-Fi | 5G", "ip": "192.168.1.86"})

    def test_wired_route_with_lower_metric_wins(self):
        self.interfaces.append(interface("enp2s0", "192.168.1.20"))
        self.routes.append({"dev": "enp2s0", "metric": 100})
        self.assertEqual(network.scan(self.root), {"name": "enp2s0", "ip": "192.168.1.20"})

    def test_networkmanager_connection_name_still_works(self):
        self.station = ""
        self.nm_name = "Office Wi-Fi\n"
        self.assertEqual(network.scan(self.root)["name"], "Office Wi-Fi")

    def test_missing_name_utilities_fall_back_to_interface(self):
        self.station = ""
        self.assertEqual(network.scan(self.root)["name"], "wlan0")

    def test_ipv6_only_connection(self):
        self.interfaces = [interface("wlan0", "2001:db8::1", "inet6")]
        self.routes = []
        self.routes6 = [{"dev": "wlan0", "metric": 600}]
        self.assertEqual(network.scan(self.root)["ip"], "2001:db8::1")

    def test_local_network_without_default_route(self):
        self.routes = []
        self.assertEqual(network.scan(self.root)["ip"], "192.168.1.86")

    def test_disconnected_link_does_not_show_stale_address(self):
        self.interfaces = [interface("wlan0", state="DOWN"), interface("lo", "127.0.0.1")]
        self.assertEqual(network.scan(self.root), {"name": "", "ip": ""})

    def test_empty_or_invalid_ip_output_reports_offline(self):
        with patch.object(network, "run", return_value="not json"):
            self.assertEqual(network.scan(self.root), {"name": "", "ip": ""})


class CommandTests(unittest.TestCase):
    def test_missing_and_timed_out_commands_are_optional(self):
        for error in (FileNotFoundError(), subprocess.TimeoutExpired("iwctl", 2)):
            with self.subTest(error=error), patch.object(network.subprocess, "run", side_effect=error):
                self.assertEqual(network.run(["iwctl"]), "")

    def test_failed_command_does_not_leak_output(self):
        with patch.object(network.subprocess, "run", return_value=subprocess.CompletedProcess([], 1, "error")):
            self.assertEqual(network.run(["nmcli"]), "")


if __name__ == "__main__":
    unittest.main()

import importlib.util
from pathlib import Path
import tempfile
import unittest


spec = importlib.util.spec_from_file_location("gpu", Path(__file__).parents[1] / ".config/quickshell/services/gpu.py")
gpu = importlib.util.module_from_spec(spec)
spec.loader.exec_module(gpu)


class GpuTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)

    def card(self, name, *, vendor="0x1002", busy="0", used="1024", total="4096", connected=False, boot=False):
        device = self.root / name / "device"
        device.mkdir(parents=True)
        for field, value in {"vendor": vendor, "gpu_busy_percent": busy, "mem_info_vram_used": used,
                             "mem_info_vram_total": total, "boot_vga": "1" if boot else "0",
                             "uevent": "DRIVER=amdgpu\nPCI_SLOT_NAME=0000:03:00.0\n"}.items():
            if value is not None:
                (device / field).write_text(value)
        connector = self.root / (name + "-DP-1")
        connector.mkdir()
        (connector / "status").write_text("connected" if connected else "disconnected")
        return device

    def test_selects_display_gpu_instead_of_integrated_card_zero(self):
        self.card("card0", total="536870912", boot=True)
        self.card("card1", total="12884901888", connected=True)
        data = gpu.scan(self.root)
        self.assertEqual(data["card"], "card1")
        self.assertEqual(data["pci"], "0000:03:00.0")
        self.assertEqual(data["busy"], 0)

    def test_falls_back_to_boot_gpu_then_larger_vram(self):
        self.card("card1", total="8192")
        device = self.card("card2", total="4096", boot=True)
        self.assertEqual(gpu.scan(self.root)["card"], "card2")
        (device / "boot_vga").write_text("0")
        self.assertEqual(gpu.scan(self.root)["card"], "card1")

    def test_ignores_other_vendors_and_connector_names(self):
        self.card("card0", vendor="0x10de", connected=True)
        self.card("card1-DP-3", connected=True)
        self.assertFalse(gpu.scan(self.root)["available"])

    def test_unavailable_or_corrupt_values_do_not_become_zero_percent_readings(self):
        self.card("card1", busy="invalid", used="-1", total="0")
        self.assertFalse(gpu.scan(self.root)["available"])
        self.assertFalse(gpu.scan(self.root / "missing")["available"])

    def test_partial_metrics_remain_usable_without_division_by_zero(self):
        self.card("card1", busy=None, used="8192", total="4096")
        data = gpu.scan(self.root)
        self.assertTrue(data["available"])
        self.assertIsNone(data["busy"])
        self.assertEqual(data["vramUsed"], 4096)
        self.assertEqual(data["vramTotal"], 4096)

    def test_tool_opens_the_same_gpu_in_a_uwsm_managed_terminal(self):
        self.assertEqual(gpu.monitor_command({"pci": "0000:03:00.0"}, "/usr/bin/amdgpu_top"),
                         ["uwsm", "app", "--", "ghostty", "-e", "/usr/bin/amdgpu_top",
                          "--dark", "--single", "--pci", "0000:03:00.0"])


if __name__ == "__main__":
    unittest.main()

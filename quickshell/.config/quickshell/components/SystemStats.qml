pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick
import "TelemetryLogic.js" as Logic

Singleton {
    id: root

    property int cpu: 0
    property int ram: 0
    property int temp: -1
    property int gpu: -1
    property real vramUsed: 0
    property real vramTotal: 0
    property string gpuPci: ""
    readonly property string vramLabel: Logic.gib(vramUsed) + "G"
    readonly property string vramTooltip: "VRAM: " + Logic.gib(vramUsed) + " / " + Logic.gib(vramTotal)
        + " GiB (" + (vramTotal ? Math.round(vramUsed / vramTotal * 100) : 0) + "%)\nAMD GPU · " + gpuPci
    readonly property string gpuBackend: Quickshell.shellPath("services/gpu.py")
    property string netName: ""
    property string netIp: ""
    property int volume: 0
    property bool volumeMuted: false
    property bool micMuted: false
    property bool hasBattery: false
    property int batteryPercent: 0
    property bool batteryCharging: false

    property real _prevTotal: 0
    property real _prevIdle: 0

    function _run(proc) {
        if (!proc.running)
            proc.running = true;
    }

    function openGpuMonitor() {
        Quickshell.execDetached(["python3", gpuBackend, "open"]);
    }

    component Poll: Process {
        id: p
        property var handler
        stdout: StdioCollector {
            onStreamFinished: p.handler(text.trim())
        }
    }

    Poll {
        id: cpuProc
        command: ["head", "-n1", "/proc/stat"]
        handler: out => {
            const f = out.split(/\s+/).slice(1).map(Number);
            const idle = f[3] + (f[4] || 0);
            const total = f.slice(0, 8).reduce((a, b) => a + b, 0);
            if (root._prevTotal > 0 && total > root._prevTotal)
                root.cpu = Math.round(100 * (1 - (idle - root._prevIdle) / (total - root._prevTotal)));
            root._prevTotal = total;
            root._prevIdle = idle;
        }
    }

    Poll {
        id: ramProc
        command: ["awk", "/MemTotal/{t=$2} /MemAvailable/{a=$2} END{printf \"%d\", (t-a)*100/t}", "/proc/meminfo"]
        handler: out => root.ram = parseInt(out) || 0
    }

    Poll {
        id: gpuProc
        command: ["python3", root.gpuBackend, "scan"]
        handler: out => {
            const data = Logic.gpuSnapshot(out);
            root.gpu = data.busy;
            root.vramUsed = data.vramUsed;
            root.vramTotal = data.vramTotal;
            root.gpuPci = data.pci;
        }
    }

    Poll {
        id: tempProc
        command: ["sh", "-c", "for d in /sys/class/hwmon/hwmon*; do case $(cat $d/name) in k10temp|coretemp|zenpower) cat $d/temp1_input; break;; esac; done"]
        handler: out => root.temp = out ? Math.round(parseInt(out) / 1000) : -1
    }

    Poll {
        id: netProc
        command: ["sh", "-c", "l=$(LC_ALL=C nmcli -t -f TYPE,STATE,DEVICE,CONNECTION device | awk -F: '($1==\"ethernet\"||$1==\"wifi\")&&$2==\"connected\"{print;exit}'); [ -z \"$l\" ] && exit 0; dev=$(echo \"$l\" | cut -d: -f3); name=$(echo \"$l\" | cut -d: -f4-); ip=$(LC_ALL=C nmcli -g IP4.ADDRESS device show \"$dev\" | head -n1 | cut -d/ -f1); echo \"$name|$ip\""]
        handler: out => {
            const i = out.indexOf("|");
            root.netName = i < 0 ? "" : out.slice(0, i);
            root.netIp = i < 0 ? "" : out.slice(i + 1);
        }
    }

    Poll {
        id: audioProc
        command: ["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@; wpctl get-volume @DEFAULT_AUDIO_SOURCE@"]
        handler: out => {
            const lines = out.split("\n");
            const sink = lines[0] || "";
            const src = lines[1] || "";
            const m = sink.match(/([\d.]+)/);
            root.volume = m ? Math.round(parseFloat(m[1]) * 100) : 0;
            root.volumeMuted = sink.includes("[MUTED]");
            root.micMuted = src.includes("[MUTED]");
        }
    }

    Poll {
        id: batProc
        command: ["sh", "-c", "for b in /sys/class/power_supply/BAT*; do [ -e \"$b/capacity\" ] && echo \"$(cat $b/capacity)|$(cat $b/status)\" && break; done"]
        handler: out => {
            root.hasBattery = out !== "";
            if (!root.hasBattery)
                return;
            const p = out.split("|");
            root.batteryPercent = parseInt(p[0]) || 0;
            root.batteryCharging = p[1] === "Charging" || p[1] === "Full";
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            root._run(cpuProc);
            root._run(ramProc);
            root._run(gpuProc);
            root._run(audioProc);
        }
    }
    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            root._run(netProc);
            root._run(tempProc);
        }
    }
    Timer {
        interval: 30000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root._run(batProc)
    }
}

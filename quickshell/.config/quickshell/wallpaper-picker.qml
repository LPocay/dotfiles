import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick

ShellRoot {
  id: root

  readonly property string fontFamily: "JetBrainsMono Nerd Font"
  readonly property color bgColor: "#181616"
  readonly property color listBg: "#0d0c0c"
  readonly property color fgColor: "#c5c9c5"
  readonly property color mutedColor: "#625e5a"
  readonly property color selectedBg: "#282727"
  readonly property color accentColor: "#8992a7"
  readonly property color borderColor: "#625e5a"

  property string tsvPath: Quickshell.env("WALLPAPER_TSV") || ""
  property string selectionFile: Quickshell.env("WALLPAPER_SELECTION_FILE") || ""
  property var images: []
  property int selectedIndex: 0
  property bool ready: false

  readonly property int modalW: 820
  readonly property int modalH: 500
  readonly property int listW: 270

  function fileUrl(path) {
    return "file://" + path.split("/").map(encodeURIComponent).join("/")
  }

  function shellQuote(v) {
    return "'" + String(v).replace(/'/g, "'\\''") + "'"
  }

  function labelFor(img) {
    if (!img) return ""
    return img.path.split("/").pop().replace(/\.[^.]+$/, "")
      .replace(/[-_]/g, " ")
      .replace(/\b\w/g, function(m) { return m.toUpperCase() })
  }

  function select(idx) {
    if (idx < 0) idx = 0
    else if (idx >= images.length) idx = images.length - 1
    selectedIndex = idx
    listView.positionViewAtIndex(idx, ListView.Contain)
  }

  function apply() {
    var img = images[selectedIndex]
    if (!img || !selectionFile) return
    var cmd = "printf '%s' " + shellQuote(img.path) + " > " + shellQuote(selectionFile)
    applyProc.command = ["bash", "-c", cmd]
    applyProc.running = true
  }

  function cancel() {
    Qt.quit()
  }

  Process {
    id: loader
    command: ["cat", tsvPath]
    running: tsvPath !== ""
    stdout: StdioCollector {
      onStreamFinished: {
        var lines = loader.stdout.text.split("\n")
        var list = []
        for (var i = 0; i < lines.length; i++) {
          var cols = lines[i].split("\t")
          if (cols.length >= 2 && cols[0].length > 0) {
            list.push({ path: cols[0], thumb: cols[1] })
          }
        }
        images = list
        ready = true
      }
    }
  }

  Process {
    id: applyProc
    onExited: Qt.quit()
  }

  PanelWindow {
    visible: ready
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    WlrLayershell.namespace: "wallpaper-picker"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusionMode: ExclusionMode.Ignore

    Timer {
      interval: 50
      running: ready
      onTriggered: modal.focus = true
    }

    Rectangle {
      anchors.fill: parent
      color: Qt.rgba(0.035, 0.024, 0.094, 0.72)

      MouseArea {
        anchors.fill: parent
        onClicked: cancel()
      }
    }

    Rectangle {
      id: modal
      anchors.centerIn: parent
      width: modalW
      height: modalH
      color: bgColor
      border { color: borderColor; width: 1 }
      focus: true

      Keys.priority: Keys.BeforeItem
      Keys.onPressed: function(ev) {
        if (ev.key === Qt.Key_Escape) { cancel(); ev.accepted = true }
        else if (ev.key === Qt.Key_Return || ev.key === Qt.Key_Enter) { apply(); ev.accepted = true }
        else if (ev.key === Qt.Key_Up || ev.key === Qt.Key_k) { select(selectedIndex - 1); ev.accepted = true }
        else if (ev.key === Qt.Key_Down || ev.key === Qt.Key_j) { select(selectedIndex + 1); ev.accepted = true }
      }

      MouseArea { anchors.fill: parent; onClicked: {} }

      Row {
        anchors.fill: parent

        Rectangle {
          width: listW
          height: parent.height
          color: listBg

          Rectangle {
            anchors.left: parent.left
            width: 1
            height: parent.height
            color: borderColor
          }

          Rectangle {
            anchors.top: parent.top
            width: parent.width
            height: 1
            color: borderColor
          }

          Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: 1
            color: borderColor
          }

          ListView {
            id: listView
            anchors {
              fill: parent
              leftMargin: 1
              rightMargin: 1
              topMargin: 12
              bottomMargin: 1
            }
            model: images.length
            boundsBehavior: Flickable.StopAtBounds
            clip: true
            leftMargin: 4

            delegate: Item {
              width: listView.width
              height: 52

              Rectangle {
                anchors.fill: parent
                color: selectedIndex === index ? selectedBg : "transparent"

                Rectangle {
                  x: 0
                  width: 3
                  height: parent.height
                  color: selectedIndex === index ? accentColor : "transparent"
                }
              }

              Text {
                anchors { left: parent.left; leftMargin: 16; verticalCenter: parent.verticalCenter; right: parent.right; rightMargin: 12 }
                text: labelFor(images[index])
                color: selectedIndex === index ? accentColor : fgColor
                font { family: fontFamily; pixelSize: 16 }
                elide: Text.ElideRight
              }

              MouseArea {
                anchors.fill: parent
                onClicked: select(index)
              }
            }
          }
        }

        Item {
          width: parent.width - listW
          height: parent.height

          Column {
            anchors.centerIn: parent
            spacing: 16
            width: parent.width - 60

            Rectangle {
              anchors.horizontalCenter: parent.horizontalCenter
              width: Math.min(parent.width, 640)
              height: width * 9 / 16
              color: listBg
              clip: true

              Image {
                anchors.fill: parent
                source: images.length > 0 ? fileUrl(images[selectedIndex].thumb) : ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                cache: true
                smooth: true
              }
            }

            Text {
              anchors.horizontalCenter: parent.horizontalCenter
              width: parent.width
              text: selectedIndex < images.length ? labelFor(images[selectedIndex]) : ""
              color: fgColor
              font { family: fontFamily; pixelSize: 20; weight: Font.DemiBold }
              horizontalAlignment: Text.AlignHCenter
              elide: Text.ElideRight
            }
          }
        }
      }
    }
  }
}

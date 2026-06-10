import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick

ShellRoot {
  id: root

  readonly property string fontFamily: "JetBrainsMono Nerd Font"
  readonly property color bgColor: "#181616"
  readonly property color fgColor: "#c5c9c5"
  readonly property color mutedColor: "#625e5a"
  readonly property color accentColor: "#8992a7"
  readonly property color borderColor: "#625e5a"
  readonly property color listBg: "#0d0c0c"

  property string songTitle: ""
  property string songArtist: ""
  property string artUrl: ""
  property bool isPlaying: false
  property bool ready: false

  Timer {
    id: closeTimer
    interval: 5000
    running: true
    onTriggered: closePopup()
  }

  function resetTimer() {
    closeTimer.restart()
  }

  function closePopup() {
    closeTimer.stop()
    slideOut.start()
  }

  function refresh() {
    metaProc.running = true
    statusProc.running = true
  }

  function control(action) {
    resetTimer()
    ctlProc.command = ["playerctl", "--player=spotify", action]
    ctlProc.running = true
  }

  Process {
    id: metaProc
    command: ["playerctl", "--player=spotify", "metadata", "--format", "{{ title }}\t{{ artist }}\t{{ mpris:artUrl }}"]
    running: false
    stdout: StdioCollector {
      onStreamFinished: {
        var text = this.text.trim()
        var parts = text.split("\t")
        songTitle = parts.length > 0 ? parts[0] : ""
        songArtist = parts.length > 1 ? parts[1] : ""
        if (parts.length > 2 && parts[2]) {
          artUrl = parts[2]
        }
        ready = true
      }
    }
  }

  Process {
    id: statusProc
    command: ["playerctl", "--player=spotify", "status"]
    running: false
    stdout: StdioCollector {
      onStreamFinished: {
        isPlaying = this.text.trim() === "Playing"
      }
    }
  }

  Process {
    id: ctlProc
    command: []
    running: false
    onExited: {
      refreshSoonTimer.restart()
      refreshLaterTimer.restart()
    }
  }

  Timer {
    id: refreshSoonTimer
    interval: 150
    running: false
    repeat: false
    onTriggered: refresh()
  }

  Timer {
    id: refreshLaterTimer
    interval: 450
    running: false
    repeat: false
    onTriggered: refresh()
  }

  PanelWindow {
    id: panel
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    WlrLayershell.namespace: "spotify-controls"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusionMode: ExclusionMode.Ignore

    MouseArea {
      anchors.fill: parent
      onClicked: closePopup()
    }

    Rectangle {
      id: card
      width: 500
      height: 130
      x: (panel.width - width) / 2
      y: 0
      visible: false
      opacity: 0

      color: bgColor
      border { color: borderColor; width: 1 }
      radius: 12

      focus: true
      Keys.priority: Keys.BeforeItem
      Keys.onPressed: function(ev) {
        if (ev.key === Qt.Key_Escape) { closePopup(); ev.accepted = true }
      }

      function show() {
        if (panel.height <= 0) {
          retryTimer.start()
          return
        }

        refresh()
        card.y = panel.height + card.height
        card.visible = true
        card.opacity = 0

        fadeIn.start()
        slideIn.from = panel.height + card.height
        slideIn.to = panel.height - card.height - 40
        slideIn.start()
      }

      Timer {
        id: retryTimer
        interval: 50
        running: false
        repeat: false
        onTriggered: card.show()
      }

      Timer {
        interval: 50
        running: true
        onTriggered: card.show()
      }

      NumberAnimation {
        id: fadeIn
        target: card
        property: "opacity"
        from: 0
        to: 1
        duration: 100
      }

      NumberAnimation {
        id: slideIn
        target: card
        property: "y"
        duration: 300
        easing.type: Easing.OutCubic
      }

      NumberAnimation {
        id: slideOut
        target: card
        property: "y"
        to: panel.height + card.height
        duration: 200
        easing.type: Easing.InCubic
        onFinished: Qt.quit()
      }

      MouseArea {
        anchors.fill: parent
      }

      Row {
        anchors {
          fill: parent
          margins: 16
        }
        spacing: 14

        Rectangle {
          width: 80
          height: 80
          anchors.verticalCenter: parent.verticalCenter
          color: listBg
          radius: 6
          clip: true

          Image {
            anchors.fill: parent
            source: artUrl || ""
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: true
            visible: artUrl !== ""
          }

          Text {
            anchors.centerIn: parent
            text: "\uf1bc"
            font { family: fontFamily; pixelSize: 32 }
            color: accentColor
            visible: artUrl === ""
          }
        }

        Column {
          anchors.verticalCenter: parent.verticalCenter
          width: parent.width - 80 - 14
          spacing: 4

          Text {
            width: parent.width
            text: ready ? (songTitle || "No track playing") : "Loading..."
            color: fgColor
            font { family: fontFamily; pixelSize: 16; weight: Font.DemiBold }
            elide: Text.ElideRight
          }

          Text {
            width: parent.width
            text: ready ? (songArtist || "Unknown artist") : ""
            color: mutedColor
            font { family: fontFamily; pixelSize: 13 }
            elide: Text.ElideRight
          }

          Item { width: 1; height: 8 }

          Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 32

            Text {
              text: "\uf04a"
              color: fgColor
              font { family: fontFamily; pixelSize: 20 }
              MouseArea {
                anchors.fill: parent
                anchors.margins: -8
                cursorShape: Qt.PointingHandCursor
                onClicked: control("previous")
              }
            }

            Text {
              text: isPlaying ? "\uf04c" : "\uf04b"
              color: accentColor
              font { family: fontFamily; pixelSize: 22 }
              MouseArea {
                anchors.fill: parent
                anchors.margins: -8
                cursorShape: Qt.PointingHandCursor
                onClicked: control("play-pause")
              }
            }

            Text {
              text: "\uf04e"
              color: fgColor
              font { family: fontFamily; pixelSize: 20 }
              MouseArea {
                anchors.fill: parent
                anchors.margins: -8
                cursorShape: Qt.PointingHandCursor
                onClicked: control("next")
              }
            }
          }
        }
      }
    }
  }
}

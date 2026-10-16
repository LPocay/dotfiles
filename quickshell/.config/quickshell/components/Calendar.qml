import Quickshell
import QtQuick
import QtQuick.Layouts
import "../theme/"
import "CalendarLogic.js" as CalendarLogic

PopupWindow {
    id: calendarPopup
    implicitWidth: 300
    implicitHeight: content.implicitHeight + 28

    property bool expanded: false
    property int viewYear: clock.date.getFullYear()
    property int viewMonth: clock.date.getMonth()
    property var selectedDate: null

    function shiftMonth(delta) {
        const d = new Date(viewYear, viewMonth + delta, 1);
        viewYear = d.getFullYear();
        viewMonth = d.getMonth();
    }

    visible: expanded
    color: "transparent"

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Rectangle {
        anchors.fill: parent
        border.color: Colors.topbar.power_menu_terminal_prompt
        color: Colors.topbar.panel_background
        radius: 2
        Item {
            anchors.fill: parent
            anchors.margins: 14
            ColumnLayout {
                id: content
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 8
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 26
                    Text {
                        Layout.fillWidth: true
                        font.bold: true
                        font.pixelSize: 13
                        font.letterSpacing: 1
                        color: Colors.topbar.accent_lime
                        text: `cal ${calendarPopup.viewYear}-${String(calendarPopup.viewMonth + 1).padStart(2, "0")}`
                        font.family: "JetBrainsMono Nerd Font"
                    }
                    Repeater {
                        model: [
                            {
                                glyph: "‹",
                                delta: -1
                            },
                            {
                                glyph: "›",
                                delta: 1
                            }
                        ]
                        Text {
                            required property var modelData
                            text: modelData.glyph
                            color: Colors.topbar.accent_green
                            font.pixelSize: 18
                            font.family: "JetBrainsMono Nerd Font"
                            leftPadding: 6
                            rightPadding: 6
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: calendarPopup.shiftMonth(parent.modelData.delta)
                            }
                        }
                    }
                }
                RowLayout {
                    spacing: 2
                    Layout.fillWidth: true
                    Repeater {
                        model: ["SU", "MO", "TU", "WE", "TH", "FR", "SA"]

                        Text {
                            required property string modelData

                            text: modelData
                            color: Colors.topbar.text_dim
                            font.pixelSize: 10
                            font.family: "JetBrainsMono Nerd Font"

                            Layout.fillWidth: true
                            Layout.preferredWidth: 0
                            Layout.preferredHeight: 18
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
                GridLayout {
                    Layout.fillWidth: true
                    columns: 7
                    columnSpacing: 2
                    rowSpacing: 3
                    Repeater {
                        model: 42

                        Rectangle {
                            id: cell
                            required property int index
                            readonly property date cellDate: CalendarLogic.dateForCell(calendarPopup.viewYear, calendarPopup.viewMonth, index)
                            readonly property bool inMonth: cellDate.getMonth() === calendarPopup.viewMonth
                            readonly property bool isToday: inMonth && CalendarLogic.sameDay(cellDate, clock.date)
                            readonly property bool isSelected: CalendarLogic.sameDay(cellDate, calendarPopup.selectedDate)

                            Layout.fillWidth: true
                            Layout.preferredWidth: 0
                            Layout.preferredHeight: 28
                            radius: 2
                            color: isSelected ? Colors.topbar.day_31 : "transparent"

                            Text {
                                anchors.centerIn: parent
                                text: cell.cellDate.getDate()
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 12
                                font.bold: cell.isToday
                                color: cell.isToday ? Colors.topbar.accent_lime : cell.inMonth ? Colors.topbar.text_primary : Colors.topbar.date_30_1_0
                            }
                            MouseArea {
                                anchors.fill: parent
                                enabled: cell.inMonth
                                cursorShape: Qt.PointingHandCursor
                                onClicked: calendarPopup.selectedDate = cell.cellDate
                            }
                        }
                    }
                }
            }
        }
    }
}

import QtQuick

QtObject {
    readonly property color panel_background: "#151914"
    readonly property color panel_border: "#49634F"
    readonly property color divider: "#334237"
    readonly property color accent: "#87A987"
    readonly property color accent_selected: "#A3BE8C"
    readonly property color text_primary: "#CED6CB"
    readonly property color text_secondary: "#858D84"
    readonly property color text_dim: "#70746E"
    readonly property color icon: "#8C9A8D"
    readonly property color search_background: "#0E140F"
    readonly property color search_border: "#5B765D"
    readonly property color search_text: "#C5C9C5"
    readonly property color selection_background: "#26352A"
    readonly property color selection_border: "#57765B"
    // .pen stores RRGGBBAA; QML expects AARRGGBB.
    readonly property color scrim: "#88000000"
    readonly property color error: "#C4746E"
}

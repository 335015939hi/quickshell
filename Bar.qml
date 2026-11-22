import Quickshell
import Quickshell.Wayland
import QtQuick

PanelWindow {
    id: root
    WlrLayershell.namespace: "qs-bar"

    property color background: "#ffffff"

    property bool roundCornerBottomRight: false
    property bool roundCornerBottomLeft: false
    property bool roundCornerTopRight: false
    property bool roundCornerTopLeft: false

    color: "transparent"

    Rectangle {
        anchors.fill: parent
        bottomLeftRadius: root.roundCornerBottomLeft ? root.implicitHeight / 2 : 0
        bottomRightRadius: root.roundCornerBottomRight ? root.implicitHeight / 2 : 0
        topLeftRadius: root.roundCornerTopLeft ? root.implicitHeight / 2 : 0
        topRightRadius: root.roundCornerTopRight ? root.implicitHeight / 2 : 0
        color: root.background
    }
}

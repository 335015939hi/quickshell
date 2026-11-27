import QtQuick
import Quickshell

HoverArea {
    id: root

    property string icon: "system-shutdown"
    property string text: ""
    property color textColor: Matugen.on_surface
    property string command: ""

    property int iconSize: 24
    property int textPixelSize: iconSize / 2
    property int buttonMargins: 16
    property int cornerRadius: 8

    implicitWidth: iconSize + iconText.implicitWidth + buttonMargins
    implicitHeight: Math.max(iconText.implicitHeight, iconSize) + buttonMargins

    Row {
        anchors.centerIn: parent
        Image {
            anchors.verticalCenter: parent.verticalCenter

            width: root.iconSize
            height: root.iconSize

            source: Quickshell.iconPath(root.icon)
            sourceSize: Qt.size(root.iconSize, root.iconSize)
            fillMode: Image.PreserveAspectFit
        }

        Text {
            id: iconText
            anchors.verticalCenter: parent.verticalCenter
            text: root.text
            font.pixelSize: root.textPixelSize
            color: root.textColor
        }
    }

    onClicked: {
        if (root.command !== "")
            Quickshell.execDetached(["/bin/sh", "-c", root.command]);
    }
}

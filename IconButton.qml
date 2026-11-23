import QtQuick
import Quickshell

Item {
    id: root

    property string icon: "system-shutdown"
    property string command: ""

    property int buttonSize: 40
    property int iconSize: 24
    property int cornerRadius: 8

    property color hoverColor: "#404040"

    signal clicked

    implicitWidth: buttonSize
    implicitHeight: buttonSize

    Rectangle {
        anchors.fill: parent
        radius: root.cornerRadius
        color: root.hoverColor
        opacity: mouseArea.containsMouse ? 1 : 0

        Behavior on opacity {
            NumberAnimation { duration: 130; easing.type: Easing.OutCubic }
        }
    }

    Image {
        anchors.centerIn: parent
        width: root.iconSize
        height: root.iconSize
        source: Quickshell.iconPath(root.icon)
        sourceSize: Qt.size(root.iconSize, root.iconSize)
        fillMode: Image.PreserveAspectFit
        scale: mouseArea.pressed ? 0.88 : mouseArea.containsMouse ? 1.08 : 1

        Behavior on scale {
            NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent

        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            if (root.command !== "")
                Quickshell.execDetached(["/bin/sh", "-c", root.command]);

            root.clicked();
        }
    }
}

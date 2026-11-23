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
        color: mouseArea.containsMouse ? root.hoverColor : "transparent"

        Behavior on color {
            ColorAnimation {
                duration: 120
            }
        }
    }

    Image {
        anchors.centerIn: parent

        width: root.iconSize
        height: root.iconSize

        source: Quickshell.iconPath(root.icon)
        sourceSize: Qt.size(root.iconSize, root.iconSize)
        fillMode: Image.PreserveAspectFit
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

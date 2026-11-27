import Quickshell
import QtQuick
import Quickshell.Networking
import QtQuick.Layouts
import qs

Item {
    anchors.fill: parent
    Row {
        Image {
            width: 24
            height: 24
            source: Quickshell.iconPath(Globals.networkIcon)
            sourceSize: Qt.size(width, height)
            fillMode: Image.PreserveAspectFit
        }
        Text {
            text: Globals.networkName
            color: Matugen.on_surface
            anchors.fill: parent
        }
    }
}

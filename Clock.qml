import Quickshell
import QtQuick
import qs

HoverArea {
    id: root
    property string format: "hh:mm:ss"
    property string tooltipFormat: "dddd, MMMM d, yyyy\nhh:mm:ss"
    property int textSize: 16
    property color color
    implicitWidth: text.implicitWidth
    implicitHeight: text.implicitHeight
    Text {
        id: text
        font {
            pixelSize: root.textSize
        }
        color: root.color
        text: Qt.formatDateTime(Globals.currentTime, root.format)
    }
    tooltip: Qt.formatDateTime(Globals.currentTime, root.tooltipFormat)
}

import Quickshell
import QtQuick
import qs

Text {
    property string format: "hh:mm:ss"
    property date currentTime: new Date()
    property int textSize: 16
    font {
        pixelSize: textSize
    }
    text: Qt.formatDateTime(Globals.currentTime, format)
}

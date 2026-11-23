import Quickshell
import Quickshell.Wayland
import QtQuick

Text {
    property string format: "hh:mm:ss"
    property date currentTime: new Date()
    property int textSize: 16
    font {
        pixelSize: textSize
        family: "Cormorant Garamond"
    }
    text: Qt.formatDateTime(currentTime, format)

    Timer {
        interval: 1000
        repeat: true
        running: true
        triggeredOnStart: true

        onTriggered: currentTime = new Date()
    }
}

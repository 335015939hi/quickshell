import Quickshell
import Quickshell.Wayland
import QtQuick

Text {
    property string format: "hh:mm:ss"
    property date currentTime: new Date()
    font {
        pixelSize: 16
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

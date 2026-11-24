pragma Singleton

import Quickshell
import QtQuick

Singleton {
    property string networkIcon: ""

    property date currentTime: new Date()
    Timer {
        interval: 1000
        repeat: true
        running: true
        triggeredOnStart: true

        onTriggered: currentTime = new Date()
    }

    property int animationTime: 250
}

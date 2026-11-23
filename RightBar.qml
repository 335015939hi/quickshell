import QtQuick
import Quickshell

Slide {
    Matugen {
        id: color
    }
    background: color.primary_a
    edge: "right"
    slideWidth: 80

    Clock {
        color: color.on_primary
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 10
    }
    IconButton {}
}

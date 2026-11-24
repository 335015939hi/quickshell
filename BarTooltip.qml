// BarTooltip.qml
// Delayed-appearance tooltip for bar widgets. Drops a small bubble below
// (or above, via FlipY) an anchor item after the user hovers for `delay`
// ms; vanishes immediately when the user moves away. The consumer drives
// the `show` property (typically `mouseArea.containsMouse`) and supplies
// `anchorItem` plus the `text`.
//
// Pattern stolen from `tray/Tray.qml:169-218` and generalized.
//
// Usage:
//
//   MouseArea {
//       id: ma
//       hoverEnabled: true
//       BarTooltip {
//           anchorItem: ma
//           text: "Volume 75%"
//           show: ma.containsMouse && !popup.visible   // hide when popup opens
//       }
//   }

import QtQuick
import Quickshell
import qs

PopupWindow {
    id: tip
    Matugen {
        id: color
    }

    property Item anchorItem
    property string text: ""
    property bool show: false
    property int delay: 350

    // Internal: only flip true after the delay timer fires.
    property bool _shown: false

    color: "transparent"
    visible: _shown && text !== ""

    anchor.item: anchorItem
    anchor.rect.x: anchorItem ? (anchorItem.width - tip.width) / 2 : 0
    anchor.rect.y: anchorItem ? anchorItem.height + 6 : 0

    implicitWidth: Math.max(40, tipText.implicitWidth + 16)
    implicitHeight: tipText.implicitHeight + 8

    Timer {
        id: showTimer
        interval: tip.delay
        onTriggered: tip._shown = true
    }

    onShowChanged: {
        if (show && text !== "") {
            showTimer.restart();
        } else {
            showTimer.stop();
            tip._shown = false;
        }
    }

    // If the text becomes empty mid-display, drop the tooltip to avoid an
    // empty bubble flashing.
    onTextChanged: {
        if (text === "" && _shown)
            _shown = false;
    }

    Rectangle {
        anchors.fill: parent
        color: color.surface_a
        radius: tip.implicitHeight / 2

        Text {
            id: tipText
            anchors.centerIn: parent
            text: tip.text
            color: color.on_surface
            elide: Text.ElideRight
        }
    }
}

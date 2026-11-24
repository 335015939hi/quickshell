import QtQuick
import Quickshell
import qs

Item {
    id: root

    // The wrapper should not take up layout space.
    width: 0
    height: 0

    // Properties
    property Item anchorItem: parent
    property string text: ""
    property bool show: parent ? parent.containsMouse : false
    property int delay: 350

    // Internal state
    property bool _shown: false

    // Tooltip window
    PopupWindow {
        id: tip

        color: "transparent"
        visible: root._shown && root.text !== ""
        grabFocus: false

        // Position relative to the anchor item.
        anchor.item: root.anchorItem

        anchor.rect.x: root.anchorItem ? (root.anchorItem.width - tip.implicitWidth) / 2 : 0

        anchor.rect.y: root.anchorItem ? root.anchorItem.height + 6 : 0

        implicitWidth: Math.max(40, tipText.implicitWidth + 16)
        implicitHeight: tipText.implicitHeight + 8

        Rectangle {
            anchors.fill: parent
            color: Matugen.surface_a
            radius: tip.implicitHeight / 2

            Text {
                id: tipText

                anchors.centerIn: parent
                text: root.text
                color: Matugen.on_surface
                elide: Text.ElideRight
            }
        }
        mask: Region {
            width: tip.width
            height: tip.height
            intersection: Intersection.Xor
        }
    }

    // Delayed appearance
    Timer {
        id: showTimer
        interval: root.delay

        onTriggered: {
            root._shown = true;
        }
    }

    // Show/hide handling
    onShowChanged: {
        if (root.show && root.text !== "") {
            showTimer.restart();
        } else {
            showTimer.stop();
            root._shown = false;
        }
    }

    // Hide immediately if text becomes empty.
    onTextChanged: {
        if (root.text === "" && root._shown) {
            root._shown = false;
        }
    }
}

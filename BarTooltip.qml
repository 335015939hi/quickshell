import QtQuick
import Quickshell
import Quickshell.Wayland
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
    property int delay: Globals.animationTime * 2
    property int tooltipOffset: 8

    // Internal state
    property bool _shown: false

    // Tooltip window
    PopupWindow {
        id: tip
        readonly property var screen: QsWindow.screen

        color: "transparent"
        //grabFocus: false
        visible: tipRect.opacity != 0

        // Position relative to the anchor item.
        anchor.item: root.anchorItem

        anchor.rect.x: root.anchorItem ? (root.anchorItem.width - tip.implicitWidth) / 2 : 0
        anchor.rect.y: {
            if (!root.anchorItem) {
                return 0;
            }
            var y = root.anchorItem.mapToGlobal(0, 0).y + (root.anchorItem.height / 2);
            // QsWindow.window may be null on init. check for null to prevent warnings
            var screen = root.anchorItem.QsWindow.window;
            if (screen == null) {
                return 0;
            }
            screen = screen.screen;
            if (y > screen.y + screen.height / 2) {
                return -tip.implicitHeight - root.tooltipOffset;
            } else {
                return anchorItem.height + root.tooltipOffset;
            }
        }

        implicitWidth: Math.max(40, tipText.implicitWidth + 16)
        implicitHeight: tipText.implicitHeight + 8

        Rectangle {
            id: tipRect
            anchors.fill: parent
            color: Matugen.surface_a
            radius: tipText.font.pixelSize
            opacity: (root._shown && root.text !== "") ? 1 : 0
            Behavior on opacity {
                NumberAnimation {
                    duration: Globals.animationTime
                    easing.type: Easing.OutCubic
                }
            }

            Text {
                id: tipText
                anchors.centerIn: parent
                text: root.text
                color: Matugen.on_surface
                elide: Text.ElideRight
            }
        }

        mask: Region {
            width: 0
            height: 0
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

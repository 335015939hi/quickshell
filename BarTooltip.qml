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
    property int _windowRevision: 0
    Connections {
        target: root.anchorItem ? root.anchorItem.QsWindow.window : null
        function onWindowConnected() {
            root._windowRevision++;
        }
    }

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
            // Re-evaluate after the parent window connects.
            root._windowRevision;

            const anchor = root.anchorItem;
            if (!anchor)
                return 0;

            const window = anchor.QsWindow.window;
            if (!window)
                return 0;

            const screen = window.screen;
            if (!screen)
                return 0;

            const y = anchor.mapToGlobal(0, 0).y + anchor.height / 2;

            return y > screen.y + screen.height / 2 ? -tip.implicitHeight - root.tooltipOffset : anchor.height + root.tooltipOffset;
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
            root._windowRevision++;
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

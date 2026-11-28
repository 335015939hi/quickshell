import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root

    default property alias content: contentRoot.data

    // Position
    property string edge: "top" // top, bottom, left, right

    // Dimensions
    property int slideHeight: 48
    property int slideWidth: 48
    property int peekHeight: 1
    property int peekWidth: 1

    // Timing
    property int showDelay: Globals.animationTime
    property int hideDelay: Globals.animationTime
    property bool expanded: false
    property bool suspendAutoHide: false
    property bool fullyHidden: true

    property color background: "#ffffff"

    property bool roundCornerBottomRight: false
    property bool roundCornerBottomLeft: false
    property bool roundCornerTopRight: false
    property bool roundCornerTopLeft: false

    property var onShow: function () {}
    property var onHide: function () {}

    readonly property bool vertical: edge === "left" || edge === "right"
    readonly property int thickness: vertical ? slideWidth : slideHeight

    property bool focused: false
    property bool preparing: showTimer.running
    // Appearance
    WlrLayershell.namespace: "qs-bar"

    color: "transparent"

    // Layer-shell anchoring
    anchors {
        top: root.edge === "top" || root.vertical
        bottom: root.edge === "bottom" || root.vertical
        left: root.edge === "left" || !root.vertical
        right: root.edge === "right" || !root.vertical
    }

    implicitWidth: slideWidth
    implicitHeight: slideHeight

    exclusionMode: ExclusionMode.Ignore

    // Slide away from the selected edge
    margins.top: edge === "top" ? (expanded ? 0 : peekHeight - height) : 0

    margins.bottom: edge === "bottom" ? (expanded ? 0 : peekHeight - height) : 0

    margins.left: edge === "left" ? (expanded ? 0 : peekWidth - width) : 0

    margins.right: edge === "right" ? (expanded ? 0 : peekWidth - width) : 0

    Behavior on margins.right {
        SequentialAnimation {
            NumberAnimation {
                duration: Globals.animationTime
                easing.type: Easing.OutCubic
            }
            ScriptAction {
                script: {
                    if (!root.expanded) {
                        root.fullyHidden = true;
                        root.onHide();
                    }
                }
            }
        }
    }

    Behavior on margins.left {
        SequentialAnimation {
            NumberAnimation {
                duration: Globals.animationTime
                easing.type: Easing.OutCubic
            }
            ScriptAction {
                script: {
                    if (!root.expanded) {
                        root.fullyHidden = true;
                        root.onHide();
                    }
                }
            }
        }
    }

    Behavior on margins.bottom {
        SequentialAnimation {
            NumberAnimation {
                duration: Globals.animationTime
                easing.type: Easing.OutCubic
            }
            ScriptAction {
                script: {
                    if (!root.expanded) {
                        root.fullyHidden = true;
                        root.onHide();
                    }
                }
            }
        }
    }

    Behavior on margins.top {
        SequentialAnimation {
            NumberAnimation {
                duration: Globals.animationTime
                easing.type: Easing.OutCubic
            }
            ScriptAction {
                script: {
                    if (!root.expanded) {
                        root.fullyHidden = true;
                        root.onHide();
                    }
                }
            }
        }
    }

    // Content
    Item {
        id: contentRoot
        anchors.fill: parent

        Rectangle {
            anchors.fill: parent

            bottomLeftRadius: root.roundCornerBottomLeft ? root.thickness / 2 : 0
            bottomRightRadius: root.roundCornerBottomRight ? root.thickness / 2 : 0
            topLeftRadius: root.roundCornerTopLeft ? root.thickness / 2 : 0
            topRightRadius: root.roundCornerTopRight ? root.thickness / 2 : 0

            color: root.background
        }
    }

    // Hover detection
    HoverHandler {
        onHoveredChanged: {
            if (hovered) {
                root.focused = true;
                hideTimer.stop();

                if (!root.expanded)
                    showTimer.start();
            } else {
                root.focused = false;
                showTimer.stop();
                if (!root.suspendAutoHide) {
                    if (root.expanded)
                        hideTimer.restart();
                }
            }
        }
    }

    onSuspendAutoHideChanged: {
        if (suspendAutoHide) {
            hideTimer.stop();
        } else if (root.expanded && !root.focused) {
            hideTimer.restart();
        }
    }

    Timer {
        id: showTimer
        interval: root.showDelay
        onTriggered: {
            root.fullyHidden = false;
            root.expanded = true;
            root.onShow();
        }
    }

    Timer {
        id: hideTimer
        interval: root.hideDelay
        onTriggered: {
            if (!root.suspendAutoHide && !root.focused)
                root.expanded = false;
        }
    }
}

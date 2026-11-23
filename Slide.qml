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
    property int showDelay: 200
    property int hideDelay: 100
    property bool expanded: false

    property color background: "#ffffff"

    property bool roundCornerBottomRight: false
    property bool roundCornerBottomLeft: false
    property bool roundCornerTopRight: false
    property bool roundCornerTopLeft: false

    property var onShow: function () {}
    property var onHide: function () {}

    readonly property bool vertical: edge === "left" || edge === "right"
    readonly property int thickness: vertical ? slideWidth : slideHeight
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

    Behavior on margins.top {
        NumberAnimation {
            duration: 250
            easing.type: Easing.OutCubic
        }
    }

    Behavior on margins.bottom {
        NumberAnimation {
            duration: 250
            easing.type: Easing.OutCubic
        }
    }

    Behavior on margins.left {
        NumberAnimation {
            duration: 250
            easing.type: Easing.OutCubic
        }
    }

    Behavior on margins.right {
        NumberAnimation {
            duration: 250
            easing.type: Easing.OutCubic
        }
    }

    // Content
    Item {
        id: contentRoot
        anchors.fill: parent

        opacity: root.expanded ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: 120
            }
        }

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
                hideTimer.stop();

                if (!root.expanded)
                    showTimer.start();
            } else {
                showTimer.stop();

                if (root.expanded)
                    hideTimer.restart();
            }
        }
    }

    Timer {
        id: showTimer
        interval: root.showDelay
        onTriggered: {
            root.expanded = true;
            root.onShow();
        }
    }

    Timer {
        id: hideTimer
        interval: root.hideDelay
        onTriggered: {
            root.expanded = false;
            root.onHide();
        }
    }
}

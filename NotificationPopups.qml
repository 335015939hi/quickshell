import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root

    required property var notificationModel
    property color background: "#303030"
    property color foreground: "#ffffff"

    // One list of notification content Items inside this one PanelWindow.
    // Entries stay here until their exit animation has finished.
    property var popupItems: []

    WlrLayershell.namespace: "qs-notifications"

    anchors {
        top: true
        right: true
    }

    margins {
        top: 14
        right: 14
    }

    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    visible: root.popupItems.length > 0

    implicitWidth: 360
    implicitHeight: popupColumn.implicitHeight

    // Keep layer-shell resizing instantaneous. Animating this property would
    // reconfigure the Wayland surface on every frame.

    // This is the only notification background. All notification content
    // is rendered inside it, so the stack reads as one continuous surface.
    Rectangle {
        anchors.fill: popupColumn
        radius: 16
        color: root.background
        border.width: 1
        border.color: Qt.lighter(root.background, 1.2)
    }

    function findPopup(notification) {
        for (const entry of root.popupItems) {
            if (entry.notification === notification)
                return entry.popup
        }

        return null
    }

    function addNotification(notification) {
        if (root.findPopup(notification))
            return

        const popup = popupComponent.createObject(popupColumn, {
            notification: notification
        })

        if (!popup) {
            console.warn("Failed to create notification content")
            return
        }

        popup.removalFinished.connect(() => root.removePopup(popup))
        root.popupItems = [...root.popupItems, {
            notification: notification,
            popup: popup
        }]
    }

    function closeNotification(notification) {
        const popup = root.findPopup(notification)

        if (popup)
            popup.closing = true
    }

    function removePopup(popup) {
        root.popupItems = root.popupItems.filter(entry => entry.popup !== popup)
        popup.destroy()
    }

    Component {
        id: popupComponent

        NotificationPopup {
            width: root.implicitWidth
            foreground: root.foreground
        }
    }

    Column {
        id: popupColumn

        width: root.implicitWidth
        height: implicitHeight
        spacing: 0

        // Track changing layout positions without restarting the animation
        // from a new easing curve whenever the stack changes again.
        move: Transition {
            SmoothedAnimation {
                properties: "y"
                velocity: 600
            }
        }
    }

    Connections {
        target: root.notificationModel

        function onObjectInsertedPost(notification, index) {
            root.addNotification(notification)
        }

        function onObjectRemovedPre(notification, index) {
            root.closeNotification(notification)
        }
    }

    Component.onCompleted: {
        for (const notification of root.notificationModel.values)
            root.addNotification(notification)
    }
}

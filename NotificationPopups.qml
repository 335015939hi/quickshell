import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root

    required property var notificationModel
    property color background: "#303030"
    property color foreground: "#ffffff"

    // The displayed list is intentionally separate from trackedNotifications:
    // entries remain here long enough to finish their exit animation.
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

    // QsWindow sizes itself from its implicit dimensions. Setting width/height
    // directly is deprecated in newer Quickshell versions.
    implicitWidth: 360
    implicitHeight: popupColumn.implicitHeight

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
            console.warn("Failed to create notification popup")
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
            background: root.background
            foreground: root.foreground
        }
    }

    Column {
        id: popupColumn

        width: root.implicitWidth
        spacing: 10
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

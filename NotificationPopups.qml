import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root

    required property var notificationModel
    property color background: "#303030"
    property color foreground: "#ffffff"

    readonly property int notificationCount: root.notificationModel
        ? root.notificationModel.values.length
        : 0

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

    visible: root.notificationCount > 0

    implicitWidth: 360
    implicitHeight: popupColumn.implicitHeight
    width: implicitWidth
    height: implicitHeight

    Column {
        id: popupColumn

        width: root.width
        spacing: 10

        Repeater {
            model: root.notificationModel

            delegate: NotificationPopup {
                required property var modelData

                width: popupColumn.width
                notification: modelData
                background: root.background
                foreground: root.foreground
            }
        }
    }
}

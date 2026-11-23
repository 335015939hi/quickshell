import Quickshell
import Quickshell.Wayland
import QtQuick
import Quickshell.Services.Notifications

ShellRoot {
    Matugen {
        id: color
    }
    NotificationService {
        id: notifications
    }

    Bar {
        anchors.top: true
        anchors.right: true
        roundCornerBottomLeft: true
        exclusionMode: ExclusionMode.Ignore
        implicitHeight: clock.implicitHeight + 3
        implicitWidth: clock.implicitWidth + 6
        background: color.primary_a
        Clock {
            id: clock
            color: color.on_primary
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
    RightBar {}
    NotificationPopups {
        notificationModel: notifications.trackedNotifications
        background: color.primary_a
        foreground: color.on_primary
    }
}

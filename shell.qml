import Quickshell
import Quickshell.Wayland
import QtQuick

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

    Slide {
        background: color.primary_a
        edge: "right"
        slideWidth: 80

        Clock {
            color: color.on_primary
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    NotificationPopups {
        notificationModel: notifications.trackedNotifications
        background: color.primary_a
        foreground: color.on_primary
    }
}

import Quickshell
import Quickshell.Wayland
import QtQuick
import Quickshell.Services.Notifications
import qs.widgets

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
        implicitHeight: topLeftBarRow.implicitHeight + 3
        implicitWidth: topLeftBarRow.implicitWidth + 6
        background: color.surface_a
        Row {
            id: topLeftBarRow
            anchors.horizontalCenter: parent.horizontalCenter
            Clock {
                color: color.on_surface
                format: "hh:mm"
            }
            Battery {
                buttonMargins: 2
                iconSize: 20
                showText: false
            }
        }
    }
    RightBar {}
    NotificationPopups {
        notificationModel: notifications.trackedNotifications
        background: color.primary_a
        foreground: color.on_primary
    }
}

import Quickshell
import Quickshell.Wayland
import QtQuick
import Quickshell.Services.Notifications
import qs.widgets
import qs.applauncher

ShellRoot {
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
        background: Matugen.surface_a
        Row {
            id: topLeftBarRow
            anchors.horizontalCenter: parent.horizontalCenter
            Clock {
                color: Matugen.on_surface
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
    LeftBar {}
    Wallpaper {}
    AppLauncher {}
    NotificationPopups {
        notificationModel: notifications.trackedNotifications
        background: Matugen.primary_a
        foreground: Matugen.on_primary
    }
}

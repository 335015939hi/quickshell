import Quickshell
import Quickshell.Wayland
import QtQuick
import Quickshell.Services.Notifications

ShellRoot {
    Matugen {
        id: color
    }
    NotificationServer {
        id: notificationServer

        actionsSupported: true
        bodyMarkupSupported: true
        imageSupported: true

        onNotification: notification => {
            notification.tracked = true;

            console.log(notification.appName, notification.summary, notification.body);
        }
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
}

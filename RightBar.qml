import QtQuick
import Quickshell

Slide {
    id: root
    Matugen {
        id: color
    }
    background: color.background_a
    edge: "right"
    slideWidth: 300

    onHide: function () {
        sessionConfirm.visible = false;
    }

    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        Clock {
            color: color.on_background
            anchors.margins: 10
        }
    }
    Column {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        Row {
            id: sessionConfirm
            visible: false
            property string command: ""
            Text {
                id: sessionConfirmText
                anchors.verticalCenter: parent.verticalCenter
                color: color.on_background
            }
            IconButton {
                command: sessionConfirm.command
                icon: "dialog-ok"
                onClicked: {
                    sessionConfirm.visible = false;
                }
            }
            IconButton {
                icon: "dialog-cancel"
                onClicked: {}
            }
        }
        Row {
            IconButton {
                icon: "system-shutdown"
                onClicked: {
                    sessionConfirmText.text = "Shutdown?";
                    sessionConfirm.visible = true;
                    sessionConfirm.command = "systemctl poweroff";
                }
            }
            IconButton {
                icon: "system-reboot"
                onClicked: {
                    sessionConfirmText.text = "Reboot?";
                    sessionConfirm.visible = true;
                    sessionConfirm.command = "systemctl reboot";
                }
            }
            IconButton {
                icon: "system-log-out"
                onClicked: {
                    sessionConfirmText.text = "Logout?";
                    sessionConfirm.visible = true;
                    sessionConfirm.command = "hyprshutdown";
                }
            }
            IconButton {
                icon: "system-suspend"
                command: "hyprlock & disown;sleep 0.5;systemctl suspend"
            }
            IconButton {
                icon: "system-lock-screen"
                command: "hyprlock & disown"
            }
        }
    }
}

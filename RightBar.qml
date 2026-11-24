import QtQuick
import Quickshell
import qs.widgets

Slide {
    id: root
    background: Matugen.surface_a
    edge: "right"
    slideWidth: 500
    focusable: true

    onHide: function () {
        sessionConfirm.visible = false;
        viewDefault.visible = true;
        viewNetwork.visible = false;
    }

    Item {
        id: viewDefault
        anchors.fill: parent
        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            Clock {
                color: Matugen.on_surface
                format: "yyyy/mm/dd hh:mm:ss"
                anchors.margins: 10
            }
            Row {
                IconButton {
                    icon: "network-manager"
                    onClicked: {
                        viewDefault.visible = false;
                        viewNetwork.visible = true;
                    }
                }
                Battery {}
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
                    color: Matugen.on_background
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
                    onClicked: {
                        sessionConfirm.visible = false;
                    }
                }
            }
            Row {
                IconButton {
                    icon: "system-shutdown-symbolic"
                    iconSize: 40
                    onClicked: {
                        sessionConfirmText.text = "Shutdown?";
                        sessionConfirm.visible = true;
                        sessionConfirm.command = "systemctl poweroff";
                    }
                }
                IconButton {
                    icon: "system-reboot-symbolic"
                    iconSize: 40
                    onClicked: {
                        sessionConfirmText.text = "Reboot?";
                        sessionConfirm.visible = true;
                        sessionConfirm.command = "systemctl reboot";
                    }
                }
                IconButton {
                    icon: "system-log-out-symbolic"
                    iconSize: 40
                    onClicked: {
                        sessionConfirmText.text = "Logout?";
                        sessionConfirm.visible = true;
                        sessionConfirm.command = "hyprshutdown";
                    }
                }
                IconButton {
                    icon: "system-suspend-symbolic"
                    iconSize: 40
                    command: "hyprlock & disown;sleep 0.5;systemctl suspend"
                }
                IconButton {
                    icon: "system-lock-screen-symbolic"
                    iconSize: 40
                    command: "hyprlock & disown"
                }
            }
        }
    }

    Column {
        id: viewNetwork
        anchors.fill: parent
        visible: false
        IconButton {
            icon: "go-previous"
            onClicked: function () {
                viewNetwork.visible = false;
                viewDefault.visible = true;
            }
        }
        NetworkWidget {
            width: parent.width
            anchors.margins: 15
            cardColor: Matugen.surface_a
            innerColor: Matugen.surface_container_a
            textColor: Matugen.on_surface
            mutedTextColor: Matugen.on_surface_variant
            accentColor: Matugen.primary
        }
    }
}

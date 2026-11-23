import QtQuick
import Quickshell
import qs.widgets

Slide {
    id: root
    Matugen {
        id: color
    }
    background: color.background_a
    edge: "right"
    slideWidth: 500
    focusable: true
    property string activeView: "default"

    onHide: function () {
        sessionConfirm.open = false;
        root.activeView = "default";
    }

    Item {
        id: viewDefault
        anchors.fill: parent
        property bool active: root.activeView === "default"
        visible: active || opacity > 0.001
        enabled: active
        opacity: active ? 1 : 0
        x: active ? 0 : -20
        z: active ? 1 : 0

        Behavior on opacity {
            NumberAnimation { duration: 210; easing.type: Easing.OutCubic }
        }

        Behavior on x {
            NumberAnimation { duration: 230; easing.type: Easing.OutCubic }
        }
        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            Clock {
                color: color.on_background
                anchors.margins: 10
            }
            Row {
                IconButton {
                    icon: "network-manager"
                    onClicked: {
                        root.activeView = "network";
                    }
                }
            }
        }
        Column {
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            Row {
                id: sessionConfirm
                property string command: ""
                property bool open: false
                visible: open || opacity > 0.001
                enabled: open
                opacity: open ? 1 : 0
                scale: open ? 1 : 0.96
                transformOrigin: Item.Center

                Behavior on opacity {
                    NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
                }

                Behavior on scale {
                    NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
                }
                Text {
                    id: sessionConfirmText
                    anchors.verticalCenter: parent.verticalCenter
                    color: color.on_background
                }
                IconButton {
                    command: sessionConfirm.command
                    icon: "dialog-ok"
                    onClicked: {
                        sessionConfirm.open = false;
                    }
                }
                IconButton {
                    icon: "dialog-cancel"
                    onClicked: {
                        sessionConfirm.open = false;
                    }
                }
            }
            Row {
                IconButton {
                    icon: "system-shutdown"
                    onClicked: {
                        sessionConfirmText.text = "Shutdown?";
                        sessionConfirm.open = true;
                        sessionConfirm.command = "systemctl poweroff";
                    }
                }
                IconButton {
                    icon: "system-reboot"
                    onClicked: {
                        sessionConfirmText.text = "Reboot?";
                        sessionConfirm.open = true;
                        sessionConfirm.command = "systemctl reboot";
                    }
                }
                IconButton {
                    icon: "system-log-out"
                    onClicked: {
                        sessionConfirmText.text = "Logout?";
                        sessionConfirm.open = true;
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

    Column {
        id: viewNetwork
        anchors.fill: parent
        property bool active: root.activeView === "network"
        visible: active || opacity > 0.001
        enabled: active
        opacity: active ? 1 : 0
        x: active ? 0 : 24
        z: active ? 1 : 0

        Behavior on opacity {
            NumberAnimation { duration: 210; easing.type: Easing.OutCubic }
        }

        Behavior on x {
            NumberAnimation { duration: 230; easing.type: Easing.OutCubic }
        }
        IconButton {
            icon: "go-previous"
            onClicked: function () {
                root.activeView = "default";
            }
        }
        NetworkWidget {
            width: parent.width
            anchors.margins: 15
            cardColor: color.surface_a
            innerColor: color.surface_container_a
            textColor: color.on_surface
            mutedTextColor: color.on_surface_variant
            accentColor: color.primary
        }
    }
}

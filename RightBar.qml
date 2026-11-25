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
        sessionConfirm.opened = false;
        viewDefault.opened = true;
        viewNetwork.visible = false;
        viewWallpaperPick.opened = false;
    }

    Item {
        id: viewDefault
        property bool opened: true
        opacity: opened ? 1 : 0
        visible: opacity != 0
        Behavior on opacity {
            NumberAnimation {
                duration: Globals.animationTime
                easing.type: Easing.OutCubic
            }
        }
        anchors.fill: parent
        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            Clock {
                color: Matugen.on_surface
                format: "yyyy/mm/dd hh:mm:ss"
            }
            Row {
                Network {
                    onClicked: {
                        viewDefault.opened = false;
                        viewNetwork.visible = true;
                    }
                }
                Battery {}
                IconButton {
                    icon: "viewimage-symbolic"
                    tooltip: "Set wallpaper"
                    onClicked: {
                        viewDefault.opened = false;
                        viewWallpaperPick.opened = true;
                    }
                }
            }
        }
        Column {
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            Row {
                id: sessionConfirm
                visible: opacity != 0
                opacity: opened ? 1 : 0
                property bool opened: false
                property string command: ""
                property string _nextText: ""
                property var setText: function (text) {
                    if (text == sessionConfirmText.text) {
                        return;
                    }
                    if (opened) {
                        _nextText = text;
                        textAnimation.restart();
                    } else {
                        sessionConfirmText.text = text;
                    }
                }
                SequentialAnimation {
                    id: textAnimation

                    NumberAnimation {
                        target: sessionConfirm
                        property: "opacity"
                        to: 0
                        duration: Globals.animationTime
                        easing.type: Easing.OutCubic
                    }

                    ScriptAction {
                        script: sessionConfirmText.text = sessionConfirm._nextText
                    }

                    NumberAnimation {
                        target: sessionConfirm
                        property: "opacity"
                        to: 1
                        duration: Globals.animationTime / 2
                        easing.type: Easing.OutCubic
                    }
                }
                Behavior on opacity {
                    NumberAnimation {
                        duration: Globals.animationTime / 2
                        easing.type: Easing.OutCubic
                    }
                }
                Text {
                    id: sessionConfirmText
                    anchors.verticalCenter: parent.verticalCenter
                    color: Matugen.on_background
                }
                IconButton {
                    command: sessionConfirm.command
                    tooltip: "Confirm"
                    icon: "dialog-ok"
                    onClicked: {
                        sessionConfirm.opened = false;
                    }
                }
                IconButton {
                    icon: "dialog-cancel"
                    tooltip: "Cancel"
                    onClicked: {
                        sessionConfirm.opened = false;
                    }
                }
            }
            Row {
                IconButton {
                    icon: "system-shutdown-symbolic"
                    iconSize: 40
                    tooltip: "Shutdown"
                    onClicked: {
                        sessionConfirm.setText("Shutdown?");
                        sessionConfirm.opened = true;
                        sessionConfirm.command = "systemctl poweroff";
                    }
                }
                IconButton {
                    icon: "system-reboot-symbolic"
                    iconSize: 40
                    tooltip: "Reboot"
                    onClicked: {
                        sessionConfirm.setText("Reboot?");
                        sessionConfirm.opened = true;
                        sessionConfirm.command = "systemctl reboot";
                    }
                }
                IconButton {
                    icon: "system-log-out-symbolic"
                    iconSize: 40
                    tooltip: "Logout"
                    onClicked: {
                        sessionConfirm.setText("Logout?");
                        sessionConfirm.opened = true;
                        sessionConfirm.command = "hyprshutdown";
                    }
                }
                IconButton {
                    icon: "system-suspend-symbolic"
                    iconSize: 40
                    command: "hyprlock & disown;sleep 0.5;systemctl suspend"
                    tooltip: "Sleep"
                }
                IconButton {
                    icon: "system-lock-screen-symbolic"
                    iconSize: 40
                    command: "hyprlock & disown"
                    tooltip: "Lock screen"
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
                viewDefault.opened = true;
            }
        }
        Loader {
            id: networkWidgetLoader
            width: parent.width
            active: viewNetwork.visible

            sourceComponent: Component {
                NetworkWidget {
                    width: networkWidgetLoader.width
                    anchors.margins: 15
                    cardColor: Matugen.surface_a
                    innerColor: Matugen.surface_container_a
                    textColor: Matugen.on_surface
                    mutedTextColor: Matugen.on_surface_variant
                    accentColor: Matugen.primary
                }
            }
        }
    }
    Item {
        id: viewWallpaperPick
        anchors.fill: parent
        property bool opened: false
        opacity: opened ? 1 : 0
        visible: opacity != 0

        Behavior on opacity {
            NumberAnimation {
                duration: Globals.animationTime
                easing.type: Easing.OutCubic
            }
        }

        onOpenedChanged: {
            if (opened)
                Qt.callLater(() => {
                    const picker = wallpaperPickerLoader.item;
                    if (picker)
                        picker.focusGrid();
                });
        }

        IconButton {
            id: wallpaperBack
            anchors.top: parent.top
            anchors.left: parent.left
            icon: "go-previous"
            onClicked: {
                viewWallpaperPick.opened = false;
                viewDefault.opened = true;
            }
        }

        Loader {
            id: wallpaperPickerLoader

            anchors {
                top: wallpaperBack.bottom
                bottom: parent.bottom
                left: parent.left
                right: parent.right
                margins: 8
            }

            active: viewWallpaperPick.visible

            sourceComponent: Component {
                WallpaperPicker {
                    onBackRequested: {
                        viewWallpaperPick.opened = false;
                        viewDefault.opened = true;
                    }

                    onWallpaperSelected: {
                        viewWallpaperPick.opened = false;
                        viewDefault.opened = true;
                    }
                }
            }
        }
    }
}

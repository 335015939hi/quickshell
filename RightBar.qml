import QtQuick
import Quickshell
import QtQuick.Layouts
import QtQuick.Controls
import qs.widgets

Slide {
    id: root
    background: Matugen.surface_a
    edge: "right"
    slideWidth: 500
    focusable: true
    suspendAutoHide: false

    onHide: function () {}

    Loader {
        anchors.fill: parent

        active: !root.fullyHidden || root.expanded || root.preparing

        sourceComponent: Component {
            Item {
                anchors.fill: parent
                RowLayout {
                    anchors.fill: parent
                    //border
                    Rectangle {
                        Layout.fillHeight: true
                        width: 1
                        color: Matugen.primary
                    }
                    //back button
                    ColumnLayout {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        IconButton {
                            icon: "go-previous"
                            onClicked: {
                                if (stack.depth <= 1) {
                                    root.expanded = false;
                                } else {
                                    stack.pop();
                                }
                            }
                        }
                        //view
                        StackView {
                            id: stack
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            initialItem: defaultPage
                            onBusyChanged: {
                                root.suspendAutoHide = stack.busy;
                            }
                        }
                    }
                }

                Component {
                    id: defaultPage
                    ColumnLayout {
                        Clock {
                            Layout.alignment: Qt.AlignHCenter
                            format: "dddd, MMMM d, yyyy\nhh:mm:ss"
                            textSize: 24
                            color: Matugen.on_surface
                            horizontalAlignment: Text.AlignHCenter
                        }
                        Grid {
                            Layout.fillHeight: true
                            Battery {}
                            NetworkControl {
                                pageStack: stack
                            }
                            WallpaperPicker {
                                pageStack: stack
                            }
                        }
                        Item {
                            Layout.fillWidth: true
                            height: sessionButtons.implicitHeight
                            RowLayout {
                                id: sessionButtons
                                anchors.centerIn: parent
                                opacity: opened ? 1 : 0
                                visible: opacity != 0
                                property bool opened: !sessionConfirm.opened
                                IconButton {
                                    icon: "system-shutdown-symbolic"
                                    iconSize: 40
                                    tooltip: "Shutdown"
                                    onClicked: {
                                        sessionConfirmText.text = "Shutdown?";
                                        sessionConfirm.opened = true;
                                        sessionConfirm.command = "systemctl poweroff";
                                    }
                                }
                                IconButton {
                                    icon: "system-reboot-symbolic"
                                    iconSize: 40
                                    tooltip: "Reboot"
                                    onClicked: {
                                        sessionConfirmText.text = "Reboot?";
                                        sessionConfirm.opened = true;
                                        sessionConfirm.command = "systemctl reboot";
                                    }
                                }
                                IconButton {
                                    icon: "system-log-out-symbolic"
                                    iconSize: 40
                                    tooltip: "Logout"
                                    onClicked: {
                                        sessionConfirmText.text = "Logout?";
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
                                Behavior on opacity {
                                    NumberAnimation {
                                        duration: Globals.animationTime
                                        easing.type: Easing.InOutCubic
                                    }
                                }
                            }
                            RowLayout {
                                id: sessionConfirm
                                anchors.centerIn: parent
                                opacity: opened ? 1 : 0
                                visible: opacity != 0
                                property bool opened: false
                                property string command: ""
                                Behavior on opacity {
                                    NumberAnimation {
                                        duration: Globals.animationTime
                                        easing.type: Easing.InOutCubic
                                    }
                                }
                                Text {
                                    id: sessionConfirmText
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
                        }
                    }
                }
            }
        }
    }
}

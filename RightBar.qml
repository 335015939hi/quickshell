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

        active: root.expanded || root.preparing

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
                        }
                    }
                }
            }
        }
    }
}

import QtQuick
import Quickshell
import QtQuick.Controls
import QtQuick.Layouts
import qs.widgets
import qs

Slide {
    id: root
    background: Matugen.surface_a
    edge: "left"
    slideWidth: 500
    focusable: true
    RowLayout {
        anchors.fill: parent
        ColumnLayout {
            Layout.fillWidth: true
            RowLayout {
                Layout.fillWidth: true
                Item {
                    Layout.fillWidth: true
                }
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
            }
            StackView {
                id: stack
                Layout.fillHeight: true
                initialItem: defaultPage
            }
        }
        //border
        Rectangle {
            Layout.fillHeight: true
            width: 1
            color: Matugen.primary
        }
    }

    Component {
        id: defaultPage
        Column {}
    }
}

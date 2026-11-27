import Quickshell
import QtQuick
import QtQuick.Effects
import qs

MouseArea {
    id: root
    property bool disabled: false
    property bool checked: false
    property var onCheck: function () {}
    property color checkedColor: Matugen.primary
    property color uncheckedColor: Matugen.surface_bright
    property color checkedDisabledColor: Matugen.primary_a
    property color uncheckedDisabledColor: Matugen.surface_bright_a
    property color toggleColor: Matugen.on_surface
    property color borderColor: toggleColor
    property color toggleDisabledColor: Matugen.on_surface_a

    property int borderWidth: 2

    implicitHeight: 24
    implicitWidth: implicitHeight * 1.8
    hoverEnabled: true

    Rectangle {
        anchors.centerIn: parent
        width: parent.width
        height: parent.height
        radius: height / 2
        color: root.disabled ? root.uncheckedDisabledColor : root.uncheckedColor
        layer.enabled: true
        anchors.fill: parent

        Rectangle {
            id: checkedColor
            color: disabled ? root.checkedDisabledColor : root.checkedColor
            height: parent.height
            width: checkCircle.x + checkCircle.width
            anchors.left: parent.left
            radius: height / 2
        }

        Rectangle {
            id: border
            color: "transparent"
            anchors.fill: parent
            border.width: root.borderWidth
            border.color: root.disabled ? "transparent" : (root.containsMouse ? root.borderColor : "transparent")
            radius: width / 2
            Behavior on border.color {
                ColorAnimation {
                    duration: Globals.animationTime
                    easing.type: Easing.InOutCubic
                }
            }
        }
        Rectangle {
            id: checkCircle
            height: parent.height
            width: height
            x: checked ? parent.width - width : 0
            color: root.disabled ? root.toggleDisabledColor : root.toggleColor
            radius: height / 2
            Behavior on x {
                NumberAnimation {
                    duration: Globals.animationTime
                    easing.type: Easing.InOutCubic
                }
            }
        }
    }

    function toggle() {
        if (!disabled) {
            root.onCheck();
        }
    }

    onClicked: {
        toggle();
    }
}

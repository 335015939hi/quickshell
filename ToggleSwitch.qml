import Quickshell
import QtQuick
import QtQuick.Effects
import qs

MouseArea {
    id: root
    property bool disabled: true
    property bool checked: false
    property color checkedColor: Matugen.primary_container
    property color uncheckedColor: Matugen.outline_variant
    property color checkedDisabledColor: Matugen.primary_container_a
    property color uncheckedDisabledColor: Matugen.outline_variant_a
    property color borderColor: Matugen.primary
    property color toggleColor: Matugen.primary
    property color toggleDisabledColor: Matugen.primary_a

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

    onClicked: {
        if (!disabled) {
            checked = !checked;
        }
    }
}

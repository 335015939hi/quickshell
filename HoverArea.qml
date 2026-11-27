import QtQuick

MouseArea {
    id: root
    property color hoverColor: Matugen.primary_container_a
    property int cornerRadius: Math.min(implicitWidth, implicitHeight) / 4
    property string tooltip: ""

    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight
    hoverEnabled: true
    Rectangle {
        anchors.fill: parent
        radius: root.cornerRadius
        opacity: root.containsMouse ? 1 : 0
        color: root.hoverColor

        Behavior on opacity {
            NumberAnimation {
                duration: Globals.animationTime
            }
        }
    }
    BarTooltip {
        text: root.tooltip
    }
}

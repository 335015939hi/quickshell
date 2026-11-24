import QtQuick

MouseArea {
    id: root
    property color hoverColor: Matugen.primary_container_a
    property int cornerRadius: implicitWidth / 4

    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight
    hoverEnabled: true
    Rectangle {
        anchors.fill: parent
        radius: root.cornerRadius
        color: root.containsMouse ? root.hoverColor : "transparent"

        Behavior on color {
            ColorAnimation {
                duration: 120
            }
        }
    }
}

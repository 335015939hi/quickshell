import Quickshell
import QtQuick

Row {
    id: root
    property string label: ""
    property string value: ""
    signal edited(string value)

    width: parent ? parent.width : 0
    height: 34
    spacing: 8

    Text {
        id: label
        text: root.label
        color: Matugen.on_surface_variant
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
        anchors.verticalCenter: parent.verticalCenter
    }

    Rectangle {
        width: Math.max(0, root.width - label.implicitWidth - 8)
        height: label.font.pixelSize + 8
        radius: height / 3
        color: "transparent"
        border.width: 1
        border.color: Matugen.primary
        anchors.verticalCenter: parent.verticalCenter
        clip: true

        TextInput {
            anchors.verticalCenter: parent.verticalCenter
            anchors.fill: parent
            anchors.leftMargin: 4
            anchors.rightMargin: 4
            verticalAlignment: TextInput.AlignVCenter
            color: Matugen.on_surface
            selectedTextColor: Matugen.on_primary_container
            selectionColor: Matugen.primary_container
            selectByMouse: true
            text: root.value
            font.pixelSize: label.font.pixelSize
            onTextChanged: root.edited(text)
        }
    }
}

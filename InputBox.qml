import Quickshell
import QtQuick
import qs

Row {
    id: root

    // Existing settings-row API.
    property string label: ""
    property string placeholderText: ""
    property string icon: ""
    property alias echoMode: editor.echoMode

    // Input appearance.
    property color textColor: Matugen.on_surface
    property color placeholderColor: Matugen.on_surface_variant
    property color backgroundColor: "transparent"
    property color borderColor: Matugen.primary
    property color focusedBorderColor: Matugen.primary

    property int horizontalPadding: 8
    property int iconSize: height / 2
    property int cornerRadius: height / 3

    // Keep the old "value" API and expose the editor for focus/cursor control.
    property alias value: editor.text
    property alias text: editor.text
    property alias textInput: editor
    property alias readOnly: editor.readOnly
    property alias selectByMouse: editor.selectByMouse

    property int fontPixelSize: height - 2 * horizontalPadding

    signal edited(string value)
    signal accepted
    signal keyPressed(var event)

    //width: parent ? parent.width : ((labelText.visible ? labelText.implicitWidth + spacing : 0) + 240)
    spacing: 8

    Text {
        id: labelText

        visible: root.label.length > 0
        text: root.label
        color: Matugen.on_surface_variant
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: root.fontPixelSize
    }

    Rectangle {
        id: field

        width: Math.max(0, root.width - (labelText.visible ? labelText.implicitWidth + root.spacing : 0))
        height: root.height
        radius: root.cornerRadius
        color: root.backgroundColor
        border.width: 1
        border.color: editor.activeFocus ? root.focusedBorderColor : root.borderColor

        anchors.verticalCenter: parent.verticalCenter
        clip: true

        Behavior on border.color {
            ColorAnimation {
                duration: Globals.animationTime
            }
        }

        Image {
            visible: root.icon.length > 0

            anchors.left: parent.left
            anchors.leftMargin: root.horizontalPadding
            anchors.verticalCenter: parent.verticalCenter

            width: root.iconSize
            height: root.iconSize

            source: visible ? Quickshell.iconPath(root.icon) : ""
            sourceSize: Qt.size(root.iconSize, root.iconSize)
            fillMode: Image.PreserveAspectFit
            asynchronous: true
        }

        Text {
            anchors.left: parent.left
            anchors.leftMargin: root.horizontalPadding + (root.icon.length > 0 ? root.iconSize + 10 : 0)
            anchors.right: parent.right
            anchors.rightMargin: root.horizontalPadding
            anchors.verticalCenter: parent.verticalCenter

            visible: editor.text.length === 0 && root.placeholderText.length > 0
            text: root.placeholderText
            color: root.placeholderColor
            font.pixelSize: root.fontPixelSize
            elide: Text.ElideRight
        }

        TextInput {
            id: editor

            anchors.fill: parent
            anchors.leftMargin: root.horizontalPadding + (root.icon.length > 0 ? root.iconSize + 10 : 0)
            anchors.rightMargin: root.horizontalPadding

            verticalAlignment: TextInput.AlignVCenter
            color: root.textColor
            selectedTextColor: Matugen.on_primary_container
            selectionColor: Matugen.primary
            selectByMouse: true
            font.pixelSize: root.fontPixelSize

            onTextChanged: root.edited(text)
            onAccepted: root.accepted()

            Keys.onPressed: event => root.keyPressed(event)
        }
    }
}

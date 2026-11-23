import QtQuick
import Quickshell
import Quickshell.Widgets

Item {
    id: root

    required property var notification
    property color background: "#303030"
    property color foreground: "#ffffff"

    readonly property int timeoutMs: {
        const timeout = root.notification.expireTimeout
        if (timeout > 0)
            return Math.round(timeout * 1000)
        if (timeout < 0)
            return 5000
        return 0
    }

    implicitWidth: 360
    width: implicitWidth
    height: implicitHeight
    implicitHeight: content.implicitHeight + 28

    function applicationIcon() {
        const icon = root.notification.appIcon

        if (!icon)
            return Quickshell.iconPath("application-x-executable")

        if (icon.startsWith("/") || icon.startsWith("file:") || icon.includes("://"))
            return icon

        return Quickshell.iconPath(icon, "application-x-executable")
    }

    Rectangle {
        anchors.fill: parent
        radius: 16
        color: root.background
        border.width: 1
        border.color: Qt.lighter(root.background, 1.2)
    }

    Column {
        id: content

        x: 14
        y: 14
        width: root.width - 28
        spacing: 8

        Row {
            width: content.width
            spacing: 8

            IconImage {
                width: 32
                height: 32
                source: root.applicationIcon()
                asynchronous: true
            }

            Column {
                width: content.width - 32 - 26 - 16
                spacing: 2

                Text {
                    width: parent.width
                    text: root.notification.appName || "Notification"
                    color: root.foreground
                    opacity: 0.72
                    font.pixelSize: 11
                    elide: Text.ElideRight
                }

                Text {
                    width: parent.width
                    visible: root.notification.summary.length > 0
                    text: root.notification.summary
                    color: root.foreground
                    font.pixelSize: 14
                    font.bold: true
                    wrapMode: Text.Wrap
                    maximumLineCount: 2
                    elide: Text.ElideRight
                }
            }

            Item {
                width: 26
                height: 26

                Text {
                    anchors.fill: parent
                    text: "×"
                    color: root.foreground
                    opacity: closeMouse.containsMouse ? 1.0 : 0.65
                    font.pixelSize: 21
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                MouseArea {
                    id: closeMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.notification.dismiss()
                }
            }
        }

        Text {
            width: content.width
            visible: root.notification.body.length > 0
            text: root.notification.body
            textFormat: Text.AutoText
            color: root.foreground
            font.pixelSize: 13
            wrapMode: Text.Wrap
            maximumLineCount: 4
            elide: Text.ElideRight
        }

        Item {
            width: content.width
            height: root.notification.image.length > 0 ? 120 : 0
            visible: height > 0
            clip: true

            Image {
                anchors.fill: parent
                source: root.notification.image
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
            }
        }

        Flow {
            width: content.width
            height: childrenRect.height
            spacing: 6
            visible: root.notification.actions.length > 0

            Repeater {
                model: root.notification.actions

                delegate: Rectangle {
                    required property var modelData

                    width: Math.min(actionText.implicitWidth + 22, content.width)
                    height: 30
                    radius: 9
                    color: actionMouse.containsMouse
                        ? Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.20)
                        : Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.10)
                    border.width: 1
                    border.color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.16)

                    Text {
                        id: actionText
                        anchors.centerIn: parent
                        width: parent.width - 16
                        text: modelData.text
                        color: root.foreground
                        font.pixelSize: 12
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                    }

                    MouseArea {
                        id: actionMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: modelData.invoke()
                    }
                }
            }
        }
    }

    HoverHandler {
        id: hover
    }

    Timer {
        interval: root.timeoutMs
        running: root.timeoutMs > 0 && !hover.hovered
        repeat: false
        onTriggered: root.notification.expire()
    }
}

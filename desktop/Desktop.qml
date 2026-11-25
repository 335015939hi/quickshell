import Quickshell
import Quickshell.Wayland
import QtQuick
import Quickshell.Io
import qs

PanelWindow {
    id: root
    property bool opened: false

    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Background
    Item {
        id: desktop
        visible: opacity != 0
        opacity: root.opened ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: Globals.animationTime
                easing.type: Easing.OutCubic
            }
        }

        DesktopLayout {}
        Wallpaper {}
    }

    Process {
        id: command
    }

    IpcHandler {
        id: ipc
        target: "desktop"

        function toggle(): void {
            if (root.opened) {
                ipc.close();
            } else {
                ipc.open();
            }
        }

        function close(): void {
            command.exec(["qs", "ipc", "call", "applauncher", "close"]);
            root.opened = false;
        }

        function open(): void {
            root.opened = true;
        }
    }
}

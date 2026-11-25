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
    anchors.right: true
    anchors.left: true
    WlrLayershell.layer: WlrLayer.Overlay
    focusable: true
    color: Matugen.surface_a

    visible: launcher.opacity != 0
    Item {
        id: launcher
        opacity: root.opened ? 1 : 0
        focus: true
        Behavior on opacity {
            NumberAnimation {
                duration: Globals.animationTime
                easing.type: Easing.OutCubic
            }
        }
        Keys.onPressed: event => {
            switch (event.key) {
            case Qt.Key_Escape:
                event.accepted = true;
                root.opened = false;
                break;
            }
        }
    }
    IpcHandler {
        target: "applauncher"
        function toggle(): void {
            root.opened = !root.opened;
        }
        function close(): void {
            root.opened = false;
        }
        function open(): void {
            root.opened = true;
        }
    }
}

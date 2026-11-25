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
    }

    IpcHandler {
        target: "desktop"

        function toggle(): void {
            root.opened = !root.opened;
        }
    }
}

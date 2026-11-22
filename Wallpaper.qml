import Quickshell
import Quickshell.Wayland
import QtQuick

Variants {
    model: Quickshell.screens

    delegate: Component {
        PanelWindow {
            required property var modelData
            screen: modelData

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            WlrLayershell.layer: WlrLayer.Background

            exclusionMode: ExclusionMode.Ignore
            focusable: false
            color: "black"

            Image {
                anchors.fill: parent

                source: "/home/tony/Pictures/wallpapers/resized/IMG_0700-jenny_lake-1.jpg"

                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                mipmap: true
                cache: true
            }
        }
    }
}

import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import qs

Item {
    id: root

    // Hardcoded for now; change this to the directory containing your images.
    property string wallpaperDirectory: (Quickshell.env("HOME") || "") + "/Pictures/wallpapers"
    property int cardsPerRow: 3
    property int cardHeight: 132
    property int gridSpacing: 8

    readonly property int columnCount: Math.max(1, cardsPerRow)
    property var wallpapers: []
    property string scanError: ""

    signal wallpaperSelected(string path)
    signal backRequested

    function imageUrl(path) {
        return "file://" + path.split("/").map(part => encodeURIComponent(part)).join("/");
    }

    function parseFiles(output) {
        const extensions = ["avif", "bmp", "gif", "jpeg", "jpg", "jxl", "png", "svg", "tif", "tiff", "webp"];
        const files = output.split("\n").map(path => path.replace(/\r$/, "")).filter(path => path.length > 0).filter(path => {
            const name = path.split("/").pop();
            const dot = name.lastIndexOf(".");
            return dot >= 0 && extensions.includes(name.slice(dot + 1).toLowerCase());
        });
        files.sort((a, b) => a.localeCompare(b, undefined, {
                numeric: true,
                sensitivity: "base"
            }));
        wallpapers = files;
        scanError = "";
    }

    function select(index) {
        if (index < 0 || index >= wallpapers.length)
            return;
        const path = wallpapers[index];
        // Wallpaper.qml owns the per-monitor renderer and exposes this IPC API.
        Quickshell.execDetached(["qs", "ipc", "call", "wallpaper", "setAll", path]);
        wallpaperSelected(path);
    }

    function focusGrid() {
        if (wallpapers.length && grid.currentIndex < 0)
            grid.currentIndex = 0;
        grid.forceActiveFocus();
        if (grid.currentIndex >= 0)
            grid.positionViewAtIndex(grid.currentIndex, GridView.Contain);
    }

    Process {
        id: scanner
        command: ["find", "-L", root.wallpaperDirectory, "-maxdepth", "1", "-type", "f"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.parseFiles(text)
        }
        stderr: StdioCollector {
            onStreamFinished: root.scanError = text.trim()
        }
    }

    onWallpapersChanged: {
        if (!wallpapers.length)
            grid.currentIndex = -1;
        else if (grid.currentIndex < 0 || grid.currentIndex >= wallpapers.length)
            grid.currentIndex = 0;
    }

    Column {
        anchors.fill: parent
        spacing: root.gridSpacing

        Row {
            id: header
            width: parent.width
            height: 28
            spacing: 8
            Text {
                text: "Select wallpaper"
                anchors.verticalCenter: parent.verticalCenter
                color: Matugen.on_surface
                font.pixelSize: 17
                font.bold: true
            }
            Text {
                text: root.wallpapers.length + " images"
                anchors.verticalCenter: parent.verticalCenter
                color: Matugen.on_surface_variant
                font.pixelSize: 11
            }
        }

        GridView {
            id: grid
            width: parent.width
            height: parent.height - header.height - parent.spacing
            clip: true
            focus: true
            interactive: true
            boundsBehavior: Flickable.StopAtBounds
            model: root.wallpapers
            cellWidth: width / root.columnCount
            cellHeight: root.cardHeight + root.gridSpacing
            delegate: Item {
                required property string modelData
                required property int index

                width: grid.cellWidth - root.gridSpacing
                height: root.cardHeight

                Image {
                    id: thumbnail
                    anchors.fill: parent
                    source: root.imageUrl(modelData)
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    cache: false
                    smooth: true
                    visible: false
                    sourceSize: Qt.size(Math.ceil(width * 2), Math.ceil(height * 2))
                }

                // Rounded, opaque mask.
                Rectangle {
                    id: thumbnailMask
                    anchors.fill: thumbnail
                    radius: 9
                    color: "white"
                    visible: false
                    layer.enabled: true
                }

                // Render the image through the rounded mask.
                MultiEffect {
                    anchors.fill: thumbnail
                    source: thumbnail
                    maskEnabled: true
                    maskSource: thumbnailMask
                }

                // Selection border, rendered above the image.
                Rectangle {
                    anchors.fill: parent
                    radius: 9
                    color: "transparent"
                    border.width: grid.currentIndex === index ? 2 : 1
                    border.color: grid.currentIndex === index ? Matugen.primary : "transparent"
                    Behavior on border.color {
                        ColorAnimation {
                            duration: Globals.animationTime
                            easing.type: Easing.InOutCubic
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true

                        onEntered: grid.currentIndex = index

                        onClicked: {
                            grid.currentIndex = index;
                            grid.forceActiveFocus();
                            root.select(index);
                        }
                    }
                }
            }

            Keys.onPressed: event => {
                const count = root.wallpapers.length;
                if (event.key === Qt.Key_Escape) {
                    event.accepted = true;
                    root.backRequested();
                    return;
                }
                if (!count)
                    return;

                let next = grid.currentIndex < 0 ? 0 : grid.currentIndex;
                let handled = true;
                switch (event.key) {
                case Qt.Key_Left:
                    next--;
                    break;
                case Qt.Key_Right:
                    next++;
                    break;
                case Qt.Key_Up:
                    next -= root.columnCount;
                    break;
                case Qt.Key_Down:
                    next += root.columnCount;
                    break;
                case Qt.Key_Home:
                    next = 0;
                    break;
                case Qt.Key_End:
                    next = count - 1;
                    break;
                case Qt.Key_PageUp:
                    next -= root.columnCount * Math.max(1, Math.floor(grid.height / grid.cellHeight));
                    break;
                case Qt.Key_PageDown:
                    next += root.columnCount * Math.max(1, Math.floor(grid.height / grid.cellHeight));
                    break;
                case Qt.Key_Return:
                case Qt.Key_Enter:
                case Qt.Key_Space:
                    event.accepted = true;
                    root.select(next);
                    return;
                default:
                    handled = false;
                    break;
                }
                if (!handled)
                    return;
                event.accepted = true;
                next = Math.max(0, Math.min(count - 1, next));
                grid.currentIndex = next;
                grid.positionViewAtIndex(next, GridView.Contain);
            }
        }
    }
}

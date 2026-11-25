import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io
import qs

PanelWindow {
    id: root

    property bool opened: false
    property string launchError: ""

    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true

    WlrLayershell.layer: WlrLayer.Overlay
    focusable: true
    color: "transparent"
    visible: opened || launcher.opacity > 0

    DesktopEntryLauncher {
        id: desktopEntryLauncher
        onLaunchFailed: (applicationName, reason) => {
            root.launchError = applicationName + ": " + reason;
            console.warn("App launcher:", root.launchError);
        }
    }

    ScriptModel {
        id: filteredApplications

        values: {
            const query = searchBox.text.trim().toLowerCase();
            const applications = [...DesktopEntries.applications.values];

            if (!query)
                return applications.sort((a, b) => a.name.localeCompare(b.name));

            const tokens = query.split(/\s+/).filter(token => token.length > 0);

            function haystack(app) {
                return [app.name, app.genericName, app.comment, ...(app.keywords || []), ...(app.categories || [])].join(" ").toLowerCase();
            }

            function score(app) {
                const name = app.name.toLowerCase();
                if (name === query)
                    return 0;
                if (name.startsWith(query))
                    return 1;
                if (name.includes(query))
                    return 2;
                const generic = (app.genericName || "").toLowerCase();
                if (generic.startsWith(query))
                    return 3;
                if (generic.includes(query))
                    return 4;
                return 5;
            }

            return applications.filter(app => tokens.every(token => haystack(app).includes(token))).sort((a, b) => score(a) - score(b) || a.name.localeCompare(b.name));
        }
    }

    readonly property int gridColumns: Math.max(1, Math.floor(appGrid.width / appGrid.cellWidth))

    function openLauncher() {
        if (opened) {
            searchBox.textInput.forceActiveFocus();
            return;
        }
        opened = true;
    }

    function closeLauncher() {
        opened = false;
        searchBox.textInput.focus = false;
    }

    function toggleLauncher() {
        if (opened)
            closeLauncher();
        else
            openLauncher();
    }

    function launchApplication(app) {
        if (desktopEntryLauncher.launch(app))
            closeLauncher();
    }

    function launchSelected() {
        const applications = filteredApplications.values;
        const index = appGrid.currentIndex;
        if (index < 0 || index >= applications.length)
            return;
        launchApplication(applications[index]);
    }

    function moveSelection(delta) {
        const count = filteredApplications.values.length;
        if (!count)
            return;
        const current = appGrid.currentIndex < 0 ? 0 : appGrid.currentIndex;
        const next = Math.max(0, Math.min(count - 1, current + delta));
        appGrid.currentIndex = next;
        appGrid.positionViewAtIndex(next, GridView.Contain);
    }

    onOpenedChanged: {
        if (opened) {
            launchError = "";
            searchBox.text = "";
            appGrid.currentIndex = 0;
            Qt.callLater(() => searchBox.textInput.forceActiveFocus());
        }
    }

    Item {
        id: launcher
        anchors.fill: parent
        opacity: root.opened ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: Globals.animationTime
                easing.type: Easing.OutCubic
            }
        }

        Rectangle {
            anchors.fill: parent
            color: Matugen.surface_container_low_a
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.closeLauncher()
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 30
            spacing: 18

            RowLayout {
                Layout.fillWidth: true

                ColumnLayout {
                    spacing: 3
                    Text {
                        text: "Applications"
                        color: Matugen.on_surface
                        font.pixelSize: 28
                        font.weight: Font.Bold
                    }
                    Text {
                        text: "Search and launch installed applications"
                        color: Matugen.on_surface_variant
                        font.pixelSize: 13
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                Rectangle {
                    Layout.preferredWidth: 42
                    Layout.preferredHeight: 42
                    radius: 14
                    color: closeMouse.containsMouse ? Matugen.surface_container_high : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "×"
                        color: Matugen.on_surface_a
                        font.pixelSize: 26
                    }

                    MouseArea {
                        id: closeMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.closeLauncher()
                    }
                }
            }

            InputBox {
                id: searchBox
                Layout.fillWidth: true
                label: ""
                icon: "system-search"
                placeholderText: "Search applications..."
                inputHeight: 56
                fontPixelSize: 18
                iconSize: 22
                horizontalPadding: 16
                cornerRadius: 15
                backgroundColor: Matugen.surface_container_a
                borderColor: Matugen.outline_variant
                focusedBorderColor: Matugen.primary

                onEdited: appGrid.currentIndex = 0
                onAccepted: root.launchSelected()

                onKeyPressed: event => {
                    switch (event.key) {
                    case Qt.Key_Escape:
                        root.closeLauncher();
                        event.accepted = true;
                        break;
                    case Qt.Key_Down:
                        root.moveSelection(root.gridColumns);
                        event.accepted = true;
                        break;
                    case Qt.Key_Up:
                        root.moveSelection(-root.gridColumns);
                        event.accepted = true;
                        break;
                    case Qt.Key_Right:
                        if (searchBox.textInput.cursorPosition === searchBox.text.length) {
                            root.moveSelection(1);
                            event.accepted = true;
                        }
                        break;
                    case Qt.Key_Left:
                        if (searchBox.textInput.cursorPosition === 0) {
                            root.moveSelection(-1);
                            event.accepted = true;
                        }
                        break;
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "Installed applications"
                    color: Matugen.on_surface
                    font.pixelSize: 15
                    font.weight: Font.DemiBold
                }
                Item {
                    Layout.fillWidth: true
                }
                Text {
                    text: filteredApplications.values.length + " results"
                    color: Matugen.on_surface_variant
                    font.pixelSize: 12
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                GridView {
                    id: appGrid
                    anchors.fill: parent
                    clip: true
                    cellWidth: 180
                    cellHeight: 142
                    model: filteredApplications
                    currentIndex: count > 0 ? 0 : -1
                    boundsBehavior: Flickable.StopAtBounds

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                    }

                    onCountChanged: {
                        if (count === 0)
                            currentIndex = -1;
                        else if (currentIndex < 0 || currentIndex >= count)
                            currentIndex = 0;
                    }

                    delegate: Item {
                        required property var modelData
                        required property int index
                        width: appGrid.cellWidth
                        height: appGrid.cellHeight

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 6
                            radius: 17
                            color: appGrid.currentIndex === index ? Matugen.primary_container_a : Matugen.surface_a
                            border.width: appGrid.currentIndex === index ? 1 : 0
                            border.color: Matugen.primary

                            Behavior on color {
                                ColorAnimation {
                                    duration: Globals.animationTime
                                }
                            }

                            Column {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 6

                                Image {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: 46
                                    height: 46
                                    source: Quickshell.iconPath(modelData.icon || "application-x-executable")
                                    sourceSize: Qt.size(46, 46)
                                    fillMode: Image.PreserveAspectFit
                                    asynchronous: true
                                }

                                Text {
                                    width: parent.width
                                    height: 34
                                    text: modelData.name
                                    color: appGrid.currentIndex === index ? Matugen.on_primary_container : Matugen.on_surface
                                    font.pixelSize: 13
                                    font.weight: Font.DemiBold
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    wrapMode: Text.Wrap
                                    maximumLineCount: 2
                                    elide: Text.ElideRight
                                }

                                Text {
                                    width: parent.width
                                    text: modelData.genericName || modelData.comment
                                    color: appGrid.currentIndex === index ? Matugen.on_primary_container : Matugen.on_surface_variant
                                    font.pixelSize: 10
                                    horizontalAlignment: Text.AlignHCenter
                                    elide: Text.ElideRight
                                    maximumLineCount: 1
                                }
                            }
                        }

                        MouseArea {
                            id: appMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: appGrid.currentIndex = index
                            onClicked: root.launchApplication(modelData)
                        }
                    }
                }

                Column {
                    anchors.centerIn: parent
                    spacing: 8
                    visible: appGrid.count === 0
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "No applications found"
                        color: Matugen.on_surface
                        font.pixelSize: 18
                        font.weight: Font.DemiBold
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Try a different search"
                        color: Matugen.on_surface_variant
                        font.pixelSize: 13
                    }
                }

                Text {
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    visible: !desktopEntryLauncher.ready
                    text: "Indexing desktop files..."
                    color: Matugen.on_surface_variant
                    font.pixelSize: 11
                }
            }

            Text {
                Layout.fillWidth: true
                visible: root.launchError.length > 0
                text: root.launchError
                color: Matugen.error
                font.pixelSize: 12
                elide: Text.ElideRight
            }

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "↑ ↓ Navigate    ·    Enter Launch    ·    Esc Close"
                    color: Matugen.on_surface_variant
                    font.pixelSize: 12
                }
                Item {
                    Layout.fillWidth: true
                }
                Text {
                    text: "Quickshell"
                    color: Matugen.outline
                    font.pixelSize: 11
                }
            }
        }
    }

    IpcHandler {
        target: "applauncher"
        function toggle(): void {
            root.toggleLauncher();
        }
        function close(): void {
            root.closeLauncher();
        }
        function open(): void {
            root.openLauncher();
        }
    }
}

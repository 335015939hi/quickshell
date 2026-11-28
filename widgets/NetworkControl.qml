import Quickshell
import QtQuick
import Quickshell.Networking
import Quickshell.Io
import QtQuick.Layouts
import QtQuick.Controls
import qs

ScrollView {
    id: root

    anchors.fill: parent

    contentWidth: availableWidth
    contentHeight: content.implicitHeight

    ScrollBar.vertical.policy: ScrollBar.AsNeeded
    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

    readonly property bool hasWifiDevice: Networking.devices.values.some(
        device => device.type === DeviceType.Wifi
    )

    property bool wifiScanPending: false
    property string wifiScanInterface: ""
    property string wifiScanDbusPath: ""
    property double wifiScanLastScanBefore: -1

    function finishWifiScan() {
        wifiScanPending = false;
        wifiScanPollTimer.stop();
        wifiScanTimeout.stop();
    }

    function scanWifiDevices() {
        if (!Networking.wifiEnabled || !root.visible || wifiScanPending)
            return;

        const wifiDevice = Networking.devices.values.find(
            device => device.type === DeviceType.Wifi
        );
        if (!wifiDevice)
            return;

        wifiScanPending = true;
        wifiScanInterface = wifiDevice.name;
        wifiScanDbusPath = "";
        wifiScanLastScanBefore = -1;
        wifiScanTimeout.restart();

        // Read LastScan before requesting a scan so we can detect its next update.
        wifiScanGetDevicePath.command = [
            "nmcli", "-g", "GENERAL.DBUS-PATH", "device", "show",
            wifiScanInterface
        ];
        wifiScanGetDevicePath.running = true;
    }

    onVisibleChanged: {
        if (visible)
            scanWifiDevices();
    }
    Component.onCompleted: {
        if (root.visible)
            scanWifiDevices();
    }
    Component.onDestruction: finishWifiScan()

    Connections {
        target: Networking

        function onWifiEnabledChanged() {
            if (Networking.wifiEnabled)
                root.scanWifiDevices();
            else
                root.finishWifiScan();
        }
    }

    ColumnLayout {
        id: controls
        width: root.availableWidth
        spacing: 8
        HoverArea {
            implicitWidth: wifiToggleRow.width
            implicitHeight: wifiToggleRow.height + 2 * controls.spacing
            RowLayout {
                id: wifiToggleRow
                width: controls.width
                anchors.verticalCenter: parent.verticalCenter
                Image {
                    source: Quickshell.iconPath(wifiToggleSwitch.checked ? "network-wireless-on" : "network-wireless-off")
                    sourceSize: Qt.size(24, 24)
                    width: 24
                    height: 24
                    fillMode: Image.PreserveAspectFit
                }
                ToggleSwitch {
                    id: wifiToggleSwitch
                    checked: Networking.wifiEnabled
                    disabled: !Networking.wifiHardwareEnabled
                    onCheck: function () {
                        Networking.wifiEnabled = !Networking.wifiEnabled;
                    }
                    Layout.alignment: Qt.AlignRight
                }
            }
            onClicked: {
                wifiToggleSwitch.toggle();
            }
            BarTooltip {
                text: "Toggle WiFi"
            }
        }

        HoverArea {
            implicitWidth: networkDetails.width
            implicitHeight: networkDetails.height + 2 * controls.spacing
            RowLayout {
                id: networkDetails
                width: controls.width
                anchors.verticalCenter: parent.verticalCenter

                Image {
                    source: Quickshell.iconPath(Globals.networkIcon)
                    sourceSize: Qt.size(24, 24)
                    width: 24
                    height: 24
                    fillMode: Image.PreserveAspectFit
                }

                Column {
                    Row {
                        Text {
                            text: "Network: " + Globals.networkName
                            color: Matugen.on_surface
                        }
                    }
                    Row {
                        Text {
                            color: Matugen.on_surface
                            text: "IPv4: " + (Globals.ipv4 ? Globals.ipv4 : "Not configured")
                        }
                    }
                    Row {
                        Text {
                            color: Matugen.on_surface
                            text: "IPv6: " + (Globals.ipv6 ? Globals.ipv6 : "Not configured")
                        }
                    }
                }
            }
        }
        Rectangle {
            width: parent.width
            implicitHeight: wifiToggleSwitch.checked ? wifiNetworksView.implicitHeight : 0
            color: "transparent"
            clip: true

            ColumnLayout {
                id: wifiNetworksView
                width: parent.width
                spacing: controls.spacing

                RowLayout {
                    Text {
                        text: "WiFi Networks"
                        Layout.alignment: Qt.AlignVCenter
                        Layout.fillWidth: true
                        color: Matugen.on_surface
                    }

                    IconButton {
                        icon: "view-refresh"
                        tooltip: "Re-scan WiFi networks"
                        enabled: wifiToggleSwitch.checked && root.hasWifiDevice && !root.wifiScanPending
                        onClicked: root.scanWifiDevices()
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: Matugen.primary
                    Layout.alignment: Qt.AlignHCenter
                }

                Repeater {
                    model: Networking.devices

                    delegate: ListView {
                        id: wifiNetworksList

                        width: parent.width
                        Layout.preferredHeight: contentHeight
                        clip: true
                        spacing: 2
                        model: modelData.type === DeviceType.Wifi ? modelData.networks : null

                        delegate: HoverArea {
                            required property var modelData

                            implicitWidth: controls.width
                            implicitHeight: wifiNetworksListRow.implicitHeight + 2 * controls.spacing
                            hoverColor: Matugen.primary_a

                            RowLayout {
                                id: wifiNetworksListRow
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8
                                spacing: 8
                                Image {
                                    source: Quickshell.iconPath(Globals.getWifiSignalIcon(modelData.signalStrength))
                                    sourceSize: Qt.size(24, 24)
                                    width: 24
                                    height: 24
                                    fillMode: Image.PreserveAspectFit
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 1

                                    Text {
                                        Layout.fillWidth: true
                                        text: modelData.name.length > 0 ? modelData.name : "Hidden network"
                                        color: Matugen.on_surface
                                        font.pixelSize: 12
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: WifiSecurityType.toString(modelData.security) + " · " + Math.round(modelData.signalStrength * 100) + "%" + (modelData.known ? " · Saved" : "") + (modelData.connected ? " · Connected" : "")
                                        color: Matugen.on_surface_variant
                                        font.pixelSize: 10
                                        elide: Text.ElideRight
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Behavior on implicitHeight {
                NumberAnimation {
                    duration: Globals.animationTime
                    easing.type: Easing.InOutCubic
                }
            }
        }

        Text {
            text: "Connections"
            color: Matugen.on_surface
        }
        Rectangle {
            width: parent.width
            height: 1
            color: Matugen.primary
            Layout.alignment: Qt.AlignHCenter
        }
        Repeater {
            id: nmcliConnectionsView
            model: root.nmcliConnectionsList
            width: controls.width
            delegate: HoverArea {
                hoverColor: Matugen.primary_a
                required property var modelData
                implicitWidth: parent.width
                implicitHeight: nmcliConnectionsViewRow.implicitHeight + 2 * controls.spacing
                RowLayout {
                    id: nmcliConnectionsViewRow
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    spacing: 0
                    Image {
                        id: nmcliConnectionsItemIcon
                        source: Quickshell.iconPath(modelData.icon)
                        sourceSize: Qt.size(24, 24)
                        width: 24
                        height: 24
                        fillMode: Image.PreserveAspectFit
                    }
                    Text {
                        text: modelData["connection.id"]
                        color: Matugen.on_surface
                    }
                    Item {
                        Layout.fillWidth: true
                    }
                    IconButton {
                        icon: modelData.activated ? "network-disconnect" : "network-connect"
                        tooltip: modelData.activated ? "Disconnect" : "Connect"
                    }
                    IconButton {
                        id: nmcliConnectionsMenuIcon
                        icon: "overflow-menu"
                        tooltip: "More actions"
                    }
                }
            }
        }
    }

    property var nmcliConnectionsList: []
    property var nmcliConnectionsListTemp: []

    function splitColonEscape(s) {
        let r = [];
        let str = '';
        for (let i = 0; i < s.length; i++) {
            let c = s[i];
            if (c == '\\') {
                i++;
                str += s[i];
            } else if (c == ':') {
                r.push(str);
                str = '';
            } else {
                str += c;
            }
        }
        r.push(str);
        return r;
    }
    function connectionTypeToIcon(s, a) {
        switch (s) {
        case "802-3-ethernet":
            return a ? "network-wired" : "network-wired-unavailable";
        case "802-11-wireless":
            return !a ? "network-wireless" : "network-wireless-disconnected";
        default:
            return a ? "network-connect" : "network-disconnect";
        }
    }
    Process {
        id: nmcliGetConnections
        command: ["nmcli", "-t", "connection", "show"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                let connections = text.endsWith('\n') ? text.slice(0, -1) : text;
                connections = connections.split('\n');
                for (let i = 0; i < connections.length; i++) {
                    let con = root.splitColonEscape(connections[i]);
                    connections[i] = con[0];
                }
                root.nmcliConnectionsListTemp = connections;
                root.nmcliConnectionsList = [];
                if (root.nmcliConnectionsListTemp.length > 0) {
                    nmcliGetConnectionDetails.index = 0;
                    nmcliGetConnectionDetails.running = true;
                }
            }
        }
    }
    Process {
        id: nmcliGetConnectionDetails
        property int index: 0
        command: ["nmcli", "-t", "connection", "show", root.nmcliConnectionsListTemp[nmcliGetConnectionDetails.index]]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                let data = text.endsWith('\n') ? text.slice(0, -1) : text;
                data = data.split('\n');
                var details = {};
                for (let i = 0; i < data.length; i++) {
                    let s = data[i];
                    let colon = s.indexOf(':');
                    let key = [s.slice(0, colon), s.slice(colon + 1, s.length)];
                    details[key[0]] = key[1];
                }

                details.activated = details["GENERAL.STATE"] == "activated";
                details.icon = root.connectionTypeToIcon(details["connection.type"], details.activated);

                root.nmcliConnectionsListTemp[nmcliGetConnectionDetails.index] = details;

                if (nmcliGetConnectionDetails.index < root.nmcliConnectionsListTemp.length - 1) {
                    nmcliGetConnectionDetails.index++;
                    nmcliGetConnectionDetails.running = true;
                } else {
                    root.nmcliConnectionsList = root.nmcliConnectionsListTemp;
                }
            }
        }
    }

    // Resolve the NetworkManager D-Bus object for the Wi-Fi interface.
    Process {
        id: wifiScanGetDevicePath
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                if (!root.wifiScanPending)
                    return;

                const path = this.text.trim();
                if (!path.startsWith("/org/freedesktop/NetworkManager/Devices/")) {
                    console.warn("Could not resolve NetworkManager D-Bus path for", root.wifiScanInterface);
                    root.finishWifiScan();
                    return;
                }

                root.wifiScanDbusPath = path;
                wifiScanGetLastScanBefore.command = [
                    "busctl", "--system", "get-property",
                    "org.freedesktop.NetworkManager",
                    root.wifiScanDbusPath,
                    "org.freedesktop.NetworkManager.Device.Wireless",
                    "LastScan"
                ];
                wifiScanGetLastScanBefore.running = true;
            }
        }
    }

    // Capture the last completed scan timestamp before requesting another scan.
    Process {
        id: wifiScanGetLastScanBefore
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                if (!root.wifiScanPending)
                    return;

                const fields = this.text.trim().split(/\s+/);
                const timestamp = Number(fields[fields.length - 1]);
                if (!Number.isFinite(timestamp)) {
                    console.warn("Could not read NetworkManager LastScan timestamp:", this.text);
                    root.finishWifiScan();
                    return;
                }

                root.wifiScanLastScanBefore = timestamp;
                nmcliRescanWifi.running = true;
            }
        }
    }

    Process {
        id: nmcliRescanWifi
        command: ["nmcli", "device", "wifi", "rescan"]
        running: false

        onExited: function(exitCode, exitStatus) {
            if (!root.wifiScanPending)
                return;

            if (exitCode !== 0) {
                console.warn("nmcli Wi-Fi rescan failed with exit code", exitCode);
                root.finishWifiScan();
                return;
            }

            // nmcli only submits the request. LastScan changes when NetworkManager
            // has actually completed the wireless scan.
            wifiScanPollTimer.start();
        }
    }

    Process {
        id: wifiScanPollLastScan
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                if (!root.wifiScanPending)
                    return;

                const fields = this.text.trim().split(/\s+/);
                const timestamp = Number(fields[fields.length - 1]);
                if (!Number.isFinite(timestamp)) {
                    console.warn("Could not read NetworkManager LastScan timestamp:", this.text);
                    root.finishWifiScan();
                    return;
                }

                if (timestamp > root.wifiScanLastScanBefore)
                    root.finishWifiScan();
            }
        }
    }

    Timer {
        id: wifiScanPollTimer
        interval: 500
        repeat: true
        onTriggered: {
            if (root.wifiScanPending && !wifiScanPollLastScan.running)
                wifiScanPollLastScan.running = true;
        }
    }

    Timer {
        id: wifiScanTimeout
        interval: 30000
        repeat: false
        onTriggered: {
            if (root.wifiScanPending) {
                console.warn("Timed out waiting for NetworkManager Wi-Fi scan completion");
                root.finishWifiScan();
            }
        }
    }
}

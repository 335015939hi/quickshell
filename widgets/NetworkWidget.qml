import QtQuick
import Quickshell.Io
import Quickshell.Networking

// A reusable NetworkManager-backed network control widget.
// Import this file as a QML type and place NetworkWidget wherever it is needed.
Item {
    id: root

    // Appearance
    property color cardColor: "#242536"
    property color innerColor: "#303246"
    property color textColor: "#e2e4f3"
    property color mutedTextColor: "#a6a9bd"
    property color accentColor: "#89b4fa"
    property color dangerColor: "#f38ba8"
    property int cornerRadius: 12
    property int preferredWidth: 360

    // Behaviour / layout. The parent owns outer margins and positioning.
    property bool showWifi: true
    property bool showEthernet: true
    property bool showIpAddresses: true
    property int networkListHeight: 220
    property int animationDuration: 200

    // Internal connection prompt state
    property var pendingNetwork: null
    property string passwordInput: ""
    property string passwordError: ""
    property bool passwordPromptOpen: false
    property string statusMessage: ""

    // Ethernet activation and advanced NetworkManager profile editor.
    property string ethernetPendingInterface: ""
    property bool ethernetActionBusy: false
    property string ethernetCommandError: ""

    property bool configOpen: false
    property string configDeviceName: ""
    property string configDeviceKind: "ethernet"
    property string configMtuProperty: "802-3-ethernet.mtu"
    property string configUuid: ""
    property string configStatus: ""
    property string configCommandError: ""
    property string configIpv4Mode: "auto"
    property string configIpv4Address: ""
    property string configIpv4Gateway: ""
    property string configIpv4Dns: ""
    property string configIpv4Search: ""
    property string configIpv6Mode: "auto"
    property string configIpv6Address: ""
    property string configIpv6Gateway: ""
    property string configIpv6Dns: ""
    property string configIpv6Search: ""
    property string configMtu: "0"
    property bool configAutoconnect: true

    readonly property bool anyConnected: Networking.devices.values.some(device => device.connected)

    implicitWidth: preferredWidth
    implicitHeight: content.implicitHeight
    width: implicitWidth
    height: implicitHeight

    component ConfigField: Row {
        id: fieldRoot
        property string label: ""
        property string value: ""
        property color textColor: root.textColor
        property color mutedTextColor: root.mutedTextColor
        property color fieldColor: root.innerColor
        property color fieldBorderColor: root.accentColor
        signal edited(string value)

        width: parent ? parent.width : 0
        height: 34
        spacing: 8

        Text {
            id: configFieldLabel
            text: fieldRoot.label
            color: fieldRoot.mutedTextColor
            font.pixelSize: 11
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        Rectangle {
            width: Math.max(0, fieldRoot.width - configFieldLabel.width)
            height: 34
            radius: 7
            color: fieldRoot.fieldColor
            border.width: 1
            border.color: fieldRoot.fieldBorderColor

            TextInput {
                anchors.fill: parent
                anchors.leftMargin: 9
                anchors.rightMargin: 9
                verticalAlignment: TextInput.AlignVCenter
                color: fieldRoot.textColor
                selectedTextColor: root.innerColor
                selectionColor: root.accentColor
                font.pixelSize: 12
                selectByMouse: true
                text: fieldRoot.value
                onTextChanged: fieldRoot.edited(text)
            }
        }
    }

    component AdvancedEditor: Rectangle {
        property string deviceName: ""
        readonly property bool active: root.configOpen && root.configDeviceName === deviceName

        Rectangle {
            visible: active || opacity > 0.001
            width: parent ? parent.width : root.width
            radius: root.cornerRadius
            color: root.cardColor
            implicitHeight: advancedContent.implicitHeight + 24
            height: active ? implicitHeight : 0
            opacity: active ? 1 : 0
            clip: true
            enabled: active
    
            Behavior on height {
                NumberAnimation { duration: root.animationDuration; easing.type: Easing.OutCubic }
            }
    
            Behavior on opacity {
                NumberAnimation { duration: root.animationDuration; easing.type: Easing.OutCubic }
            }
    
            Column {
                id: advancedContent
                anchors.fill: parent
                anchors.margins: 14
                spacing: 9
    
                Row {
                    width: parent.width
                    height: 28
    
                    Text {
                        width: parent.width - closeAdvanced.width - 8
                        text: "Advanced · " + root.configDeviceName
                        color: root.textColor
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                        elide: Text.ElideRight
                        anchors.verticalCenter: parent.verticalCenter
                    }
    
                    Rectangle {
                        id: closeAdvanced
                        width: 28
                        height: 28
                        radius: 7
                        color: root.innerColor
    
                        Text {
                            anchors.centerIn: parent
                            text: "×"
                            color: root.textColor
                            font.pixelSize: 18
                        }
    
                        MouseArea {
                            anchors.fill: parent
                            onClicked: root.closeAdvanced()
                        }
                    }
                }
    
                Text {
                    visible: !root.configUuid && root.configStatus.length > 0
                    width: parent.width
                    text: root.configStatus
                    color: root.mutedTextColor
                    font.pixelSize: 11
                    wrapMode: Text.WordWrap
                }
    
                Column {
                    visible: root.configUuid.length > 0
                    width: parent.width
                    spacing: 8
    
                    Text {
                        text: "IPv4"
                        color: root.textColor
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                    }
    
                    Row {
                        width: parent.width
                        spacing: 5
    
                        Repeater {
                            model: [
                                {
                                    label: "Auto",
                                    value: "auto"
                                },
                                {
                                    label: "Manual",
                                    value: "manual"
                                },
                                {
                                    label: "Off",
                                    value: "disabled"
                                }
                            ]
    
                            delegate: Rectangle {
                                required property var modelData
                                width: (parent.width - 10) / 3
                                height: 28
                                radius: 7
                                color: root.configIpv4Mode === modelData.value ? root.accentColor : root.innerColor
    
                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.label
                                    color: root.configIpv4Mode === modelData.value ? "#171925" : root.textColor
                                    font.pixelSize: 10
                                    font.weight: root.configIpv4Mode === modelData.value ? Font.DemiBold : Font.Normal
                                }
    
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: root.configIpv4Mode = modelData.value
                                }
                            }
                        }
                    }
    
                    ConfigField {
                        visible: root.configIpv4Mode === "manual"
                        width: parent.width
                        label: "Address/CIDR"
                        value: root.configIpv4Address
                        onEdited: value => root.configIpv4Address = value
                    }
    
                    ConfigField {
                        visible: root.configIpv4Mode === "manual"
                        width: parent.width
                        label: "Gateway"
                        value: root.configIpv4Gateway
                        onEdited: value => root.configIpv4Gateway = value
                    }
    
                    ConfigField {
                        visible: root.configIpv4Mode !== "disabled"
                        width: parent.width
                        label: "DNS"
                        value: root.configIpv4Dns
                        onEdited: value => root.configIpv4Dns = value
                    }
    
                    ConfigField {
                        visible: root.configIpv4Mode !== "disabled"
                        width: parent.width
                        label: "Search"
                        value: root.configIpv4Search
                        onEdited: value => root.configIpv4Search = value
                    }
    
                    Rectangle {
                        width: parent.width
                        height: 1
                        color: root.accentColor
                    }
    
                    Text {
                        text: "IPv6"
                        color: root.textColor
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                    }
    
                    Row {
                        width: parent.width
                        spacing: 4
    
                        Repeater {
                            model: [
                                {
                                    label: "Auto",
                                    value: "auto"
                                },
                                {
                                    label: "DHCP",
                                    value: "dhcp"
                                },
                                {
                                    label: "Manual",
                                    value: "manual"
                                },
                                {
                                    label: "Link-local",
                                    value: "link-local"
                                },
                                {
                                    label: "Off",
                                    value: "disabled"
                                }
                            ]
    
                            delegate: Rectangle {
                                required property var modelData
                                width: (parent.width - 16) / 5
                                height: 28
                                radius: 7
                                color: root.configIpv6Mode === modelData.value ? root.accentColor : root.innerColor
    
                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.label
                                    color: root.configIpv6Mode === modelData.value ? "#171925" : root.textColor
                                    font.pixelSize: 9
                                    font.weight: root.configIpv6Mode === modelData.value ? Font.DemiBold : Font.Normal
                                }
    
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: root.configIpv6Mode = modelData.value
                                }
                            }
                        }
                    }
    
                    ConfigField {
                        visible: root.configIpv6Mode === "manual"
                        width: parent.width
                        label: "Address/CIDR"
                        value: root.configIpv6Address
                        onEdited: value => root.configIpv6Address = value
                    }
    
                    ConfigField {
                        visible: root.configIpv6Mode === "manual"
                        width: parent.width
                        label: "Gateway"
                        value: root.configIpv6Gateway
                        onEdited: value => root.configIpv6Gateway = value
                    }
    
                    ConfigField {
                        visible: root.configIpv6Mode === "auto" || root.configIpv6Mode === "dhcp" || root.configIpv6Mode === "manual"
                        width: parent.width
                        label: "DNS"
                        value: root.configIpv6Dns
                        onEdited: value => root.configIpv6Dns = value
                    }
    
                    ConfigField {
                        visible: root.configIpv6Mode === "auto" || root.configIpv6Mode === "dhcp" || root.configIpv6Mode === "manual"
                        width: parent.width
                        label: "Search"
                        value: root.configIpv6Search
                        onEdited: value => root.configIpv6Search = value
                    }
    
                    Rectangle {
                        width: parent.width
                        height: 1
                        color: root.accentColor
                    }
    
                    Text {
                        text: "Connection"
                        color: root.textColor
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                    }
    
                    ConfigField {
                        width: parent.width
                        label: "MTU"
                        value: root.configMtu
                        onEdited: value => root.configMtu = value
                    }
    
                    Rectangle {
                        width: parent.width
                        height: 30
                        radius: 7
                        color: root.innerColor
    
                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: 9
                            anchors.rightMargin: 9
    
                            Text {
                                width: parent.width - 42
                                text: "Autoconnect"
                                color: root.textColor
                                font.pixelSize: 11
                                anchors.verticalCenter: parent.verticalCenter
                            }
    
                            Rectangle {
                                width: 34
                                height: 20
                                radius: 10
                                color: root.configAutoconnect ? root.accentColor : root.mutedTextColor
                                anchors.verticalCenter: parent.verticalCenter
    
                                Rectangle {
                                    width: 14
                                    height: 14
                                    radius: 7
                                    color: root.textColor
                                    x: root.configAutoconnect ? 17 : 3
                                    anchors.verticalCenter: parent.verticalCenter
                                }
    
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: root.configAutoconnect = !root.configAutoconnect
                                }
                            }
                        }
                    }
    
                    Text {
                        visible: root.configStatus.length > 0
                        width: parent.width
                        text: root.configStatus
                        color: root.configStatus.startsWith("Configuration applied") ? root.accentColor : root.dangerColor
                        font.pixelSize: 11
                        wrapMode: Text.WordWrap
                    }
    
                    Row {
                        width: parent.width
                        height: 32
                        spacing: 8
    
                        Item {
                            width: Math.max(0, parent.width - applyConfigButton.width - 8)
                            height: 1
                        }
    
                        Rectangle {
                            id: applyConfigButton
                            width: 112
                            height: 30
                            radius: 7
                            color: root.accentColor
                            opacity: root.configUuid.length > 0 ? 1.0 : 0.45
    
                            Text {
                                anchors.centerIn: parent
                                text: "Apply changes"
                                color: "#171925"
                                font.pixelSize: 11
                                font.weight: Font.DemiBold
                            }
    
                            MouseArea {
                                anchors.fill: parent
                                enabled: root.configUuid.length > 0 && !configApplyProcess.running && !configActivateProcess.running
                                onClicked: root.applyAdvancedConfig()
                            }
                        }
                    }
                }
    
                Text {
                    visible: root.configUuid.length > 0 && !root.configStatus.startsWith("Configuration applied")
                    width: parent.width
                    text: "Changes affect the saved NetworkManager profile. Reconnecting may briefly interrupt network access."
                    color: root.mutedTextColor
                    font.pixelSize: 10
                    wrapMode: Text.WordWrap
                }
            }
        }
    }

    component WifiPasswordPrompt: Rectangle {
        required property var network
        readonly property bool active: root.passwordPromptOpen && root.pendingNetwork === network

        Rectangle {
            visible: active || opacity > 0.001
            width: parent ? parent.width : root.width
            radius: root.cornerRadius
            color: root.cardColor
            implicitHeight: passwordContent.implicitHeight + 24
            height: active ? implicitHeight : 0
            opacity: active ? 1 : 0
            clip: true
            enabled: active
    
            Behavior on height {
                NumberAnimation { duration: root.animationDuration; easing.type: Easing.OutCubic }
            }
    
            Behavior on opacity {
                NumberAnimation { duration: root.animationDuration; easing.type: Easing.OutCubic }
            }
    
            Column {
                id: passwordContent
                anchors.fill: parent
                anchors.margins: 14
                spacing: 9
    
                Text {
                    text: network ? "Password for " + network.name : "Wi-Fi password"
                    color: root.textColor
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                    width: parent.width
                    elide: Text.ElideRight
                }
    
                Rectangle {
                    width: parent.width
                    height: 38
                    radius: 7
                    color: root.innerColor
                    border.color: root.accentColor
    
                    TextInput {
                        id: passwordField
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        verticalAlignment: TextInput.AlignVCenter
                        color: root.textColor
                        selectedTextColor: root.innerColor
                        selectionColor: root.accentColor
                        font.pixelSize: 13
                        echoMode: TextInput.Password
                        text: root.passwordInput
                        onTextChanged: root.passwordInput = text
                        onAccepted: root.submitPassword()
                    }
                }
    
                Text {
                    visible: root.passwordError.length > 0
                    text: root.passwordError
                    color: root.passwordError.startsWith("Connecting") ? root.mutedTextColor : root.dangerColor
                    font.pixelSize: 11
                    width: parent.width
                    wrapMode: Text.WordWrap
                }
    
                Row {
                    width: parent.width
                    height: 30
                    spacing: 8
    
                    Item {
                        width: Math.max(0, parent.width - cancelButton.width - connectPasswordButton.width - 16)
                        height: 1
                    }
    
                    Rectangle {
                        id: cancelButton
                        width: 72
                        height: 28
                        radius: 7
                        color: root.innerColor
    
                        Text {
                            anchors.centerIn: parent
                            text: "Cancel"
                            color: root.textColor
                            font.pixelSize: 11
                        }
    
                        MouseArea {
                            anchors.fill: parent
                            onClicked: root.cancelPasswordPrompt()
                        }
                    }
    
                    Rectangle {
                        id: connectPasswordButton
                        width: 82
                        height: 28
                        radius: 7
                        color: root.accentColor
    
                        Text {
                            anchors.centerIn: parent
                            text: "Connect"
                            color: "#171925"
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                        }
    
                        MouseArea {
                            anchors.fill: parent
                            enabled: root.passwordInput.length > 0
                            onClicked: root.submitPassword()
                        }
                    }
                }
            }
        }
    }

    function normaliseList(value) {
        return value.trim().split(/[,\s]+/).filter(part => part.length > 0).join(",");
    }

    function nmField(output, field, fallback) {
        const escaped = field.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
        const match = output.match(new RegExp("^" + escaped + ":\\s*(.*)$", "m"));
        if (!match)
            return fallback;
        const value = match[1].trim();
        return value === "--" ? "" : value;
    }

    function closeAdvanced() {
        configOpen = false;
        configUuid = "";
        configStatus = "";
        configUuidProcess.running = false;
        configShowProcess.running = false;
    }

    // The Advanced button is a toggle for the device currently being edited.
    // Clicking another device switches the editor to that device.
    function toggleAdvanced(device) {
        if (configOpen && configDeviceName === device.name) {
            root.closeAdvanced();
            return;
        }

        // Do not let an earlier device's pending nmcli query populate the new editor.
        configUuidProcess.running = false;
        configShowProcess.running = false;
        configDeviceName = device.name;
        configDeviceKind = device.type === DeviceType.Wifi ? "wifi" : "ethernet";
        configMtuProperty = configDeviceKind === "wifi" ? "802-11-wireless.mtu" : "802-3-ethernet.mtu";
        configUuid = "";
        configStatus = "Finding the active connection…";
        configCommandError = "";
        configOpen = true;
        configUuidProcess.command = ["nmcli", "-g", "GENERAL.CON-UUID", "device", "show", device.name];
        configUuidProcess.running = true;
    }

    function loadConfigForUuid(output) {
        // Ignore a late result if the editor was closed while nmcli was running.
        if (!configOpen)
            return;

        const uuid = output.trim().split("\n")[0];
        if (!uuid || uuid === "--") {
            configStatus = "No active NetworkManager profile was found. Connect this device first.";
            return;
        }

        configUuid = uuid;
        configStatus = "Loading connection settings…";
        configShowProcess.command = ["nmcli", "--mode", "multiline", "--fields", "connection.autoconnect,ipv4.method,ipv4.addresses,ipv4.gateway,ipv4.dns,ipv4.dns-search,ipv6.method,ipv6.addresses,ipv6.gateway,ipv6.dns,ipv6.dns-search," + configMtuProperty, "connection", "show", "uuid", uuid];
        configShowProcess.running = true;
    }

    function populateConfig(output) {
        if (!configOpen)
            return;

        configAutoconnect = nmField(output, "connection.autoconnect", "yes") !== "no";
        configIpv4Mode = nmField(output, "ipv4.method", "auto") || "auto";
        configIpv4Address = nmField(output, "ipv4.addresses", "");
        configIpv4Gateway = nmField(output, "ipv4.gateway", "");
        configIpv4Dns = nmField(output, "ipv4.dns", "");
        configIpv4Search = nmField(output, "ipv4.dns-search", "");
        configIpv6Mode = nmField(output, "ipv6.method", "auto") || "auto";
        configIpv6Address = nmField(output, "ipv6.addresses", "");
        configIpv6Gateway = nmField(output, "ipv6.gateway", "");
        configIpv6Dns = nmField(output, "ipv6.dns", "");
        configIpv6Search = nmField(output, "ipv6.dns-search", "");
        configMtu = nmField(output, configMtuProperty, "0") || "0";
        configStatus = "";
    }

    function connectEthernet(interfaceName) {
        if (root.ethernetActionBusy)
            return;
        ethernetPendingInterface = interfaceName;
        ethernetCommandError = "";
        root.ethernetActionBusy = true;
        statusMessage = "Connecting Ethernet…";
        ethernetConnectProcess.command = ["nmcli", "--wait", "30", "device", "connect", interfaceName];
        ethernetConnectProcess.running = true;
    }

    function applyAdvancedConfig() {
        if (!configUuid)
            return;
        if (configIpv4Mode === "manual" && !configIpv4Address.trim()) {
            configStatus = "Enter an IPv4 address with its prefix, for example 192.168.1.20/24.";
            return;
        }
        if (configIpv6Mode === "manual" && !configIpv6Address.trim()) {
            configStatus = "Enter an IPv6 address with its prefix.";
            return;
        }

        const v4dns = configIpv4Mode === "disabled" ? "" : normaliseList(configIpv4Dns);
        const v4search = configIpv4Mode === "disabled" ? "" : normaliseList(configIpv4Search);
        const v6DnsEnabled = configIpv6Mode !== "disabled" && configIpv6Mode !== "link-local";
        const v6dns = v6DnsEnabled ? normaliseList(configIpv6Dns) : "";
        const v6search = v6DnsEnabled ? normaliseList(configIpv6Search) : "";
        const mtu = configMtu.trim().toLowerCase();
        if (mtu.length > 0 && mtu !== "auto" && !/^\d+$/.test(mtu)) {
            configStatus = "MTU must be a number, or 0 for automatic.";
            return;
        }

        const args = ["nmcli", "connection", "modify", "uuid", configUuid, "connection.autoconnect", configAutoconnect ? "yes" : "no", "ipv4.method", configIpv4Mode, "ipv4.addresses", configIpv4Mode === "manual" ? configIpv4Address.trim() : "", "ipv4.gateway", configIpv4Mode === "manual" ? configIpv4Gateway.trim() : "", "ipv4.dns", v4dns, "ipv4.dns-search", v4search, "ipv4.ignore-auto-dns", (v4dns.length > 0 || v4search.length > 0) ? "yes" : "no", "ipv6.method", configIpv6Mode, "ipv6.addresses", configIpv6Mode === "manual" ? configIpv6Address.trim() : "", "ipv6.gateway", configIpv6Mode === "manual" ? configIpv6Gateway.trim() : "", "ipv6.dns", v6dns, "ipv6.dns-search", v6search, "ipv6.ignore-auto-dns", (v6dns.length > 0 || v6search.length > 0) ? "yes" : "no", configMtuProperty, mtu.length === 0 || mtu === "auto" ? "0" : mtu];

        configCommandError = "";
        configStatus = "Saving profile settings…";
        configApplyProcess.command = args;
        configApplyProcess.running = true;
    }

    function isPskSecurity(security) {
        return security === WifiSecurityType.WpaPsk || security === WifiSecurityType.Wpa2Psk || security === WifiSecurityType.Sae;
    }

    function connectToNetwork(network) {
        statusMessage = "";

        if (network.connected) {
            network.disconnect();
            return;
        }

        if (network.stateChanging)
            return;

        // A saved profile may already contain the credentials.
        if (network.known || network.security === WifiSecurityType.Open || network.security === WifiSecurityType.Owe) {
            network.connect();
            return;
        }

        if (isPskSecurity(network.security)) {
            pendingNetwork = network;
            passwordInput = "";
            passwordError = "";
            passwordPromptOpen = true;
            return;
        }

        statusMessage = "\"" + network.name + "\" uses " + WifiSecurityType.toString(network.security) + ". Configure this network in NetworkManager first.";
    }

    function submitPassword() {
        if (!pendingNetwork || passwordInput.length === 0)
            return;

        passwordError = "Connecting…";
        pendingNetwork.connectWithPsk(passwordInput);
    }

    function cancelPasswordPrompt() {
        passwordPromptOpen = false;
        pendingNetwork = null;
        passwordInput = "";
        passwordError = "";
    }

    function setWifiScanning(enabled) {
        const shouldScan = enabled && Networking.wifiEnabled && visible;
        for (const device of Networking.devices.values) {
            if (device.type === DeviceType.Wifi)
                device.scannerEnabled = shouldScan;
        }
    }

    function scanWifiDevices() {
        setWifiScanning(true);
    }

    function parseIpAddresses(output) {
        const result = [];
        const lines = output.split("\n");

        for (const line of lines) {
            // Omit loopback and IPv6 link-local addresses.
            if (!line.includes("scope global"))
                continue;

            const match = line.match(/\binet6?\s+([^\s]+)/);
            if (!match)
                continue;

            const family = line.includes(" inet6 ") ? "IPv6" : "IPv4";
            result.push(family + ": " + match[1]);
        }

        return result.length > 0 ? result.join("\n") : "No global IP address";
    }

    onVisibleChanged: setWifiScanning(visible)
    Component.onCompleted: scanWifiDevices()

    Connections {
        target: Networking

        function onWifiEnabledChanged() {
            root.setWifiScanning(Networking.wifiEnabled);
        }

        //function onDevicesChanged() {
        //    root.scanWifiDevices();
        //}
    }

    Connections {
        target: root.pendingNetwork
        ignoreUnknownSignals: true

        function onConnectionFailed(reason) {
            root.passwordError = "Connection failed. Check the password and try again.";
        }

        function onConnectedChanged() {
            if (root.pendingNetwork && root.pendingNetwork.connected) {
                root.passwordPromptOpen = false;
                root.pendingNetwork = null;
                root.passwordInput = "";
                root.passwordError = "";
                root.statusMessage = "Connected";
            }
        }
    }

    Process {
        id: ethernetConnectProcess
        command: ["nmcli"]
        stderr: StdioCollector {
            onStreamFinished: root.ethernetCommandError = this.text.trim()
        }
        onExited: function (exitCode, exitStatus) {
            root.ethernetActionBusy = false;
            root.statusMessage = exitCode === 0 ? "Ethernet connected on " + root.ethernetPendingInterface : "Ethernet connection failed: " + (root.ethernetCommandError || "NetworkManager returned an error.");
        }
    }

    Process {
        id: configUuidProcess
        command: ["nmcli"]
        stdout: StdioCollector {
            onStreamFinished: root.loadConfigForUuid(this.text)
        }
        stderr: StdioCollector {
            onStreamFinished: root.configCommandError = this.text.trim()
        }
        onExited: function (exitCode, exitStatus) {
            if (exitCode !== 0 && !root.configUuid && root.configOpen)
                root.configStatus = root.configCommandError || "Could not read the active connection profile.";
        }
    }

    Process {
        id: configShowProcess
        command: ["nmcli"]
        stdout: StdioCollector {
            onStreamFinished: root.populateConfig(this.text)
        }
        stderr: StdioCollector {
            onStreamFinished: root.configCommandError = this.text.trim()
        }
        onExited: function (exitCode, exitStatus) {
            if (exitCode !== 0 && root.configOpen) {
                root.configUuid = "";
                root.configStatus = root.configCommandError || "Could not load connection settings.";
            }
        }
    }

    Process {
        id: configApplyProcess
        command: ["nmcli"]
        stderr: StdioCollector {
            onStreamFinished: root.configCommandError = this.text.trim()
        }
        onExited: function (exitCode, exitStatus) {
            if (exitCode === 0) {
                root.configStatus = "Saved. Reconnecting to apply the changes…";
                configActivateProcess.command = ["nmcli", "--wait", "45", "connection", "up", "uuid", root.configUuid, "ifname", root.configDeviceName];
                configActivateProcess.running = true;
            } else {
                root.configStatus = root.configCommandError || "NetworkManager rejected the configuration.";
            }
        }
    }

    Process {
        id: configActivateProcess
        command: ["nmcli"]
        stderr: StdioCollector {
            onStreamFinished: root.configCommandError = this.text.trim()
        }
        onExited: function (exitCode, exitStatus) {
            root.configStatus = exitCode === 0 ? "Configuration applied." : "Settings were saved, but reconnecting failed: " + (root.configCommandError || "check the connection and try again.");
        }
    }

    Column {
        id: content
        width: root.width
        spacing: 10

        // Heading and overall connection status
        Rectangle {
            width: root.width
            radius: root.cornerRadius
            color: root.cardColor
            implicitHeight: heading.implicitHeight + 24
            height: implicitHeight

            Row {
                id: heading
                anchors.fill: parent
                anchors.margins: 14
                spacing: 10

                Column {
                    width: heading.width - stateLabel.implicitWidth - heading.spacing
                    spacing: 2

                    Text {
                        text: "Network"
                        color: root.textColor
                        font.pixelSize: 16
                        font.weight: Font.DemiBold
                    }

                    Text {
                        text: root.anyConnected ? "A network device is connected" : "No active connection"
                        color: root.mutedTextColor
                        font.pixelSize: 12
                    }
                }

                Text {
                    id: stateLabel
                    text: root.anyConnected ? "Connected" : "Offline"
                    color: root.anyConnected ? root.accentColor : root.mutedTextColor
                    font.pixelSize: 12
                    font.weight: Font.DemiBold
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        // Global Wi-Fi radio switch
        Rectangle {
            visible: root.showWifi || opacity > 0.001
            width: root.width
            radius: root.cornerRadius
            color: root.cardColor
            implicitHeight: wifiControl.implicitHeight + 24
            height: root.showWifi ? implicitHeight : 0
            opacity: root.showWifi ? 1 : 0
            clip: true
            enabled: root.showWifi

            Behavior on height {
                NumberAnimation { duration: root.animationDuration; easing.type: Easing.OutCubic }
            }

            Behavior on opacity {
                NumberAnimation { duration: root.animationDuration; easing.type: Easing.OutCubic }
            }

            Column {
                id: wifiControl
                anchors.fill: parent
                anchors.margins: 14
                spacing: 8

                // Use anchors rather than a calculated spacer: the switch stays
                // flush with the right edge regardless of the title's width.
                Item {
                    id: wifiHeader
                    width: parent.width
                    height: 30

                    Text {
                        text: "Wi-Fi"
                        color: root.textColor
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Rectangle {
                        width: 68
                        height: 30
                        radius: 8
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        color: Networking.wifiEnabled ? root.accentColor : root.innerColor
                        opacity: Networking.wifiHardwareEnabled ? 1.0 : 0.45

                        Behavior on color {
                            ColorAnimation { duration: 160; easing.type: Easing.OutCubic }
                        }

                        Behavior on opacity {
                            NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: Networking.wifiEnabled ? "On" : "Off"
                            color: Networking.wifiEnabled ? "#171925" : root.textColor
                            font.pixelSize: 12

                            Behavior on color {
                                ColorAnimation { duration: 160; easing.type: Easing.OutCubic }
                            }
                            font.weight: Font.DemiBold
                        }

                        MouseArea {
                            anchors.fill: parent
                            enabled: Networking.wifiHardwareEnabled
                            onClicked: Networking.wifiEnabled = !Networking.wifiEnabled
                        }
                    }
                }

                Text {
                    visible: !Networking.wifiHardwareEnabled
                    text: "Wi-Fi is disabled by the hardware radio switch."
                    color: root.dangerColor
                    font.pixelSize: 12
                    wrapMode: Text.WordWrap
                    width: parent.width
                }

                Text {
                    visible: !Networking.wifiEnabled && Networking.wifiHardwareEnabled
                    text: "Wi-Fi is turned off."
                    color: root.mutedTextColor
                    font.pixelSize: 12
                }
            }
        }

        // Wired interfaces. This intentionally includes only NetworkManager's
        // Wired devices; bridges, tunnels and Bluetooth PAN are not shown here.
        Repeater {
            model: Networking.devices

            delegate: Rectangle {
                id: wiredCard
                required property var modelData
                property string ipAddresses: ""

                property bool active: root.showEthernet && modelData.type === DeviceType.Wired
                visible: active || opacity > 0.001
                width: root.width
                radius: root.cornerRadius
                color: root.cardColor
                implicitHeight: wiredContent.implicitHeight + 24
                height: active ? implicitHeight : 0
                opacity: active ? 1 : 0
                clip: true
                enabled: active

                Behavior on height {
                    NumberAnimation { duration: root.animationDuration; easing.type: Easing.OutCubic }
                }

                Behavior on opacity {
                    NumberAnimation { duration: root.animationDuration; easing.type: Easing.OutCubic }
                }

                function disconnect() {
                    if (modelData.network)
                        modelData.network.disconnect();
                    else
                        modelData.disconnect();
                }

                Column {
                    id: wiredContent
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 7

                    Row {
                        width: parent.width
                        spacing: 8

                        Text {
                            width: parent.width - wiredState.implicitWidth - 8
                            text: "Ethernet · " + modelData.name
                            color: root.textColor
                            font.pixelSize: 14
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                        }

                        Text {
                            id: wiredState
                            text: modelData.connected ? "Connected" : (modelData.hasLink ? "Link detected" : "No cable")
                            color: modelData.connected ? root.accentColor : root.mutedTextColor
                            font.pixelSize: 11
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Text {
                        visible: modelData.connected
                        text: modelData.network ? modelData.network.name : "Wired connection"
                        color: root.mutedTextColor
                        font.pixelSize: 12
                    }

                    Text {
                        visible: root.showIpAddresses && modelData.connected
                        text: wiredCard.ipAddresses
                        color: root.mutedTextColor
                        font.pixelSize: 11
                        lineHeight: 1.25
                    }

                    Row {
                        width: parent.width
                        height: 30
                        spacing: 8

                        Item {
                            width: Math.max(0, parent.width - (modelData.connected ? wiredDisconnect.width + wiredAdvanced.width : wiredConnect.width) - (modelData.connected ? 16 : 8))
                            height: 1
                        }

                        Rectangle {
                            id: wiredConnect
                            visible: !modelData.connected
                            width: 82
                            height: 28
                            radius: 7
                            color: root.accentColor
                            opacity: modelData.hasLink && !root.ethernetActionBusy ? 1.0 : 0.45

                            Text {
                                anchors.centerIn: parent
                                text: root.ethernetActionBusy && root.ethernetPendingInterface === modelData.name ? "Connecting…" : "Connect"
                                color: "#171925"
                                font.pixelSize: 11
                                font.weight: Font.DemiBold
                            }

                            MouseArea {
                                anchors.fill: parent
                                enabled: modelData.hasLink && !root.ethernetActionBusy
                                onClicked: root.connectEthernet(modelData.name)
                            }
                        }

                        Rectangle {
                            id: wiredDisconnect
                            visible: modelData.connected
                            width: 86
                            height: 28
                            radius: 7
                            color: root.innerColor

                            Text {
                                anchors.centerIn: parent
                                text: "Disconnect"
                                color: root.textColor
                                font.pixelSize: 11
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: wiredCard.disconnect()
                            }
                        }

                        Rectangle {
                            id: wiredAdvanced
                            visible: modelData.connected
                            width: root.configOpen && root.configDeviceName === modelData.name ? 64 : 78
                            height: 28
                            radius: 7
                            color: root.configOpen && root.configDeviceName === modelData.name ? root.accentColor : root.innerColor

                            Text {
                                anchors.centerIn: parent
                                text: root.configOpen && root.configDeviceName === modelData.name ? "Close" : "Advanced"
                                color: root.configOpen && root.configDeviceName === modelData.name ? "#171925" : root.textColor
                                font.pixelSize: 11
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: root.toggleAdvanced(modelData)
                            }
                        }
                    }

                    AdvancedEditor {
                        width: parent.width
                        deviceName: modelData.name
                    }
                }

                Process {
                    id: wiredIpProcess
                    command: ["ip", "-o", "addr", "show", "dev", modelData.name]
                    stdout: StdioCollector {
                        onStreamFinished: wiredCard.ipAddresses = root.parseIpAddresses(this.text)
                    }
                }

                Timer {
                    interval: 5000
                    repeat: true
                    running: wiredCard.active && root.showIpAddresses && modelData.connected
                    triggeredOnStart: true
                    onTriggered: wiredIpProcess.running = true
                }

                Connections {
                    target: modelData
                    function onConnectedChanged() {
                        if (!modelData.connected)
                            wiredCard.ipAddresses = "";
                    }
                }
            }
        }

        // Wi-Fi interfaces and their visible access points
        Repeater {
            model: Networking.devices

            delegate: Rectangle {
                id: wifiCard
                required property var modelData
                property string ipAddresses: ""

                property bool active: root.showWifi && modelData.type === DeviceType.Wifi && Networking.wifiEnabled
                visible: active || opacity > 0.001
                width: root.width
                radius: root.cornerRadius
                color: root.cardColor
                implicitHeight: wifiContent.implicitHeight + 24
                height: active ? implicitHeight : 0
                opacity: active ? 1 : 0
                clip: true
                enabled: active

                Behavior on height {
                    NumberAnimation { duration: root.animationDuration; easing.type: Easing.OutCubic }
                }

                Behavior on opacity {
                    NumberAnimation { duration: root.animationDuration; easing.type: Easing.OutCubic }
                }

                Column {
                    id: wifiContent
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 8

                    Row {
                        width: parent.width
                        spacing: 8

                        Text {
                            width: parent.width - scanButton.width - 8
                            text: "Wireless networks · " + modelData.name
                            color: root.textColor
                            font.pixelSize: 14
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Rectangle {
                            id: scanButton
                            width: 58
                            height: 28
                            radius: 7
                            color: root.innerColor
                            opacity: Networking.wifiEnabled ? 1.0 : 0.4

                            Text {
                                anchors.centerIn: parent
                                text: "Scan"
                                color: root.textColor
                                font.pixelSize: 11
                            }

                            MouseArea {
                                anchors.fill: parent
                                enabled: Networking.wifiEnabled
                                onClicked: modelData.scannerEnabled = true
                            }
                        }
                    }

                    Text {
                        visible: wifiCard.active && modelData.connected
                        text: {
                            const current = modelData.networks.values.find(network => network.connected);
                            return current ? "Connected to " + current.name : "Connected";
                        }
                        color: root.accentColor
                        font.pixelSize: 12
                        elide: Text.ElideRight
                        width: parent.width
                    }

                    ListView {
                        id: wifiList
                        width: parent.width
                        height: wifiCard.active ? Math.min(Math.max(contentHeight, 40), root.networkListHeight) : 0
                        visible: true
                        clip: true

                        Behavior on height {
                            NumberAnimation { duration: root.animationDuration; easing.type: Easing.OutCubic }
                        }
                        spacing: 3
                        model: modelData.type === DeviceType.Wifi ? modelData.networks : []

                        add: Transition {
                            ParallelAnimation {
                                NumberAnimation {
                                    property: "opacity"
                                    from: 0
                                    to: 1
                                    duration: root.animationDuration
                                    easing.type: Easing.OutCubic
                                }
                                NumberAnimation {
                                    property: "x"
                                    from: 14
                                    to: 0
                                    duration: root.animationDuration
                                    easing.type: Easing.OutCubic
                                }
                            }
                        }

                        remove: Transition {
                            ParallelAnimation {
                                NumberAnimation { property: "opacity"; to: 0; duration: 140; easing.type: Easing.OutCubic }
                                NumberAnimation { property: "x"; to: -10; duration: 140; easing.type: Easing.OutCubic }
                            }
                        }

                        displaced: Transition {
                            NumberAnimation { property: "y"; duration: 180; easing.type: Easing.OutCubic }
                        }

                        delegate: Column {
                            required property var modelData
                            width: wifiList.width
                            height: implicitHeight
                            spacing: 4

                            Rectangle {
                                width: parent.width
                                height: 42
                                radius: 7
                                color: modelData.connected ? root.innerColor : "transparent"

                                Row {
                                    anchors.fill: parent
                                    anchors.leftMargin: 8
                                    anchors.rightMargin: 6
                                    spacing: 6

                                    Column {
                                        width: parent.width - connectButton.width - 6
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 1

                                        Text {
                                            width: parent.width
                                            text: modelData.name.length > 0 ? modelData.name : "Hidden network"
                                            color: root.textColor
                                            font.pixelSize: 12
                                            elide: Text.ElideRight
                                        }

                                        Text {
                                            width: parent.width
                                            text: WifiSecurityType.toString(modelData.security) + " · " + Math.round(modelData.signalStrength * 100) + "%" + (modelData.known ? " · Saved" : "")
                                            color: root.mutedTextColor
                                            font.pixelSize: 10
                                            elide: Text.ElideRight
                                        }
                                    }

                                    Rectangle {
                                        id: connectButton
                                        width: 76
                                        height: 28
                                        radius: 7
                                        color: modelData.connected ? root.dangerColor : root.accentColor
                                        opacity: modelData.stateChanging ? 0.45 : 1.0
                                        anchors.verticalCenter: parent.verticalCenter

                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.connected ? "Disconnect" : (modelData.stateChanging ? "Working…" : "Connect")
                                            color: modelData.connected ? "#27151b" : "#171925"
                                            font.pixelSize: 10
                                            font.weight: Font.DemiBold
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            enabled: !modelData.stateChanging
                                            onClicked: root.connectToNetwork(modelData)
                                        }
                                    }
                                }
                            }

                            WifiPasswordPrompt {
                                width: parent.width
                                network: modelData
                            }
                        }

                        Text {
                            anchors.fill: parent
                            visible: wifiList.count === 0
                            text: modelData.scannerEnabled ? "Looking for networks…" : "No networks found"
                            color: root.mutedTextColor
                            font.pixelSize: 11
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Text {
                        visible: root.showIpAddresses && modelData.connected
                        text: wifiCard.ipAddresses
                        color: root.mutedTextColor
                        font.pixelSize: 11
                        lineHeight: 1.25
                    }

                    Row {
                        visible: modelData.connected
                        width: parent.width
                        height: 28

                        Item {
                            width: Math.max(0, parent.width - wifiAdvancedButton.width - 8)
                            height: 1
                        }

                        Rectangle {
                            id: wifiAdvancedButton
                            width: root.configOpen && root.configDeviceName === modelData.name ? 64 : 78
                            height: 28
                            radius: 7
                            color: root.configOpen && root.configDeviceName === modelData.name ? root.accentColor : root.innerColor

                            Text {
                                anchors.centerIn: parent
                                text: root.configOpen && root.configDeviceName === modelData.name ? "Close" : "Advanced"
                                color: root.configOpen && root.configDeviceName === modelData.name ? "#171925" : root.textColor
                                font.pixelSize: 11
                            }

                            MouseArea {
                                anchors.fill: parent
                                enabled: modelData.connected
                                onClicked: root.toggleAdvanced(modelData)
                            }
                        }
                    }

                    AdvancedEditor {
                        width: parent.width
                        deviceName: modelData.name
                    }
                }

                Process {
                    id: wifiIpProcess
                    command: ["ip", "-o", "addr", "show", "dev", modelData.name]
                    stdout: StdioCollector {
                        onStreamFinished: wifiCard.ipAddresses = root.parseIpAddresses(this.text)
                    }
                }

                Timer {
                    interval: 5000
                    repeat: true
                    running: wifiCard.active && root.showIpAddresses && modelData.connected
                    triggeredOnStart: true
                    onTriggered: wifiIpProcess.running = true
                }

                Connections {
                    target: modelData
                    function onConnectedChanged() {
                        if (!modelData.connected)
                            wifiCard.ipAddresses = "";
                    }
                }
            }
        }

        Text {
            visible: root.statusMessage.length > 0 || opacity > 0.001
            text: root.statusMessage
            color: root.statusMessage.startsWith("Ethernet connected") || root.statusMessage.startsWith("Connecting Ethernet") ? root.accentColor : root.dangerColor
            font.pixelSize: 11
            width: root.width
            height: root.statusMessage.length > 0 ? implicitHeight : 0
            opacity: root.statusMessage.length > 0 ? 1 : 0
            clip: true
            wrapMode: Text.WordWrap

            Behavior on height {
                NumberAnimation { duration: root.animationDuration; easing.type: Easing.OutCubic }
            }

            Behavior on opacity {
                NumberAnimation { duration: root.animationDuration; easing.type: Easing.OutCubic }
            }
        }
    }
}

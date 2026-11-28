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
                        nmcliRescanWifi.running = true;
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
                        color: Matugen.on_surface
                    }

                    IconButton {
                        id: wifiRescanButton
                        icon: "view-refresh"
                        tooltip: "Re-scan WiFi networks"
                        enabled: wifiToggleSwitch.checked
                        onClicked: {
                            nmcliRescanWifi.running = true;
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: Matugen.primary
                    Layout.alignment: Qt.AlignHCenter
                }

                Repeater {
                    id: wifiNetworksListRoot
                    model: Networking.devices
                    property string passwordInputFor: ""

                    delegate: ColumnLayout {
                        required property var modelData
                        readonly property var wifiDevice: modelData

                        Layout.fillWidth: true
                        visible: wifiDevice.type === DeviceType.Wifi
                        spacing: controls.spacing

                        Repeater {
                            id: wifiNetworksList

                            model: wifiDevice.type === DeviceType.Wifi
                                   ? wifiDevice.networks
                                   : null

                            delegate: HoverArea {
                                id: wifiNetworksListRowArea
                                required property var modelData

                                Layout.fillWidth: true
                                implicitHeight: wifiNetworksListRow.implicitHeight + 2 * controls.spacing
                                hoverColor: Matugen.primary_a

                                ColumnLayout {
                                    id: wifiNetworksListRow
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width

                                    RowLayout {
                                        id: wifiNetworksListRowNoPassword

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
                                                text: modelData.name.length > 0
                                                      ? modelData.name
                                                      : "Hidden network"
                                                color: Matugen.on_surface
                                                font.pixelSize: 12
                                                elide: Text.ElideRight
                                            }

                                            Text {
                                                Layout.fillWidth: true
                                                text: WifiSecurityType.toString(modelData.security)
                                                      + " · " + Math.round(modelData.signalStrength * 100) + "%"
                                                      + (modelData.known ? " · Saved" : "")
                                                      + (modelData.connected ? " · Connected" : "")
                                                color: Matugen.on_surface_variant
                                                font.pixelSize: 10
                                                elide: Text.ElideRight
                                            }
                                        }
                                    }

                                    Rectangle {
                                        width: parent.width
                                        implicitHeight: wifiNetworksListRoot.passwordInputFor == modelData.name
                                                        ? wifiPasswordRow.implicitHeight
                                                        : 0
                                        color: "transparent"
                                        clip: true

                                        RowLayout {
                                            id: wifiPasswordRow
                                            property bool showingPassword
                                            width: parent.width

                                            IconButton {
                                                id: wifiPasswordRowSeeIcon
                                                icon: wifiPasswordRow.showingPassword
                                                      ? "password-show-off"
                                                      : "password-show-on"
                                                iconSize: 16
                                            }

                                            /*Item {
                                                width: parent.width - 2 * (wifiPasswordRowSeeIcon.width)
                                                Layout.preferredHeight: 16
                                                InputBox {}
                                            }*/
                                        }

                                        Behavior on implicitHeight {
                                            NumberAnimation {
                                                duration: Globals.animationTime
                                                easing.type: Easing.InOutCubic
                                            }
                                        }
                                    }
                                }

                                onClicked: {
                                    if (wifiNetworksListRoot.passwordInputFor == modelData.name) {
                                        wifiNetworksListRoot.passwordInputFor = "";
                                        return;
                                    }

                                    if (modelData.security != 0)
                                        wifiNetworksListRoot.passwordInputFor = modelData.name;
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
                    //root.nmcliConnectionsListTemp = null;
                }
            }
        }
    }
    Process {
        id: nmcliRescanWifi
        running: false
        command: ["nmcli", "device", "wifi", "rescan"]
    }
}

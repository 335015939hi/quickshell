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
                required property var modelData
                implicitWidth: parent.width
                implicitHeight: nmcliConnectionsViewRow.implicitHeight + 2 * controls.spacing
                RowLayout {
                    id: nmcliConnectionsViewRow
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    Image {
                        id: nmcliConnectionsItemIcon
                        Layout.alignment: Qt.AlignLeft
                        source: Quickshell.iconPath(modelData.icon)
                        sourceSize: Qt.size(24, 24)
                        width: 24
                        height: 24
                        fillMode: Image.PreserveAspectFit
                    }
                    Text {
                        anchors.left: nmcliConnectionsItemIcon.right
                        Layout.alignment: Qt.AlignLeft
                        text: modelData["connection.id"]
                        color: Matugen.on_surface
                    }
                    IconButton {
                        Layout.alignment: Qt.AlignRight
                        icon: modelData.activated ? "network-disconnect" : "network-connect"
                        hoverColor: Matugen.primary_a
                        tooltip: modelData.activated ? "Disconnect" : "Connect"
                    }
                    IconButton {
                        Layout.alignment: Qt.AlignRight
                        icon: "overflow-menu"
                        hoverColor: Matugen.primary_a
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
                console.log(root.nmcliConnectionsListTemp[nmcliGetConnectionDetails.index]);

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
        stderr: StdioCollector {
            onStreamFinished: {
                console.log(text);
            }
        }
    }
}

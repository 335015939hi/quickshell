pragma Singleton

import Quickshell
import QtQuick
import Quickshell.Networking
import Quickshell.Io

Singleton {
    id: root

    property date currentTime: new Date()

    Timer {
        interval: 1000
        repeat: true
        running: true
        triggeredOnStart: true

        onTriggered: currentTime = new Date()
    }

    property int animationTime: 250

    readonly property string networkIcon: {
        const devices = Networking.devices.values;

        const wired = devices.find(d => d.type === DeviceType.Wired && d.connected);

        if (wired)
            return "network-wired-activated-symbolic";

        const wifi = devices.find(d => d.type === DeviceType.Wifi && d.connected);

        if (wifi) {
            const network = wifi.networks.values.find(n => n.connected);
            const strength = network ? network.signalStrength : 1;

            if (strength >= 0.75)
                return "network-wireless-connected-100-symbolic";
            if (strength >= 0.50)
                return "network-wireless-connected-75-symbolic";
            if (strength >= 0.25)
                return "network-wireless-connected-50-symbolic";

            return "network-wireless-connected-25-symbolic";
        }

        return "network-wireless-disconnected-symbolic";
    }

    readonly property string networkName: {
        const device = Networking.devices.values.find(d => d.connected);
        if (!device)
            return "Disconnected";
        if (device.type === DeviceType.Wifi) {
            const network = device.networks.values.find(n => n.connected);
            if (network)
                return network.name;
        }
        return device.name;
    }

    readonly property var activeNetworkDevice: Networking.devices.values.find(d => d.connected) ?? null

    property string ipv4: "—"
    property string ipv6: "—"
    property bool ipRefreshPending: false

    function ipRefreshAddress() {
        // Queue another refresh if one is already running.
        if (ipAddressProc.running) {
            ipRefreshPending = true;
            return;
        }
        if (!activeNetworkDevice) {
            ipv4 = "—";
            ipv6 = "—";
            return;
        }
        ipRefreshPending = false;
        ipAddressProc.command = ["ip", "-o", "addr", "show", "scope", "global", "dev", activeNetworkDevice.name];
        ipAddressProc.running = true;
    }

    // Refresh whenever the active device changes.
    onActiveNetworkDeviceChanged: ipRefreshAddress()

    // Fetch both IPv4 and IPv6 addresses.
    Process {
        id: ipAddressProc

        command: []

        stdout: StdioCollector {
            onStreamFinished: {
                const ipv4Match = text.match(/\binet\s+([^/\s]+)/);
                const ipv6Match = text.match(/\binet6\s+([^/\s]+)/);
                root.ipv4 = ipv4Match ? ipv4Match[1] : "—";
                root.ipv6 = ipv6Match ? ipv6Match[1] : "—";
            }
        }
        onExited: {
            if (root.ipRefreshPending) {
                root.ipRefreshPending = false;
                root.ipRefreshAddress();
            }
        }
    }

    // Listen for address changes.
    Process {
        id: ipAddressMonitor

        command: ["ip", "monitor", "address"]
        running: true

        // Take the initial snapshot after the monitor process starts.
        onStarted: root.ipRefreshAddress()

        stdout: SplitParser {
            onRead: data => root.ipRefreshAddress()
        }
    }
}

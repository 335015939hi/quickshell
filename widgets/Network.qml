import Quickshell
import QtQuick
import qs
import Quickshell.Networking

IconButton {
    icon: Globals.networkIcon
    text: Globals.networkName
    textColor: Matugen.on_surface
    tooltip: {
        const network = Networking.devices.values;
        if (!network) {
            return "No network connected";
        }
        var result = "";
        var device = network.find(d => d.connected);
        if (device) {
            result += "Interface: " + device.name + "\n";
        }
        result += Globals.ipv4 + "\n";
        result += Globals.ipv6 + "\n";
        return result.trim();
    }
}

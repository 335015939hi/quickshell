// Battery.qml
// Bar widget for the laptop battery. Hidden entirely on machines without
// a primary battery (e.g. desktops) — `UPower.displayDevice.isPresent`
// is `false` when no battery hardware is attached, and the widget
// collapses to width 0 in that case.
//
// Visual: 5-tier Font Awesome battery glyph + percentage. A small bolt
// overlay marks the charging state. Tooltip shows time-to-full /
// time-to-empty in human-readable form.

import QtQuick
import Quickshell
import Quickshell.Services.UPower
import qs

IconButton {
    id: root

    property bool showText: true

    readonly property var dev: UPower.displayDevice
    readonly property bool _present: dev && dev.ready && dev.isPresent && dev.type === UPowerDeviceType.Battery
    // `dev.percentage` is a 0.0–1.0 fraction (energy / energyCapacity),
    // not a 0–100 number — scale it once so all thresholds and the
    // displayed integer below read naturally.
    readonly property bool _charging: _present && (dev.state === UPowerDeviceState.Charging || dev.state === UPowerDeviceState.FullyCharged)

    visible: _present

    function icon() {
        var percent = Math.floor(dev.percentage * 10) * 10;
        var icon = "battery-0" + percent;
        icon += UPowerDeviceState.Charging ? "-charging" : "";
        icon += "-symbolic.svg";
        return icon;
    }
    function batteryText(dispCharge) {
        var text = Math.floor(dev.percentage * 100);
        text += UPowerDeviceState.Charging && dispCharge ? "% (Charging)" : "%";
        return text;
    }
    icon: icon()

    text: showText ? batteryText(false) : ""
    textColor: Matugen.on_surface

    BarTooltip {
        //anchorItem: root
        text: batteryText(true)

        //show: root.containsMouse
    }
}

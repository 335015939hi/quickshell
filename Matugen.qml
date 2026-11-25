pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var palette: ({})

    function loadColors() {
        const content = colorFile.text();
        if (!content)
            return;
        try {
            const parsed = JSON.parse(content);

            if (parsed === null || typeof parsed !== "object" || Array.isArray(parsed)) {
                console.warn("Invalid Matugen color file");
                return;
            }

            palette = parsed;
        } catch (error) {
            console.warn("Failed to parse Matugen colors:", error);
        }
    }

    // Material colors

    readonly property color background: palette.background || "#10140F"

    readonly property color error: palette.error || "#FFB4AB"
    readonly property color error_container: palette.error_container || "#A7060F"

    readonly property color inverse_on_surface: palette.inverse_on_surface || "#2D322C"
    readonly property color inverse_primary: palette.inverse_primary || "#39693B"
    readonly property color inverse_surface: palette.inverse_surface || "#E0E4DB"

    readonly property color on_background: palette.on_background || "#E0E4DB"
    readonly property color on_error: palette.on_error || "#660004"
    readonly property color on_error_container: palette.on_error_container || "#FFFFFF"

    readonly property color on_primary: palette.on_primary || "#04370F"
    readonly property color on_primary_container: palette.on_primary_container || "#FFFFFF"
    readonly property color on_primary_fixed: palette.on_primary_fixed || "#002106"
    readonly property color on_primary_fixed_variant: palette.on_primary_fixed_variant || "#215026"

    readonly property color on_secondary: palette.on_secondary || "#233322"
    readonly property color on_secondary_container: palette.on_secondary_container || "#FFFFFF"
    readonly property color on_secondary_fixed: palette.on_secondary_fixed || "#101F10"
    readonly property color on_secondary_fixed_variant: palette.on_secondary_fixed_variant || "#3B4B39"

    readonly property color on_surface: palette.on_surface || "#E0E4DB"
    readonly property color on_surface_variant: palette.on_surface_variant || "#C2C9BD"

    readonly property color on_tertiary: palette.on_tertiary || "#00353A"
    readonly property color on_tertiary_container: palette.on_tertiary_container || "#FFFFFF"
    readonly property color on_tertiary_fixed: palette.on_tertiary_fixed || "#001F23"
    readonly property color on_tertiary_fixed_variant: palette.on_tertiary_fixed_variant || "#1F4D53"

    readonly property color outline: palette.outline || "#8C9388"
    readonly property color outline_variant: palette.outline_variant || "#4D544B"

    readonly property color primary: palette.primary || "#9FD49C"
    readonly property color primary_container: palette.primary_container || "#2C5C30"
    readonly property color primary_fixed: palette.primary_fixed || "#BAF0B6"
    readonly property color primary_fixed_dim: palette.primary_fixed_dim || "#9FD49C"

    readonly property color scrim: palette.scrim || "#000000"

    readonly property color secondary: palette.secondary || "#B9CCB4"
    readonly property color secondary_container: palette.secondary_container || "#455644"
    readonly property color secondary_fixed: palette.secondary_fixed || "#D5E8CF"
    readonly property color secondary_fixed_dim: palette.secondary_fixed_dim || "#B9CCB4"

    readonly property color shadow: palette.shadow || "#000000"
    readonly property color source_color: palette.source_color || "#1C201B"

    readonly property color surface: palette.surface || "#10140F"
    readonly property color surface_bright: palette.surface_bright || "#383D37"
    readonly property color surface_container: palette.surface_container || "#1E221D"
    readonly property color surface_container_high: palette.surface_container_high || "#282D27"
    readonly property color surface_container_highest: palette.surface_container_highest || "#333832"
    readonly property color surface_container_low: palette.surface_container_low || "#191D18"
    readonly property color surface_container_lowest: palette.surface_container_lowest || "#0A0E09"
    readonly property color surface_dim: palette.surface_dim || "#10140F"
    readonly property color surface_tint: palette.surface_tint || "#9FD49C"
    readonly property color surface_variant: palette.surface_variant || "#424940"

    readonly property color tertiary: palette.tertiary || "#A1CED5"
    readonly property color tertiary_container: palette.tertiary_container || "#2B585E"
    readonly property color tertiary_fixed: palette.tertiary_fixed || "#BCEBF1"
    readonly property color tertiary_fixed_dim: palette.tertiary_fixed_dim || "#A1CED5"

    // Base16 colors

    readonly property color base00: palette.base00 || "#141E25"
    readonly property color base01: palette.base01 || "#2F373C"
    readonly property color base02: palette.base02 || "#4A5053"
    readonly property color base03: palette.base03 || "#65686A"
    readonly property color base04: palette.base04 || "#7F8181"
    readonly property color base05: palette.base05 || "#9A9998"
    readonly property color base06: palette.base06 || "#B5B2AF"
    readonly property color base07: palette.base07 || "#D0CAC7"
    readonly property color base08: palette.base08 || "#B6B5B4"
    readonly property color base09: palette.base09 || "#525657"
    readonly property color base0a: palette.base0a || "#A9ADB1"
    readonly property color base0b: palette.base0b || "#A49F9B"
    readonly property color base0c: palette.base0c || "#BDC0C6"
    readonly property color base0d: palette.base0d || "#C5BFBB"
    readonly property color base0e: palette.base0e || "#D0CAC6"
    readonly property color base0f: palette.base0f || "#AFB6BF"

    // Alpha variants

    readonly property color background_a: palette.background_a || "#8010140F"

    readonly property color error_a: palette.error_a || "#80FFB4AB"
    readonly property color error_container_a: palette.error_container_a || "#80A7060F"

    readonly property color inverse_on_surface_a: palette.inverse_on_surface_a || "#802D322C"
    readonly property color inverse_primary_a: palette.inverse_primary_a || "#8039693B"
    readonly property color inverse_surface_a: palette.inverse_surface_a || "#80E0E4DB"

    readonly property color on_background_a: palette.on_background_a || "#80E0E4DB"
    readonly property color on_error_a: palette.on_error_a || "#80660004"
    readonly property color on_error_container_a: palette.on_error_container_a || "#80FFFFFF"

    readonly property color on_primary_a: palette.on_primary_a || "#8004370F"
    readonly property color on_primary_container_a: palette.on_primary_container_a || "#80FFFFFF"
    readonly property color on_primary_fixed_a: palette.on_primary_fixed_a || "#80002106"
    readonly property color on_primary_fixed_variant_a: palette.on_primary_fixed_variant_a || "#80215026"

    readonly property color on_secondary_a: palette.on_secondary_a || "#80233322"
    readonly property color on_secondary_container_a: palette.on_secondary_container_a || "#80FFFFFF"
    readonly property color on_secondary_fixed_a: palette.on_secondary_fixed_a || "#80101F10"
    readonly property color on_secondary_fixed_variant_a: palette.on_secondary_fixed_variant_a || "#803B4B39"

    readonly property color on_surface_a: palette.on_surface_a || "#80E0E4DB"
    readonly property color on_surface_variant_a: palette.on_surface_variant_a || "#80C2C9BD"

    readonly property color on_tertiary_a: palette.on_tertiary_a || "#8000353A"
    readonly property color on_tertiary_container_a: palette.on_tertiary_container_a || "#80FFFFFF"
    readonly property color on_tertiary_fixed_a: palette.on_tertiary_fixed_a || "#80001F23"
    readonly property color on_tertiary_fixed_variant_a: palette.on_tertiary_fixed_variant_a || "#801F4D53"

    readonly property color outline_a: palette.outline_a || "#808C9388"
    readonly property color outline_variant_a: palette.outline_variant_a || "#804D544B"

    readonly property color primary_a: palette.primary_a || "#809FD49C"
    readonly property color primary_container_a: palette.primary_container_a || "#802C5C30"
    readonly property color primary_fixed_a: palette.primary_fixed_a || "#80BAF0B6"
    readonly property color primary_fixed_dim_a: palette.primary_fixed_dim_a || "#809FD49C"

    readonly property color scrim_a: palette.scrim_a || "#80000000"

    readonly property color secondary_a: palette.secondary_a || "#80B9CCB4"
    readonly property color secondary_container_a: palette.secondary_container_a || "#80455644"
    readonly property color secondary_fixed_a: palette.secondary_fixed_a || "#80D5E8CF"
    readonly property color secondary_fixed_dim_a: palette.secondary_fixed_dim_a || "#80B9CCB4"

    readonly property color shadow_a: palette.shadow_a || "#80000000"
    readonly property color source_color_a: palette.source_color_a || "#801C201B"

    readonly property color surface_a: palette.surface_a || "#8010140F"
    readonly property color surface_bright_a: palette.surface_bright_a || "#80383D37"
    readonly property color surface_container_a: palette.surface_container_a || "#801E221D"
    readonly property color surface_container_high_a: palette.surface_container_high_a || "#80282D27"
    readonly property color surface_container_highest_a: palette.surface_container_highest_a || "#80333832"
    readonly property color surface_container_low_a: palette.surface_container_low_a || "#80191D18"
    readonly property color surface_container_lowest_a: palette.surface_container_lowest_a || "#800A0E09"
    readonly property color surface_dim_a: palette.surface_dim_a || "#8010140F"
    readonly property color surface_tint_a: palette.surface_tint_a || "#809FD49C"
    readonly property color surface_variant_a: palette.surface_variant_a || "#80424940"

    readonly property color tertiary_a: palette.tertiary_a || "#80A1CED5"
    readonly property color tertiary_container_a: palette.tertiary_container_a || "#802B585E"
    readonly property color tertiary_fixed_a: palette.tertiary_fixed_a || "#80BCEBF1"
    readonly property color tertiary_fixed_dim_a: palette.tertiary_fixed_dim_a || "#80A1CED5"

    // Base16 alpha variants

    readonly property color base00_a: palette.base00_a || "#80141E25"
    readonly property color base01_a: palette.base01_a || "#802F373C"
    readonly property color base02_a: palette.base02_a || "#804A5053"
    readonly property color base03_a: palette.base03_a || "#8065686A"
    readonly property color base04_a: palette.base04_a || "#807F8181"
    readonly property color base05_a: palette.base05_a || "#809A9998"
    readonly property color base06_a: palette.base06_a || "#80B5B2AF"
    readonly property color base07_a: palette.base07_a || "#80D0CAC7"
    readonly property color base08_a: palette.base08_a || "#80B6B5B4"
    readonly property color base09_a: palette.base09_a || "#80525657"
    readonly property color base0a_a: palette.base0a_a || "#80A9ADB1"
    readonly property color base0b_a: palette.base0b_a || "#80A49F9B"
    readonly property color base0c_a: palette.base0c_a || "#80BDC0C6"
    readonly property color base0d_a: palette.base0d_a || "#80C5BFBB"
    readonly property color base0e_a: palette.base0e_a || "#80D0CAC6"
    readonly property color base0f_a: palette.base0f_a || "#80AFB6BF"

    FileView {
        id: colorFile

        path: Quickshell.env("HOME") + "/.config/matugen/quickshell-colors.json"

        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.loadColors()
    }
}

import Quickshell
import QtQuick
import qs

Item {
    Clock {}
    IconButton {
        icon: "start-here-symbolic"
        iconSize: 80
        command: "qs ipc call applauncher toggle"
    }
}

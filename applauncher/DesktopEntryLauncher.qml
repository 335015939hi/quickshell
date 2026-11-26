import QtQuick
import Quickshell.Io
import Quickshell

// Launch by Quickshell's desktop-entry ID. gtk-launch resolves the ID using
// GDesktopAppInfo and handles desktop-entry execution details such as Exec
// field codes, Terminal=true, startup notification and D-Bus activation.
// Do not build a second desktop-file index here: DesktopEntries already owns
// the application model and its filesystem monitor.
Item {
    id: root

    property string pendingApplicationName: ""
    property string lastError: ""
    readonly property bool running: launchProcess.running

    signal launchFailed(string applicationName, string reason)

    function launch(entry) {
        if (!entry) {
            launchFailed("", "No application was selected.");
            return false;
        }
        if (launchProcess.running) {
            launchFailed(entry.name, "Another application launch is already in progress.");
            return false;
        }
        pendingApplicationName = entry.name;
        lastError = "";
        launchProcess.command = ["gtk-launch", entry.id];
        launchProcess.startDetached();
        return true;
    }

    Process {
        id: launchProcess
        command: []
        running: false
    }
}

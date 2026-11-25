import QtQuick
import Quickshell.Io

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

    signal launchSucceeded()
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
        launchProcess.running = true;
        return true;
    }

    Process {
        id: launchProcess

        command: []
        running: false

        stderr: StdioCollector {
            onStreamFinished: root.lastError = text.trim()
        }

        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) {
                root.launchSucceeded();
            } else {
                const reason = root.lastError.length > 0
                    ? root.lastError
                    : "gtk-launch exited with status " + exitCode
                        + ". Ensure gtk-launch is installed.";

                root.launchFailed(root.pendingApplicationName, reason);
            }

            root.pendingApplicationName = "";
        }
    }
}

import Quickshell
import QtQuick
import Quickshell.Io

QtObject {
    id: root

    readonly property var applicationDirectories: {
        const directories = [];
        let dataHome = Quickshell.env("XDG_DATA_HOME");
        if (!dataHome) {
            const home = Quickshell.env("HOME");
            if (home) dataHome = home + "/.local/share";
        }
        if (dataHome) directories.push(dataHome + "/applications");
        const dataDirs = Quickshell.env("XDG_DATA_DIRS") || "/usr/local/share:/usr/share";
        for (const directory of dataDirs.split(":")) {
            if (directory.length > 0) directories.push(directory.replace(/\/+$/, "") + "/applications");
        }
        return directories.reverse();
    }

    readonly property var findCommand: ["find", ...applicationDirectories, "-type", "f", "-name", "*.desktop", "-print"]
    property var desktopFilesById: ({})
    property bool ready: false
    property bool refreshQueued: false
    property string pendingApplicationName: ""
    property string launchError: ""
    signal launchFailed(string applicationName, string reason)

    function refreshIndex() {
        if (indexProcess.running) { refreshQueued = true; return; }
        ready = false;
        indexProcess.command = findCommand;
        indexProcess.running = true;
    }

    function updateIndex(output) {
        const next = ({});
        for (const filePath of output.split("\n").filter(path => path.length > 0)) {
            for (const directory of applicationDirectories) {
                const prefix = directory.replace(/\/+$/, "") + "/";
                if (!filePath.startsWith(prefix)) continue;
                let id = filePath.slice(prefix.length).replace(/\//g, "-");
                if (!id.endsWith(".desktop")) break;
                next[id.slice(0, -8)] = filePath;
                break;
            }
        }
        desktopFilesById = next;
        ready = true;
    }

    function launch(entry) {
        if (!entry) return false;
        if (!ready) { launchFailed(entry.name, "Desktop-entry index is still loading."); return false; }
        const desktopFile = desktopFilesById[entry.id];
        if (!desktopFile) { launchFailed(entry.name, "Could not resolve desktop file ID '" + entry.id + "'."); return false; }
        if (launchProcess.running) { launchFailed(entry.name, "Another launch is in progress."); return false; }
        pendingApplicationName = entry.name;
        launchError = "";
        launchProcess.command = ["gio", "launch", desktopFile];
        launchProcess.running = true;
        return true;
    }

    Process {
        id: indexProcess
        command: []
        stdout: StdioCollector { onStreamFinished: root.updateIndex(text) }
        stderr: SplitParser { onRead: data => console.warn("App launcher index:", data) }
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) console.warn("Desktop-file scan exited with status", exitCode);
            if (root.refreshQueued) { root.refreshQueued = false; Qt.callLater(() => root.refreshIndex()); }
        }
    }

    Process {
        id: launchProcess
        command: []
        stderr: StdioCollector { onStreamFinished: root.launchError = text.trim() }
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) root.launchFailed(root.pendingApplicationName,
                root.launchError.length > 0 ? root.launchError : "gio launch exited with status " + exitCode + ".");
            root.pendingApplicationName = "";
        }
    }

    Connections {
        target: DesktopEntries
        function onApplicationsChanged() { root.refreshIndex(); }
    }

    Component.onCompleted: refreshIndex()
}

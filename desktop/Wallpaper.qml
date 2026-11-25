import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs

// Per-monitor wallpaper renderer. Add `Wallpaper { id: wallpaper }` under
// your ShellRoot. The public API is wallpaper.setWallpaper(screenName, path).
Scope {
    id: root

    // ---------------------------------------------------------------------
    // Configuration
    // ---------------------------------------------------------------------

    property int transitionDuration: Globals.animationTime * 4

    // Shell command executed through `sh -c` on every wallpaper change.
    // It can use these variables:
    //   $MONITOR    monitor name, e.g. "DP-1"
    //   $WALLPAPER  absolute wallpaper path
    //   $TRANSITION selected transition, or "startup" / "initial"
    // The values are passed as positional arguments, not interpolated into
    // shell source, so spaces and shell metacharacters in paths are safe.
    // Example: `notify-send "Wallpaper" "$WALLPAPER on $MONITOR ($TRANSITION)"`
    property string changeCommand: "#matugen image \"$WALLPAPER\""

    // Restored wallpapers also trigger the command at startup.
    property bool runCommandOnStartup: true

    // Used only when a monitor has no saved wallpaper. Empty means black.
    property string defaultWallpaper: ""

    // Every non-startup wallpaper change chooses one of these at random.
    property var transitionStyles: ["fade", "zoom-in", "zoom-out", "slide-left", "slide-right", "slide-up", "slide-down"]

    // ---------------------------------------------------------------------
    // Persistent per-monitor state
    // ---------------------------------------------------------------------

    property var wallpapersByMonitor: ({})
    property bool stateLoaded: false

    FileView {
        id: stateFile
        path: Quickshell.statePath("wallpapers.json")
        blockLoading: true
        printErrors: false
    }

    function ensureStateLoaded() {
        if (stateLoaded)
            return;

        // blockLoading makes this first read wait for the small state file.
        stateLoaded = true;
        try {
            const contents = stateFile.text().trim();
            if (contents.length === 0) {
                wallpapersByMonitor = ({});
                return;
            }

            const parsed = JSON.parse(contents);
            if (parsed && typeof parsed === "object" && !Array.isArray(parsed))
                wallpapersByMonitor = parsed;
        } catch (error) {
            console.warn("Wallpaper: could not read saved wallpaper state:", error);
            wallpapersByMonitor = ({});
        }
    }

    function rememberWallpaper(monitorName, path) {
        ensureStateLoaded();

        const updated = Object.assign({}, wallpapersByMonitor);
        updated[monitorName] = path;
        wallpapersByMonitor = updated;
        stateFile.setText(JSON.stringify(updated, null, 2) + "\n");
    }

    // ---------------------------------------------------------------------
    // Path and command helpers
    // ---------------------------------------------------------------------

    function normalizePath(path) {
        let value = String(path ?? "").trim();
        if (value === "")
            return "";

        const home = Quickshell.env("HOME") || "";
        if (value === "~")
            value = home;
        else if (value.startsWith("~/"))
            value = home + value.slice(1);

        if (!value.startsWith("/")) {
            console.warn("Wallpaper: expected an absolute path or ~/ path, got:", value);
            return "";
        }

        return value;
    }

    function imageUrl(path) {
        // Encode each path segment, not the slashes. This handles spaces,
        // #, ?, and non-ASCII characters in filenames correctly.
        return "file://" + path.split("/").map(segment => encodeURIComponent(segment)).join("/");
    }

    function runChangeCommand(monitorName, path, transitionName) {
        const command = changeCommand.trim();
        if (command === "")
            return;

        // sh -c treats its first argument after the command string as $0.
        // The following arguments become $1, $2 and $3. Assign them to
        // descriptive shell variables before executing the configured command.
        const shellCommand = ['export MONITOR="$1" WALLPAPER="$2" TRANSITION="$3"', command].join("\n");

        Quickshell.execDetached(["sh", "-c", shellCommand, "qs-wallpaper-hook", monitorName, path, transitionName]);
    }

    function pickTransition(previous) {
        const choices = transitionStyles.length > 0 ? transitionStyles : ["fade"];
        let available = choices;

        if (choices.length > 1)
            available = choices.filter(style => style !== previous);

        return available[Math.floor(Math.random() * available.length)];
    }

    // ---------------------------------------------------------------------
    // Public API
    // ---------------------------------------------------------------------

    // Change one monitor. `monitorName` is normally e.g. "DP-1" or "eDP-1".
    // Returns false if the monitor is not currently connected or path is bad.
    function setWallpaper(monitorName, path) {
        ensureStateLoaded();

        const name = String(monitorName ?? "");
        const normalized = normalizePath(path);
        if (name === "" || normalized === "")
            return false;

        const instances = monitorWindows.instances;
        for (let i = 0; i < instances.length; ++i) {
            const monitorWindow = instances[i];
            if (monitorWindow.monitorName === name)
                return monitorWindow.changeWallpaper(normalized);
        }

        console.warn("Wallpaper: monitor is not connected:", name);
        return false;
    }

    // Convenience method: set the same image on every connected monitor.
    function setAll(path) {
        ensureStateLoaded();

        const normalized = normalizePath(path);
        if (normalized === "")
            return false;

        const instances = monitorWindows.instances;
        for (let i = 0; i < instances.length; ++i)
            instances[i].changeWallpaper(normalized);

        return true;
    }

    function currentWallpaper(monitorName) {
        ensureStateLoaded();

        const name = String(monitorName ?? "");
        const instances = monitorWindows.instances;
        for (let i = 0; i < instances.length; ++i) {
            if (instances[i].monitorName === name)
                return instances[i].currentPath;
        }

        return wallpapersByMonitor[name] || "";
    }

    // Also expose the same API through `qs ipc call wallpaper ...`.
    IpcHandler {
        target: "wallpaper"

        function set(monitorName: string, path: string): bool {
            return root.setWallpaper(monitorName, path);
        }

        function setAll(path: string): bool {
            return root.setAll(path);
        }

        function current(monitorName: string): string {
            return root.currentWallpaper(monitorName);
        }
    }

    // ---------------------------------------------------------------------
    // One background layer-shell window per monitor
    // ---------------------------------------------------------------------

    Variants {
        id: monitorWindows
        model: Quickshell.screens

        PanelWindow {
            id: monitorWindow

            required property var modelData
            readonly property string monitorName: modelData.name

            screen: modelData
            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            WlrLayershell.layer: WlrLayer.Background
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
            WlrLayershell.namespace: "qs-wallpaper-" + monitorName

            focusable: false
            exclusionMode: ExclusionMode.Ignore
            color: "black"

            // The currently visible and next-to-load layers swap roles after
            // each transition. The outer Item clips slides to this monitor.
            property Item frontLayer: imageLayerA
            property Item backLayer: imageLayerB

            property string currentPath: ""
            property string pendingPath: ""
            property string initialPath: ""
            property bool initialChangeShouldPersist: false
            property string transitionPath: ""
            property string previousTransition: ""

            function imageForLayer(layer) {
                return layer === imageLayerA ? imageA : imageB;
            }

            function imageStatus(layer) {
                return imageForLayer(layer).status;
            }

            function setLayerSource(layer, path) {
                imageForLayer(layer).source = path === "" ? "" : root.imageUrl(path);
            }

            function loadInitial(path, persistAfterLoad) {
                initialPath = path;
                initialChangeShouldPersist = persistAfterLoad;
                pendingPath = "";

                frontLayer.x = 0;
                frontLayer.y = 0;
                frontLayer.scale = 1;
                frontLayer.opacity = 1;
                frontLayer.z = 1;

                backLayer.x = 0;
                backLayer.y = 0;
                backLayer.scale = 1;
                backLayer.opacity = 0;
                backLayer.z = 0;

                currentPath = path;
                setLayerSource(frontLayer, path);

                if (imageStatus(frontLayer) === Image.Ready)
                    handleImageStatus(frontLayer, Image.Ready);
            }

            function handleImageStatus(layer, status) {
                // Ignore stale status notifications if the image has already
                // moved on to another source.
                if (imageStatus(layer) !== status)
                    return;

                if (status === Image.Error) {
                    if (layer === backLayer && pendingPath !== "") {
                        console.warn("Wallpaper: failed to load", pendingPath, "on", monitorName);
                        pendingPath = "";
                    } else if (layer === frontLayer && initialPath !== "") {
                        console.warn("Wallpaper: failed to restore", initialPath, "on", monitorName);
                        initialPath = "";
                        initialChangeShouldPersist = false;
                    }
                    return;
                }

                if (status !== Image.Ready)
                    return;

                if (layer === frontLayer && initialPath !== "") {
                    const path = initialPath;
                    const shouldPersist = initialChangeShouldPersist;
                    initialPath = "";
                    initialChangeShouldPersist = false;
                    currentPath = path;

                    if (shouldPersist) {
                        root.rememberWallpaper(monitorName, path);
                        root.runChangeCommand(monitorName, path, "initial");
                    } else if (root.runCommandOnStartup) {
                        root.runChangeCommand(monitorName, path, "startup");
                    }
                    return;
                }

                if (layer === backLayer && pendingPath !== "")
                    startTransition();
            }

            function changeWallpaper(path) {
                if (path === currentPath && pendingPath === "" && transitionPath === "")
                    return true;
                if (path === pendingPath || path === transitionPath)
                    return true;

                // If the user changes wallpaper during an animation, settle
                // the in-flight transition first. This avoids animating a
                // layer whose role is about to change.
                if (transitionAnimation.running) {
                    transitionAnimation.stop();
                    finishTransition();
                }

                // While the startup image is still loading, replace it in
                // place rather than starting a transition from an empty layer.
                if (initialPath !== "") {
                    loadInitial(path, true);
                    return true;
                }

                // First wallpaper on a monitor: load directly, then persist
                // and run the command once the image has decoded successfully.
                if (currentPath === "") {
                    loadInitial(path, true);
                    return true;
                }

                pendingPath = path;
                backLayer.x = 0;
                backLayer.y = 0;
                backLayer.scale = 1;
                backLayer.opacity = 0;
                backLayer.z = 2;
                setLayerSource(backLayer, path);

                if (imageStatus(backLayer) === Image.Ready)
                    startTransition();

                return true;
            }

            function configureAnimation(animation, target, from, to) {
                animation.target = target;
                animation.from = from;
                animation.to = to;
                animation.duration = root.transitionDuration;
            }

            function startTransition() {
                if (pendingPath === "" || imageStatus(backLayer) !== Image.Ready)
                    return;

                const style = root.pickTransition(previousTransition);
                previousTransition = style;

                const outgoing = frontLayer;
                const incoming = backLayer;
                const width = scene.width;
                const height = scene.height;
                const isSlide = style.startsWith("slide-");

                let outgoingX = 0;
                let outgoingY = 0;
                let incomingX = 0;
                let incomingY = 0;

                if (style === "slide-left") {
                    outgoingX = -width;
                    incomingX = width;
                } else if (style === "slide-right") {
                    outgoingX = width;
                    incomingX = -width;
                } else if (style === "slide-up") {
                    outgoingY = -height;
                    incomingY = height;
                } else if (style === "slide-down") {
                    outgoingY = height;
                    incomingY = -height;
                }

                let outgoingScale = 1;
                let incomingScale = 1;
                if (style === "zoom-in") {
                    outgoingScale = 0.96;
                    incomingScale = 1.16;
                } else if (style === "zoom-out") {
                    outgoingScale = 1.06;
                    incomingScale = 0.84;
                }

                outgoing.z = 1;
                incoming.z = 2;

                configureAnimation(outgoingOpacity, outgoing, 1, isSlide ? 1 : 0);
                configureAnimation(incomingOpacity, incoming, isSlide ? 1 : 0, 1);
                configureAnimation(outgoingXAnimation, outgoing, 0, outgoingX);
                configureAnimation(incomingXAnimation, incoming, incomingX, 0);
                configureAnimation(outgoingYAnimation, outgoing, 0, outgoingY);
                configureAnimation(incomingYAnimation, incoming, incomingY, 0);
                configureAnimation(outgoingScaleAnimation, outgoing, 1, outgoingScale);
                configureAnimation(incomingScaleAnimation, incoming, incomingScale, 1);

                transitionPath = pendingPath;
                pendingPath = "";
                currentPath = transitionPath;

                // Persist and invoke the command once the new image is ready,
                // immediately before its transition becomes visible.
                root.rememberWallpaper(monitorName, transitionPath);
                root.runChangeCommand(monitorName, transitionPath, style);

                transitionAnimation.start();
            }

            function finishTransition() {
                if (transitionPath === "")
                    return;

                const oldFront = frontLayer;
                frontLayer = backLayer;
                backLayer = oldFront;

                frontLayer.x = 0;
                frontLayer.y = 0;
                frontLayer.scale = 1;
                frontLayer.opacity = 1;
                frontLayer.z = 1;

                backLayer.x = 0;
                backLayer.y = 0;
                backLayer.scale = 1;
                backLayer.opacity = 0;
                backLayer.z = 0;
                setLayerSource(backLayer, "");

                transitionPath = "";
            }

            Item {
                id: scene
                anchors.fill: parent
                clip: true

                Item {
                    id: imageLayerA
                    x: 0
                    y: 0
                    width: scene.width
                    height: scene.height
                    opacity: 1
                    z: 1

                    Image {
                        id: imageA
                        anchors.fill: parent
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        cache: true
                        smooth: true
                        onStatusChanged: monitorWindow.handleImageStatus(imageLayerA, status)
                    }
                }

                Item {
                    id: imageLayerB
                    x: 0
                    y: 0
                    width: scene.width
                    height: scene.height
                    opacity: 0
                    z: 0

                    Image {
                        id: imageB
                        anchors.fill: parent
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        cache: true
                        smooth: true
                        onStatusChanged: monitorWindow.handleImageStatus(imageLayerB, status)
                    }
                }
            }

            ParallelAnimation {
                id: transitionAnimation
                onFinished: monitorWindow.finishTransition()

                NumberAnimation {
                    id: outgoingOpacity
                    property: "opacity"
                    easing.type: Easing.InOutCubic
                }
                NumberAnimation {
                    id: incomingOpacity
                    property: "opacity"
                    easing.type: Easing.InOutCubic
                }
                NumberAnimation {
                    id: outgoingXAnimation
                    property: "x"
                    easing.type: Easing.InOutCubic
                }
                NumberAnimation {
                    id: incomingXAnimation
                    property: "x"
                    easing.type: Easing.InOutCubic
                }
                NumberAnimation {
                    id: outgoingYAnimation
                    property: "y"
                    easing.type: Easing.InOutCubic
                }
                NumberAnimation {
                    id: incomingYAnimation
                    property: "y"
                    easing.type: Easing.InOutCubic
                }
                NumberAnimation {
                    id: outgoingScaleAnimation
                    property: "scale"
                    easing.type: Easing.InOutCubic
                }
                NumberAnimation {
                    id: incomingScaleAnimation
                    property: "scale"
                    easing.type: Easing.InOutCubic
                }
            }

            Component.onCompleted: {
                root.ensureStateLoaded();

                const saved = root.wallpapersByMonitor[monitorName] || "";
                const fallback = root.normalizePath(root.defaultWallpaper);
                const initial = saved !== "" ? root.normalizePath(saved) : fallback;

                if (initial !== "")
                    loadInitial(initial, false);
            }
        }
    }
}

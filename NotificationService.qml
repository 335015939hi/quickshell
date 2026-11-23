import Quickshell.Services.Notifications

NotificationServer {
    // These are the capabilities implemented by the popup UI.
    actionsSupported: true
    bodyMarkupSupported: true
    imageSupported: true

    // This shell has transient popups, not a persistent notification center.
    keepOnReload: false
    persistenceSupported: false

    onNotification: notification => {
        notification.tracked = true;

        console.log(notification.appName, notification.summary, notification.body);
    }
}

import Nemo.Notifications 1.0

Notification {
    property var task
    property var dueDate: (task.due ? Date.fromLocaleString(Qt.locale(), task.due, "yyyy-MM-dd") : new Date())
    //onDueDateChanged: dueDate.toLocaleDateString(Qt.locale())

    appName: "ZuTun.txt"
    appIcon: "harbour-zutun"
    //category: "x-nemo.general.reminder" //??
    summary: task.subject
    body: dueDate ? dueDate.toLocaleDateString(Qt.locale()) : ""
    timestamp: dueDate



    remoteActions: [{
            "name": "default",
            "displayName": "Call ZuTun.txt",
            "icon": "icon-m-certificates",
            "service": "info.fuxl.zutuntxt",
            "path": "/info/fuxl/zutuntxt",
            "iface": "info.fuxl.zutuntxt",
            "method": "notificationClosed"
        },{
            "name": "app",
            "displayName": "Call ZuTun.txt",
            "icon": "icon-m-certificates",
            "service": "info.fuxl.zutuntxt",
            "path": "/info/fuxl/zutuntxt",
            "iface": "info.fuxl.zutuntxt",
            "method": "notificationClosed",
        }
    ]

    onClosed: console.log(reason)
}

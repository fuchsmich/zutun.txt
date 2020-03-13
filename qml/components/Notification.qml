import Nemo.Notifications 1.0

Notification {
    property var task
    property var dueDate: (task.due ? Date.fromLocaleString(Qt.locale(), task.due, "yyyy-MM-dd") : new Date())
    //onDueDateChanged: dueDate.toLocaleDateString(Qt.locale())

    appName: "ZuTun.txt"
    appIcon: "harbour-zutun"
    body: task.fullTxt //task.formattedSubject
    timestamp: dueDate
    summary: dueDate.toLocaleDateString(Qt.locale()) //task.due


    remoteActions: [{
            "name": "default",
            "displayName": "Call ZuTun.txt",
            "icon": "icon-m-certificates",
            "service": "info.fuxl.zutuntxt",
            "path": "/info/fuxl/zutuntxt",
            "iface": "info.fuxl.zutuntxt",
            "method": "showApp"
        },{
            "name": "app",
            "displayName": "Call ZuTun.txt",
            "icon": "icon-m-certificates",
            "service": "info.fuxl.zutuntxt",
            "path": "/info/fuxl/zutuntxt",
            "iface": "info.fuxl.zutuntxt",
            "method": "showApp"
        }
    ]

    onClosed: console.log(reason)

}

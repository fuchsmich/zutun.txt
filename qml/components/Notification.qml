import Nemo.Notifications 1.0

Notification {
    appName: "ZuTun.txt"
    appIcon: "harbour-zutun"
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

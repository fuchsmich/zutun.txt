import QtQuick 2.0

import "../tdt/todotxt.js" as JS

QtObject {
    id: notificationList
    property var replaceIDs
    property var taskList: ListModel {}

    function filterTask(task) {
        if (!notificationSettings.showNotifications) return false

        if (task.done === true) return false

        if (task.due === "") return false

        //console.log(task.due)
        var today = new Date()
        var limit = new Date()
        switch (notificationSettings.dueLimit) {
        case 0:
            return true
        case 1:
            limit = new Date(today.getFullYear(), today.getMonth(), today.getDate() + 7)
            return (JS.tools.isoToDate(task.due) <= limit)
        case 2:
            limit = new Date(today.getFullYear(), today.getMonth() + 1, today.getDate())
            return (JS.tools.isoToDate(task.due) <= limit)
        }
    }

    function publishNotifications() {
        //check if replaceIDs is restored from settings
        if (replaceIDs) {
            removeAll()
            for (var i = 0; i < taskList.count; i++){
                var task = taskList.get(i)
                if (filterTask(task)) {
                    var notificationComp = Qt.createComponent(Qt.resolvedUrl("./Notification.qml"))

                    var notification = notificationComp.createObject(null , {task: task}) //parent needed?
                    notification.publish()
                    replaceIDs.push(notification.replacesId)
                }
            }
            settings.notificationIDs.value = replaceIDs
            //console.log("added", replaceIDs, settings.notificationIDs.value)
        }
    }

    function removeAll() {
        if (replaceIDs && replaceIDs.length > 0) {
            //console.log("removing", replaceIDs)
            replaceIDs.forEach(function(_id, index){
                var notificationComp = Qt.createComponent(Qt.resolvedUrl("./Notification.qml"))

                var notification = notificationComp.createObject(null, {task: JS.tools.lineToJSON("")})
                notification.replacesId = _id
                notification.publish()
                notification.close()
            })
            settings.notificationIDs.value = replaceIDs = []
        }
    }


    Component.onCompleted: {
        //console.log("settings.notificationIDs.value", settings.notificationIDs.value)
        replaceIDs = settings.notificationIDs.value
        publishNotifications()
    }

    Component.onDestruction: {
        removeAll()
        //console.log(replaceIDs, settings.notificationIDs.value)
    }
}

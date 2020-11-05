import QtQuick 2.0

import "../tdt/todotxt.js" as JS

QtObject {
    id: notificationList
    property var replaceIDs
    property var taskList: ListModel {}

    function filterTask(task) {
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
            var publishQueue = []
            for (var i = 0;
                 notificationSettings.showNotifications &&
                 //(notificationSettings.maxCount === 0 || publishQueue.length < notificationSettings.maxCount) &&
                 i < taskList.count; i++){
                var task = taskList.get(i)
                if (filterTask(task)) {
//                    var notificationComp = Qt.createComponent(Qt.resolvedUrl("./Notification.qml"))

//                    var notification = notificationComp.createObject(null , {task: task}) //parent needed?
                    publishQueue.push(task)
                    //notification.publish()
                    //replaceIDs.push(notification.replacesId)
                }
            }
            console.log(publishQueue, publishQueue[0].subject)
            //sort by due date
            publishQueue.sort(function(a,b){
                //console.log(a.dueDate.getTime(), b.dueDate.getTime(),a.dueDate.getTime() - b.dueDate.getTime())
                return JS.tools.isoToDate(a.due).getTime() - JS.tools.isoToDate(b.due).getTime()
            })
            console.log(publishQueue, publishQueue[0].subject)

            //crop publishQueue
            if (notificationSettings.maxCount > 0) {
                publishQueue.splice(notificationSettings.maxCount, publishQueue.length)
            }
            console.log(notificationSettings.maxCount, publishQueue, publishQueue[0].subject)

            //revers publicQueue (has no effect?)
            //publishQueue = publishQueue.reverse()
            console.log(publishQueue, publishQueue[0].subject)
            var notificationComp, notification
            publishQueue.forEach(function(task){
                notificationComp = Qt.createComponent(Qt.resolvedUrl("./Notification.qml"))
                notification = notificationComp.createObject(null , {task: task}) //parent needed?
                notification.publish()
                replaceIDs.push(notification.replacesId)
            })
            publishQueue.forEach(function(task){
                notificationComp = Qt.createComponent(Qt.resolvedUrl("./Notification.qml"))
                notification = notificationComp.createObject(null , {task: task}) //parent needed?
                notification.publish()
                replaceIDs.push(notification.replacesId)
            })
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

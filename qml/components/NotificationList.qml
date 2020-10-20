import QtQuick 2.0

import "../tdt/todotxt.js" as JS

Item {
    id: notificationList
    property var replaceIds: settings.notificationIDs.value //[]
    onReplaceIdsChanged: console.log(replaceIds)
    property var taskList: ListModel {}

    function publishNotifications() {
        removeAll()
        for (var i = 0; i < taskList.count; i++){
            var task = taskList.get(i)
            if (task.due !== "" && task.done === false) {
                var notificationComp = Qt.createComponent(Qt.resolvedUrl("./Notification.qml"))

                var notification = notificationComp.createObject(null , {task: task}) //parent needed?
                notification.publish()
                settings.notificationIDs.value.push(notification.replacesId)
                settings.notificationIDs.sync()
                console.log(notification.replacesId, replaceIds, settings.notificationIDs.value)
            }
        }
    }

    function removeAll() {
        if (replaceIds) {
            replaceIds.forEach(function(_id, index){
                var notificationComp = Qt.createComponent(Qt.resolvedUrl("./Notification.qml"))

                var notification = notificationComp.createObject(null, {task: JS.tools.lineToJSON("")})
                notification.replacesId = _id
                notification.publish()
                notification.close()
                settings.notificationIDs.value.splice(index, 1)
            })
        }
    }


    Component.onCompleted: {
//        replaceIds = settings.notificationIDs.value
//        console.log(replaceIds, settings.notificationIDs.value)
//        removeAll()
    }

    Component.onDestruction: {
            removeAll()
    }
}

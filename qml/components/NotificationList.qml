import QtQuick 2.0

import "../tdt/todotxt.js" as JS

Item {
    id: notificationList
    property var ids: []
    //property var taskList

    function publishNotifications(taskList) {
        console.log("notificationList")
        removeAll()
        JS.taskList.itemList.forEach(function(task){
            if (task.due !== "" && task.done === false) {
                var notificationComp = Qt.createComponent(Qt.resolvedUrl("./Notification.qml"))

                var notification = notificationComp.createObject(null, {task: task}) //parent needed?
                notification.publish()
                settings.notificationIDs.value.push(notification.replacesId)
                //console.log(notification.replacesId, notifications.idList);
            }
        })
    }

    function removeAll() {
        ids.forEach(function(_id, index){
            var notificationComp = Qt.createComponent(Qt.resolvedUrl("./Notification.qml"))

            var notification = notificationComp.createObject(null, {task: JS.tools.lineToJSON("")})
            notification.replacesId = _id
            notification.publish()
            notification.close()
            settings.notificationIDs.value.splice(index, 1)
        })
    }


    Component.onDestruction: {
            removeAll()
    }
}

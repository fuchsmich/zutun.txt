import QtQuick 2.0

Item {
    id: notificationList
    property var ids: []
    //property var taskList

    function publishNotifications(taskList) {
        console.log("notificationList")
        removeAll()
        for (var i = 0; i < taskList.count; i++) {
            var item = taskList.get(i)
            if (item.due !== "" && item.done === false) {
                var notificationComp = Qt.createComponent(Qt.resolvedUrl("./Notification.qml"))

                var notification = notificationComp.createObject(notificationList) //parent needed?
                notification.timestamp = Date.fromLocaleString(Qt.locale(), item.due, "yyyy-MM-dd")
                notification.body = item.subject
                notification.summary = Date.fromLocaleString(Qt.locale(), item.due, "yyyy-MM-dd")
                notification.publish()
                ids.push(notification.replacesId)
                //console.log(notification.replacesId, notifications.idList);
            }
        }
    }

    function removeAll() {
        for (var i = 0; i < ids.length; i++) {
            var notificationComp = Qt.createComponent(Qt.resolvedUrl("./Notification.qml"))

            var notification = notificationComp.createObject(app)
            notification.replacesId =  ids[i]
            notification.close()
            notification.publish()
        }
        ids = []
    }
}

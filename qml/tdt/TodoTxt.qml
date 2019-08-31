import QtQuick 2.0

import Sailfish.Silica 1.0

import "todotxt.js" as JS

QtObject {
    property FileIO file: FileIO {
        property string hintText: ""
        path: settings.todoTxtLocation

        onIoError: {
            //TODO needs some rework for translation
            hintText = msg;
        }
    }

    property var notifications: {
        "idList": [],
        "removeAll": function() {
            for (var i = 0; i < notifications.idList.length; i++) {
                var notificationComp = Qt.createComponent(Qt.resolvedUrl("./Notification.qml"));

                var notification = notificationComp.createObject(app);
                notification.replacesId =  notifications.idList[i];
                notification.close();
                notification.publish();
            }
            notifications.idList = [];
        }
    }

    function saveList() {
        var array
        for (var i = 0; i < count; i++) {
            array.append(tasks.get(i).fullTxt)
        }
        array.sort()
        file.save(array)
    }

    function readFile() {
        var content = file.read()
        if (content) tasks.populate(JS.splitLines(content))
    }

    property ListModel tasks: ListModel {

        /* überschreiben contentder Funktion setProperty: */
        function setProperty(index, prop, value) {
            var item = get(index)
            var json = ttm1.tasks.lineToJSON(
                        JS.baseFeatures.modifyLine(item.fullTxt, JS.baseFeatures[prop], value))
            console.log(JSON.stringify(json))
            ttm1.tasks.set(index, json)
        }


        function removeItem(index) {
            var newArr = tasksArray;
            newArr.splice(get(index).lineNum, 1);
            listToFile(newArr);
        }

        function prioColor(prio) {
            //        aus ColorPicker.qml:
            var colors = ["#e60003", "#e6007c", "#e700cc", "#9d00e7",
                          "#7b00e6", "#5d00e5", "#0077e7", "#01a9e7",
                          "#00cce7", "#00e696", "#00e600", "#99e600",
                          "#e3e601", "#e5bc00", "#e78601"];

            return colors[JS.alphabet.search(prio) % colors.length];
        }

        function linkify(text) {
            text = text.replace(JS.mailPattern, function(url) {
                return '<a href="mailto:' + url + '">' + url + '</a>';
            });
            return text.replace(JS.urlPattern, function(url) {
                return '<a href="' + url + '">' + url + '</a>';
            });
        }

        function lineToJSON(line) {
            var item = JS.baseFeatures.parseLine(line);

            var displayText = linkify(item.subject)
            displayText = displayText.replace(
                        JS.projects.pattern,
                        function(x) { return ' <font color="' + Theme.highlightColor + '">' + x + ' </font>'});
            displayText = displayText.replace(
                        JS.contexts.pattern,
                        function(x) { return ' <font color="' + Theme.secondaryHighlightColor + '">' + x + ' </font>'});
            displayText = (item.priority !== "" ?
                               '<font color="' + prioColor(item.priority) + '">(' + item.priority + ') </font>' : "")
                    + displayText //item.subject //+ '<br/>' +item.creationDate

            item["formattedSubject"] = displayText

            return  item
        }

        function populate(array) {
            clear()
            notifications.removeAll()
            for (var a = 0; a < array.length; a++) {
                var line = array[a];

                var json = lineToJSON(line)

                append(json)

                //for due dates add notification
                if (json.due !== "") {
                    var notificationComp = Qt.createComponent(Qt.resolvedUrl("./Notification.qml"))

                    var notification = notificationComp.createObject(app)
                    notification.timestamp = Date.fromLocaleString(Qt.locale(), json.due, "yyyy-MM-dd")
                    notification.body = json.subject
                    notification.summary = json.due
                    notification.publish()
                    notifications.idList.push(notification.replacesId)
                    //console.log(notification.replacesId, notifications.idList);
                }

            }
        }
    }

    Component.onDestruction: {
        notifications.removeAll();
    }
}

import QtQuick 2.0

import Sailfish.Silica 1.0

import "todotxt.js" as JS

QtObject {
    property FileIO file: FileIO {
        property string hintText: ""
        path: settings.todoTxtLocation
        onContentChanged:{
            tasksArray = JS.splitLines(content);
        }

        onIoError: {
            //TODO needs some rework for translation
            hintText = msg;
        }
    }

    property var tasksArray: []
    onTasksArrayChanged: {
        readArray();
    }

    function reloadFile() {
        file.read();
    }

    signal readArray()
    onReadArray: {
        tasks.populate(tasksArray);
        //filters.fetchModels();
    }

    signal listToFile(var newArray)
    onListToFile: {
        newArray.sort();
        var txt = "";
        for (var t in newArray) {
            txt += newArray[t] + "\n";
        }
        //this writes to the file:
        file.save(txt);
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

    property ListModel tasks: ListModel {

        //alles auf einmal 0:fullTxt, 1:done, 2:completionDate, 3:priority, 4:creationDate, 5:subject
        //        property var basicPattern: JS.baseFeatures.pattern
        property string lowestPrio: "A"

        /* überschreiben der Funktion setProperty: */
        function setProperty(index, prop, value) {
            var newArr = tasksArray
            var lineNum = get(index).lineNum

            var feature = -1;
            switch (prop) {
            case "done" : feature = JS.baseFeatures.done; break;
            case "priority" : feature = JS.baseFeatures.priority; break;
            default: break
            }

            newArr[lineNum] = JS.baseFeatures.modifyLine(tasksArray[lineNum], feature, value);
            listToFile(newArr);
        }

        function setFullTxt(index, fullTxt) {
            var newArr = tasksArray;

            if (index === -1) newArr.push(fullTxt);
            else  newArr[get(index).lineNum] = fullTxt;

            listToFile(newArr);
        }


        /*raise/lower priority*/
        function alterPriority(index, raise) {
            var newPrio = get(index).priority
            if (raise) {
                if (newPrio === "") newPrio = String.fromCharCode(lowestPrio.charCodeAt(0) + 1);
                else if (newPrio > "A") newPrio = String.fromCharCode(newPrio.charCodeAt(0) - 1);
            } else  {
                if (newPrio !== "") {
                    if (newPrio < "Z") newPrio = String.fromCharCode(newPrio.charCodeAt(0) + 1);
                    else newPrio = "";
                }
            }
            setProperty(index, "priority", newPrio);
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

        //returns position where to insert *item* decieded by *lessThanFunc*
        function insertPosition(lessThanFunc, item) {
            var lower = 0;
            var upper = count;
            while (lower < upper) {
                var middle = Math.floor(lower + (upper - lower) / 2);
                var result =
                        lessThanFunc(item, get(middle)); //JS.baseFeatures.parseLine(tasksArray[get(middle).lineNum]));
                if (result) {
                    upper = middle;
                } else {
                    lower = middle + 1;
                }
            }
            return lower;
        }

        function linkify(text) {
            text = text.replace(JS.mailPattern, function(url) {
                return '<a href="mailto:' + url + '">' + url + '</a>';
            });
            return text.replace(JS.urlPattern, function(url) {
                return '<a href="' + url + '">' + url + '</a>';
            });
        }

        function lineToJSON(num, line) {
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

            return {"lineNum": num,
                "fullTxt": item.fullTxt, //raw text
                "subject": item.subject, //raw text without prio, creationDate,...
                "formattedSubject": displayText, //subject with colored proj, subj
                "done": item.done,
                "priority": item.priority,
                "creationDate": item.creationDate,
                "due": item.due,
                "section": ""
            }

        }

        function populate(array) {
            //clear();
            notifications.removeAll();
            for (var a = 0; a < array.length; a++) {
                var line = array[a];

                var json = lineToJSON(a, line)

                lowestPrio = (!json.done && json.priority !== "" && json.priority.charCodeAt(0) > lowestPrio.charCodeAt(0)
                              ? json.priority : lowestPrio);

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

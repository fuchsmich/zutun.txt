import QtQuick 2.0

import Sailfish.Silica 1.0

import "todotxt.js" as JS

ListModel {
    signal listChanged()
    // aus ColorPicker.qml:
    property var textList: []
    onTextListChanged: populateTextList()

    property var prioColors: ["#e60003", "#e6007c", "#e700cc", "#9d00e7",
        "#7b00e6", "#5d00e5", "#0077e7", "#01a9e7",
        "#00cce7", "#00e696", "#00e600", "#99e600",
        "#e3e601", "#e5bc00", "#e78601"]

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

    //group by: 0..None, 1..projects, 2..contexts
    property int section: 0
    onSectionChanged: populateTextList()

    function saveList() {
        textList.sort()
        file.save(textList.join("\n"))
    }

    function readFile() {
        file.read()
    }


    function setTaskProperty(id, prop, value) {
        console.log(id, prop, value)
        if (id < textList.length) {
            textList[id] = JS.baseFeatures.modifyLine(textList[id], JS.baseFeatures[prop], value)
            populateTextList()
        }
        saveList()
    }

    function addTask(txt) {
        textList.push(txt)
        populateTextList()
        saveList()
    }

    function removeTask(index) {
        var item = get(index)
        for (var i = 0; i < count; i++) {
            if (get(i).id === item.id) remove(i)
        }
        remove(index)
        saveList()
    }

    function prioColor(prio) {
        return prioColors[JS.alphabet.search(prio) % prioColors.length]
    }

    function linkify(text) {
        text = text.replace(JS.mailPattern, function(url) {
            return '<a href="mailto:' + url + '">' + url + '</a>'
        });
        return text.replace(JS.urlPattern, function(url) {
            return '<a href="' + url + '">' + url + '</a>'
        });
    }

    function lineToJSON(line) {
        var item = JS.baseFeatures.parseLine(line);

        var displayText = linkify(item.subject)
        displayText = displayText.replace(
                    JS.projects.pattern,
                    function(x) { return ' <font color="' + Theme.highlightColor + '">' + x + ' </font>'})
        displayText = displayText.replace(
                    JS.contexts.pattern,
                    function(x) { return ' <font color="' + Theme.secondaryHighlightColor + '">' + x + ' </font>'})
        displayText = (item.priority !== "" ?
                           '<font color="' + prioColor(item.priority) + '">(' + item.priority + ') </font>' : "")
                + displayText //item.subject //+ '<br/>' +item.creationDate

        item["formattedSubject"] = displayText

        return  item
    }

    function appendLine(lineNum, line) {
        var json = lineToJSON(line)
        json["id"] = lineNum
        json["section"] = ""

        var itemSections = false
        switch (section) {
        case 1:
            itemSections = JS.projects.listLine(line)
            break
        case 2:
            itemSections = JS.contexts.listLine(line)
            break
        default:
            itemSections = false
        }
        if (itemSections.length > 0) {
            for (var s in itemSections) {
                json.section = itemSections[s]
                //console.log(JSON.stringify(json))
                append(json)
            }
        }
        else append(json)

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

    function populateTextList() {
        textList.sort()
        notifications.removeAll()
        var i = 0
        for (var a = 0; a < textList.length; a++) {
            var line = textList[a]
            var json = lineToJSON(line)
            json["id"] = a
            json["section"] = ""

            var itemSections = false
            switch (section) {
            case 1:
                itemSections = JS.projects.listLine(line)
                break
            case 2:
                itemSections = JS.contexts.listLine(line)
                break
            default:
                itemSections = false
            }

            if (itemSections.length > 0) {
                for (var s in itemSections) {
                    json.section = itemSections[s]
                    //console.log(JSON.stringify(json))
                    if (i < count) set(i, json)
                    else append(json)
                    i++
                }
            }
            else {
                if (i < count) set(i, json)
                else append(json)
                i++
            }
        }
        if (i < count) remove(i, count - i)
        listChanged()
    }

    function setTextList(newList) {
        var array = JS.splitLines(newList)
        if (array.join() !== textList.join()) {
            textList = array
        }
    }
}

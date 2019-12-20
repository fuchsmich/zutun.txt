import QtQuick 2.0

//import Sailfish.Silica 1.0

import "todotxt.js" as JS

ListModel {
    signal listChanged()
    signal itemChanged(int index)
    signal saveList(string content)

    property var textList: []
    //onTextListChanged: populateTextList()
    property var projects: {
        return JS.projects.getList(textList)
    }
    onProjectsChanged: console.log("projects", projects)
    property var contexts: {
        return JS.contexts.getList(textList)
    }

    // aus ColorPicker.qml:
    property var prioColors: ["#e60003", "#e6007c", "#e700cc", "#9d00e7",
        "#7b00e6", "#5d00e5", "#0077e7", "#01a9e7",
        "#00cce7", "#00e696", "#00e600", "#99e600",
        "#e3e601", "#e5bc00", "#e78601"]
    property color projectColor
    property color contextColor

    //TODO move back to delegateModel
    //group by: 0..None, 1..projects, 2..contexts
    //property int section: 1
    //onSectionChanged: populateTextList()

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
        var item = JS.baseFeatures.parseLine(line)

        var displayText = linkify(item.subject)
        displayText = displayText.replace(
                    JS.projects.pattern,
                    function(x) { return ' <font color="' + projectColor + '">' + x + ' </font>'})
        displayText = displayText.replace(
                    JS.contexts.pattern,
                    function(x) { return ' <font color="' + contextColor + '">' + x + ' </font>'})
        displayText = (item.priority !== "" ?
                           '<font color="' + prioColor(item.priority) + '">(' + item.priority + ') </font>' : "")
                + displayText //item.subject //+ '<br/>' +item.creationDate

        item["formattedSubject"] = displayText

        item["section"] = ""
//        switch (section) {
//        case 1:
//            item["section"] = JS.projects.listLine(line).sort().join(", ")
//            break
//        case 2:
//            item["section"] = JS.contexts.listLine(line).sort().join(", ")
//            break
//        default:
//            item["section"] = ""
//        }

        return  item
    }

    function addTask(text) {
        //console.log("adding", text)
        append(lineToJSON(text))
        _saveList()
    }

    function removeTask(index) {
        remove(index)
        _saveList()
    }

    function setTextList(newList) {
        var array = JS.splitLines(newList)
        if (array.join() !== textList.join()) {
            textList = array.sort()
        }

        clear()
        var i = 0
        for (var a = 0; a < textList.length; a++) {
            var line = textList[a]
            var json = lineToJSON(line)

            if (i < count) set(i, json)
            else append(json)
            i++
        }
        if (i < count) remove(i, count - i)

        //listChanged()
    }

    function _saveList() {
        var list = []
        for (var i = 0; i < count; i++) {
            list.push(get(i).fullTxt)
        }
        list.sort()
        textList = list
        console.log("Saving:", list.join("\n"))
        saveList(list.join("\n"))
    }

    function setTaskProperty(index, role, value) {
        if (role >= JS.baseFeatures.fullTxt && role <= JS.baseFeatures.creationDate) {
            var oldLine = get(index).fullTxt
            var newLine = JS.baseFeatures.modifyLine(oldLine, role, value)
            console.log(index, newLine)
            set(index, lineToJSON(newLine))
        }
        _saveList()
    }

    onDataChanged: {
        //console.log('Data Changed', topLeft.row, get(topLeft.row).done, roles, roles.size, roles[0], data(topLeft, roles[0]))


        //in SFOS kommt kein "roles" an???
        if (typeof roles.length === 'undefined') {
            console.log("qt 5.6 qml can't handle role")
        }


        //replace below with (?): setTaskProperty(topLeft.row, roles[0], data(topLeft, roles[0]))
        //property changed, sync other properties
        if (roles[0] >= JS.baseFeatures.fullTxt && roles[0] <= JS.baseFeatures.creationDate) {
            var oldLine = get(topLeft.row).fullTxt
            var newValue = data(topLeft, roles[0])
            var newLine = JS.baseFeatures.modifyLine(oldLine, roles[0], newValue)
            console.log(newLine)
            set(topLeft.row, lineToJSON(newLine))
        }

        //fullTxt changed, list can be saved
        if (roles[0] === JS.baseFeatures.fullTxt){
            _saveList()
            //itemChanged(topLeft.row)
        }
    }
}

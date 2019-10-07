import QtQuick 2.0

//import Sailfish.Silica 1.0

import "todotxt.js" as JS

ListModel {
    signal listChanged()
    signal itemChanged(int index)
    property var textList: []
    onTextListChanged: populateTextList()

    // aus ColorPicker.qml:
    property var prioColors: ["#e60003", "#e6007c", "#e700cc", "#9d00e7",
        "#7b00e6", "#5d00e5", "#0077e7", "#01a9e7",
        "#00cce7", "#00e696", "#00e600", "#99e600",
        "#e3e601", "#e5bc00", "#e78601"]
    property color projectColor
    property color contextColor

    //group by: 0..None, 1..projects, 2..contexts
    property int section: 1
    onSectionChanged: populateTextList()

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

        switch (section) {
        case 1:
            item["section"] = JS.projects.listLine(line).sort().join(", ")
            break
        case 2:
            item["section"] = JS.contexts.listLine(line).sort().join(", ")
            break
        default:
            item["section"] = ""
        }

        return  item
    }

    function addTask(text) {
        console.log("adding", text)
        append(lineToJSON(text))
        saveList()
    }

    function populateTextList() {
        //textList.sort()
        //notifications.removeAll()
        var i = 0
        for (var a = 0; a < textList.length; a++) {
            var line = textList[a]
            var json = lineToJSON(line)

//            var itemSections = ""
//            switch (section) {
//            case 1:
//                json["section"] = JS.projects.listLine(line).sort().join(", ")
//                break
//            case 2:
//                json["section"] = JS.contexts.listLine(line).sort().join(", ")
//                break
//            default:
//                json["section"] = ""
//            }

            if (i < count) set(i, json)
            else append(json)
            i++
        }
        if (i < count) remove(i, count - i)
        listChanged()
    }

    function setTextList(newList) {
        var array = JS.splitLines(newList)
        if (array.join() !== textList.join()) {
            textList = array.sort()
        }
    }

    function saveList() {
        var list = []
        for (var i = 0; i < count; i++) {
            list.push(get(i).fullTxt)
        }
        list.sort()
        //console.log("Saving:", list.join("\n"))
        todoTxtFile.content = list.join("\n")
    }

    onDataChanged: {
        console.log('Data Changed', topLeft.row, get(topLeft.row).done, roles.length, roles[0], data(topLeft, roles[0]))

        if (roles[0] >= JS.baseFeatures.fullTxt && roles[0] <= JS.baseFeatures.creationDate) {
            var oldLine = get(topLeft.row).fullTxt
            var newValue = data(topLeft, roles[0])
            var newLine = JS.baseFeatures.modifyLine(oldLine, roles[0], newValue)
            console.log(newLine)
            set(topLeft.row, lineToJSON(newLine))
        }

        //if fullTxt is set, list can be saved
        if (roles[0] == JS.baseFeatures.fullTxt){
            saveList()
            //itemChanged(topLeft.row)
        }
    }
}

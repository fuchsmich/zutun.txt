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
    //onProjectsChanged: console.log("projects", projects)
    property var contexts: {
        return JS.contexts.getList(textList)
    }

    function _saveList() {
        var list = []
        for (var i = 0; i < count; i++) {
            list.push(get(i).fullTxt)
        }
        list.sort()
        textList = list
        //console.log("Saving:", list.join("\n"))
        saveList(list.join("\n"))
    }

    function addTask(text) {
        //console.log("adding", text)
        append(lineToJSON(text))
        listChanged()
        _saveList()
    }

    function removeTask(index) {
        remove(index)
        listChanged()
        _saveList()
    }

    function setTaskProperty(index, role, value) {
        if (role >= JS.baseFeatures.fullTxt && role <= JS.baseFeatures.creationDate) {
            var oldLine = get(index).fullTxt
            var newLine = JS.baseFeatures.modifyLine(oldLine, role, value)
            console.log(index, newLine)
            set(index, JS.tools.lineToJSON(newLine))
        }
        listChanged()
        _saveList()
    }

    onDataChanged: {
        console.log('Data Changed', topLeft.row, get(topLeft.row).done, roles, roles.size, roles[0], data(topLeft, roles[0]))


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

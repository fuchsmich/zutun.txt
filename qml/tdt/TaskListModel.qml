import QtQuick 2.0

import "todotxt.js" as JS

ListModel {

    //0..init, 1..sorting, 2..ready
    //property int status: 0
    //property bool busy: status === 0 || status === 1

    property Filters filters: Filters {
        onFiltersChanged: _setVisibleList()
    }

    property Sorting sorting: Sorting {
    }

    property string defaultPriority: "F"

    signal saveTodoTxtFile(string content)

    property var textList: []
    property var visibleTextList: []

    signal taskListDataChanged(string reason)
    onTaskListDataChanged: {
        var tl = []; var vl = []
        for (var i = 0; i < count; i++ ) {
            var item = get(i)
            tl.push(item.fullTxt)
            if (filters.visibility(item)) vl.push(item.fullTxt)
        }
        tl.sort(); vl.sort()
        textList = tl; visibleTextList = vl
        filters.projectList = JS.projects.getList(textList)
        filters.contextList = JS.contexts.getList(textList)

        if (reason !== "read file") saveTodoTxtFile(textList.join("\n"))
    }

    function _setVisibleList() {
        var vl = []
        for (var i = 0; i < count; i++ ) {
            var item = get(i)
            if (filters.visibility(item)) vl.push(item.fullTxt)
        }
        vl.sort()
        visibleTextList = vl
    }

    function setFileContent(content) {        
        JS.taskList.setTextList(content)
        clear()
        var json = JS.taskList.itemList()
        json.forEach(function(item) {
            append(item)
        })
        taskListDataChanged("read file")
    }

    function setTaskProperty(index, feature, value) {
        var txt = JS.baseFeatures.modifyLine(get(index).fullTxt, feature, value)
        set(index, JS.tools.lineToJSON(txt))
        taskListDataChanged("set task property")
    }

    function removeTask(index) {
        remove(index)
        taskListDataChanged("remove task")
    }

    function addTask(text) {
        append(JS.tools.lineToJSON(text))
        taskListDataChanged("add task")
    }

    /*
    priority, incOrDec: true..inc, false..dec
    returns altered priority */
    function alterPriority(priority, incOrDec) {
        /* increase */
        if (incOrDec) {
            if (priority === "") priority = String.fromCharCode(defaultPriority.charCodeAt(0))
            else if (priority > "A") priority = String.fromCharCode(priority.charCodeAt(0) - 1)
        /* derease */
        } else  {
            if (priority !== "") {
                if (priority < "Z") priority = String.fromCharCode(priority.charCodeAt(0) + 1)
                else priority = ""
            }
        }
        return priority
    }

    //sorts listmodel due to compareFunc
    function listModelSort(lessThanFunc) {
        var indexes = new Array(count)
        for (var i = 0; i < count; i++) indexes[i] = i
        //console.debug(JSON.stringify(indexes))
        indexes.sort(function (a, b) {
            return (lessThanFunc(get(a), get(b)) ? -1 : 1)
        } )
        //console.debug(JSON.stringify(indexes))
        var sorted = 0
        while (sorted < indexes.length && sorted === indexes[sorted])
            sorted++
        //console.debug(sorted)
        if (sorted === indexes.length) return;
        for (i = sorted; i < indexes.length; i++) {
            var index = indexes[i]
            move(index, count - 1, 1)
            insert(index, { })
        }
        remove(sorted, indexes.length - sorted)
    }

    signal sortFinished()
    function resort(reason) {
        //status = 1
        console.debug(reason)
        listModelSort(sorting.lessThanFunc)
        sortFinished()
        //status = 2
    }

//    onDataChanged: {
//        //console.debug(topLeft, topLeft.model.get(topLeft.row).fullTxt, topLeft.column)
//    }
}

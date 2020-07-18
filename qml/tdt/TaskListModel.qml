import QtQuick 2.0

import "todotxt.js" as JS

ListModel {

    //0..init, 1..sorting, 2..ready
    property int status: 0
    property bool busy: status === 0 || status === 1

    property Filters filters: Filters {
        onFiltersChanged: resort("filters")
    }

    property Sorting sorting: Sorting {
        onSortingChanged: resort("sorting")
    }

    property string defaultPriority: "F"

    signal saveTodoTxtFile(string content)
    function saveList() {
        console.debug(textList.join("\n"))
        saveTodoTxtFile(textList.join("\n"))
    }

    property var textList: {
        var list = new Array(count)
        for (var i = 0; i < count; i++ ) {
            list[i] = get(i).fullTxt
        }
        list.sort() //TODO locale??
        return list
    }

    property var visibleTextList: {
        var list = []
        for (var i = 0; i < count; i++ ) {
            if (filters.visibility(get(i))) list.push(get(i).fullTxt)
        }
        list.sort() //TODO locale??
        return list
    }

    signal taskListDataChanged(string reason)
    onTaskListDataChanged: {
        resort(reason)
        filters.projectList = JS.projects.getList(textList)
        filters.contextList = JS.contexts.getList(textList)
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
        resort(index, "set task property")
        saveList()
    }

    function removeTask(index) {
        remove(index)
        saveList()
        resort("remove task")
    }

    function addTask(text) {
        append(JS.tools.lineToJSON(text))
        saveList()
        resort("add task")
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
    function listModelSort(compareFunc) {
        var indexes = new Array(count)
        for (var i = 0; i < count; i++) indexes[i] = i
        console.log(JSON.stringify(indexes))
        indexes.sort(function (a, b) {
            return compareFunc(get(a), get(b))
        } )
        console.log(JSON.stringify(indexes))
        var sorted = 0
        while (sorted < indexes.length && sorted === indexes[sorted])
            sorted++
        console.log(sorted)
        if (sorted === indexes.length) return;
        for (i = sorted; i < indexes.length; i++) {
            var index = indexes[i]
            move(index, count - 1, 1)
            insert(index, { } ) //??
        }
        remove(sorted, indexes.length - sorted);
    }

    signal sortFinished()
    function resort(reason) {
        status = 1
        console.debug(reason)
        listModelSort(sorting.lessThanFunc)
        sortFinished()
        status = 2
    }

    onDataChanged: {
        console.debug(topLeft)
    }
}

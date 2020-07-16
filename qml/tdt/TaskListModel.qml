import QtQuick 2.0

import "todotxt.js" as JS

ListModel {
    signal sortFinished()

    //0..init, 1..sorting, 2..ready
    property int status: 0
    property bool busy: status === 0 || status === 1

    signal taskListChanged()
    onTaskListChanged: {
        totalNumberOfTasks = JS.taskList.textList.length
    }

    property Filters filters: Filters {
        onFiltersChanged: resort("filters")
    }

    property Sorting sorting: Sorting {
        onSortingChanged: resort("sorting")
    }

    property int totalNumberOfTasks: 0

    property string defaultPriority: "F"

    signal saveList()

    function setFileContent(content) {
        JS.taskList.setTextList(content)
        resort("file content")
    }

    function setTaskProperty(index, feature, value) {
        JS.taskList.modifyTask(index, feature, value)
        saveList()
        resort("set task property")
    }

    function removeTask(index) {
        JS.taskList.removeTask(index)
        saveList()
        resort("remove task")
    }

    function addTask(text) {
        JS.taskList.addTask(index)
        saveList()
        resort("add task")
    }

    function alterPriority(index, change) {
        var json = JS.tools.lineToJSON(JS.taskList.textList[index])
        var priority = json.priority
        if (change === "inc") {
            if (priority === "") priority = String.fromCharCode(defaultPriority.charCodeAt(0))
            else if (priority > "A") priority = String.fromCharCode(priority.charCodeAt(0) - 1)
        } else  {
            if (priority !== "") {
                if (priority < "Z") priority = String.fromCharCode(priority.charCodeAt(0) + 1)
                else priority = ""
            }
        }
        JS.taskList.modifyTask(index, JS.baseFeatures.priority, priority)
        saveList()
        resort("priority")
    }

    //return the positon of the item in the list due to function lessThanFunc
    function insertPosition(lessThanFunc, item) {
        var lower = 0
        var upper = count
        while (lower < upper) {
            var middle = Math.floor(lower + (upper - lower)/2)
            var result =
                    lessThanFunc(item, get(middle))
            if (result) {
                upper = middle
            } else {
                lower = middle + 1
            }
        }
        return lower
    }

    function sort(lessThan) {
        status = 1
        var json = JS.taskList.itemList()
        //TODO set section??
        json.forEach(function(item){
            if (filters.visibility(item)) {
                if (item.priority.charCodeAt(0) > defaultPriority.charCodeAt(0))
                    defaultPriority = item.priority
                var index = insertPosition(lessThan, item)
                insert(index, item)
            }
        })
        sortFinished()
        status = 2
    }

    function resort(reason) {
        status = 1
        console.debug(reason)
        clear()
        sort(sorting.lessThanFunc)
    }
}

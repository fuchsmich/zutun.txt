import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQml.Models 2.1

import FileIO 1.0
import "todotxt.js" as JS

//TODO alles (done, date, etc. ausm fulltext lesen)??

DelegateModel {
    id: dm
    property FileIO file: FileIO {
        //        id: file
        path: settings.todoTxtLocation
        onContentChanged:{
            var lists = JS.parseTodoTxt(content);
            taskModel.taskList = lists.taskList;
            //            console.log(taskModel.taskList)
            //            projects = lists.projects;
            //            contexts = lists.contexts;
            //            proConArray = lists.proConArray;
        }
    }

    /**** Taskliste */

    model: ListModel {
        id: taskModel
        property var taskList: []
        //        aus ColorPicker.qml:
        property var colors: ["#e60003", "#e6007c", "#e700cc", "#9d00e7",
            "#7b00e6", "#5d00e5", "#0077e7", "#01a9e7",
            "#00cce7", "#00e696", "#00e600", "#99e600",
            "#e3e601", "#e5bc00", "#e78601"]

        //fullTxt, done, doneDate, priority, creationDate, subject
        property QtObject task: QtObject {
            property int fullTxt: 0
            property int done: 1
            property int doneDate: 2
            property int priority: 3
            property int creationDate: 4
            property int subject: 5
        }

        onTaskListChanged: populate(taskList)

        function populate(array) {
            for (var a = 0; a < array.length; a++) {
                var displayText = (array[a][task.priority] !== undefined ? '<font color="' + prioColor(array[a][task.priority]) + '">'
                                                                           + array[a][task.priority]+ '</font>' : "")
                        + array[a][task.subject]
                console.log(array[a][task.priority], displayText)

                var done = array[a][task.done] !== undefined

                var json = {"fullTxt": array[a][task.fullTxt], "done": getDone(a), "displayText": displayText}
                //bestehende ersetzen
                if (a < count) set(a, json)
                //restliche anhängen
                else append(json)
            }

            //überzählige löschen
            if (a < count) remove(a, (count - a) )

        }

        function getAttribute(index, attribute) {
            var txt = get(index).fullTxt;
            var patterns = [
//                        var matches = txt.match(/^(x\s)?(\d{4}-\d{2}-\d{2}\s)?(\([A-Z]\)\s)?(\d{4}-\d{2}-\d{2}\s)?(.*)/);

                        { attribute: 'done', pattern: /^(x\s).*/},
                        { attribute: 'doneDate', pattern: /^(x\s).*/}
                    ];
        }



        /* get done state */
        function getDone(index) {
            if (index >= 0 && index < taskList.length) {
                return (typeof taskList[index][task.done] !== 'undefined' ? (taskList[index][task.done][0] === 'x') : false);
            } else throw "done: Index out of bounds."
        }

        function today() {
            return Qt.formatDate(new Date(),"yyyy-MM-dd");
        }



        /* set done state and done date */
        function setDone(index, value) {
            if (index >= 0 && index < taskList.length) {
                if (value && !getDone(index))
                    taskList[index][task.fullTxt] =
                            "x " + today() + " " + taskList[index][task.fullTxt];
                if (!value && getDone(index))
                    taskList[index][task.fullTxt] =
                            taskList[index][task.fullTxt].match(/(x\s)?(\d{4}-\d{2}-\d{2}\s)?(.*)/)[3]; //Datum muss auch weg!!
                listToFile();
            } else throw "done: Index out of bounds."
        }


        /* get color due to Priority*/
        function prioColor(prio) {
            //            console.log(index, getPriority(index));
            return colors[JS.alphabet.search(prio[1]) % 15];
        }

        /* sort list and write it to the txtFile*/
        function listToFile() {
            taskList.sort();
            var txt = "";
            for (var t in taskList) {
                txt += taskList[t][task.fullTxt] + "\n";
            }
            //this writes to the file:
            file.content = txt;
        }
    }


    property var lessThan: [
        function(left, right) {  //like in textfile
            if (asc) return left.fullTxt < right.fullTxt
            else return left.fullTxt > right.fullTxt },
        function(left, right) { return left.fullTxt > right.fullTxt }
    ]

    property int sortOrder: 0
    property bool asc: true
    onSortOrderChanged: {
        //        resorting = true
        items.setGroups(0, items.count, "unsorted")
        invisible.setGroups(0, invisible.count, "unsorted")
        //        resorting = false
    }

    function insertPosition(lessThanFunc, item) {
        var lower = 0
        var upper = items.count
        while (lower < upper) {
            var middle = Math.floor(lower + (upper - lower) / 2)
            var result = lessThanFunc(item.model, items.get(middle).model);
            if (result) {
                upper = middle
            } else {
                lower = middle + 1
            }
        }
        return lower
    }

    function sort(lessThanFunc) {
        while (visible.count > 0) {
            var item = visible.get(0)
            //                    if (item.itemVisible) {
            var index = insertPosition(lessThanFunc, item)
            console.log(visible.count, items.count, index, item.groups);

            item.groups = "items"
            items.move(item.itemsIndex, index)
            //                    }
            //                    else item.groups = "hidden"
        }
    }


    /***** Filter Stuff ***/

    property var filters: [
        function (item) { return !item.model.done }
    ]

    property int filterSet: (filterSettings.hideCompletedTasks ? 0 : 1)
    onFilterSetChanged:  {
        items.setGroups(0, items.count, "unsorted")
        invisible.setGroups(0, invisible.count, "unsorted")
    }

    //    property bool hideCompleted: filterSettings.hideCompletedTasks
    //    onHideCompletedChanged:

    Connections {
        target: filterSettings
        onHideCompletedChanged: items.setGroups(0, items.count, "unsorted")
    }

    function filter(filterFunc) {
        console.log("filtering", unsorted.count)
        while (unsorted.count >0 ) {
            console.log(unsorted.count)//, item.model.done)
            var item = unsorted.get(0)
            if (filterFunc(item)) item.groups = "visible"
            else item.groups = "invisible"
        }
    }
    /**** End Filters ***/

    items.includeByDefault: false
    groups:[ DelegateModelGroup {
            id: unsorted
            name: "unsorted"

            includeByDefault: true
            onChanged: {
                console.log("filtering")
                if (filterSet < filters.length) dm.filter(dm.filters[dm.filterSet])
                else setGroups(0, count, "visible")
            }
        }
        ,
        DelegateModelGroup {
            id: invisible
            name: "invisible"
        }
        ,
        DelegateModelGroup {
            id: visible
            name: "visible"
            onChanged: {
                console.log("sorting")
                if (dm.sortOrder == dm.lessThan.length)
                    setGroups(0, count, "items")
                else
                    dm.sort(dm.lessThan[dm.sortOrder])
            }
        } ]

    delegate: ListItem {
        id: listItem
        function remove() {
            remorseAction("Deleting", function() { tdt.removeItem(index) })
        }

        Row {
            id: row
            //            x: Theme.horizontalPageMargin
            anchors.verticalCenter: parent.verticalCenter
            Switch {
                id: doneSw
                height: lbl.height
                automaticCheck: false
                checked: model.done
                onClicked: ttm.model.setDone(index, !model.done);
            }

            Label {
                id:lbl
                width: listItem.width - doneSw.width - 2*Theme.horizontalPageMargin
                text: model.displayText
                wrapMode: Text.Wrap
                font.strikeout: model.done
                font.pixelSize: settings.fontSizeTaskList
            }
        }
        menu: ContextMenu {
            Label { text: index }
            MenuItem {
                visible: !model.done
                text: "Priority Up"
                onClicked: tdt.raisePriority(index)
            }
            MenuItem {
                visible: !model.done
                text: "Priority Down"
                onClicked: tdt.lowerPriority(index)
            }
            MenuItem {
                text: "Remove"
                onClicked: remove()
            }
        }

    }


    function reloadTodoTxt() {
        file.contentChanged()
    }



}

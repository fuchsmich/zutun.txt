import QtQuick 2.0
import QtQml.Models 2.1

import Sailfish.Silica 1.0

import "../tdt/todotxt.js" as JS

DelegateModel {
    id: visualModel

    property QtObject filters: QtObject {
        property bool hideDone: filterSettings.hideDone
        onHideDoneChanged: visualModel.resort()
        property var projects: filterSettings.projects.value
        onProjectsChanged: visualModel.resort()
        property var contexts: filterSettings.contexts.value
        onContextsChanged: visualModel.resort()
        property string text: [hideDone? qsTr("Hide Complete"): undefined].concat(projects.concat(contexts)).join(", ")

        property ListModel projectsModel: ListModel {}
        property ListModel contextsModel: ListModel {}

        signal fetchModels()
        onFetchModels: {
            populate(projectsModel, JS.projects.list(tasksArray));
            populate(contextsModel, JS.contexts.list(tasksArray));
        }

        function clearFilter(filterName) {
            switch(filterName) {
            case "projects": filterSettings.projects.value = []; break;
            case "contexts": filterSettings.contexts.value = []; break;
            }
        }

        function visibility(item) {
            //            console.log(item.subject, projects, contexts)
            if ((hideDone && item.done)) return false;

            for (var p in projects) {
                //                console.log(item.subject,projects[p],item.subject.indexOf(projects[p]))
                if (item.subject.indexOf(projects[p]) === -1) return false;
            }

            for (var c in contexts) {
                if (item.subject.indexOf(contexts[c]) === -1) return false;
            }

            return true;
        }

        /* set filter; name... filterstring; onOff... turn it on (true) or off (false)*/
        function setByName(name, onOff) {
            var list = [];
            switch (name.charAt(0)) {
            case "+": list = projects; break;
            case "@": list = contexts; break;
            default: return;
            }
            if (onOff) list.push(name);
            else list.splice(list.indexOf(name), 1);
            //console.log(typeof filterSettings.projects, typeof list[0]);
            list.sort();
            switch (name.charAt(0)) {
            case "+": filterSettings.projects.value = list; break;
            case "@": filterSettings.contexts.value = list; break;
            default: return;
            }
        }

        function populate(model, array) {
            model.clear();
            var sortedArray, tmpArray = [];
            var itemCount, active, name, visibleItemCount;
            for ( var a in array) {
                tmpArray.push(a);
            }
            sortedArray = tmpArray.visibleItemsort();
            for (var i in sortedArray) {
                name = sortedArray[i];
                itemCount = array[name].length;
                visibleItemCount = 0;
                for (var j =0;  j < array[name].length; j++){
                    var taskItem = JS.baseFeatures.parseLine(tasksArray[array[name][j]]);
                    if (visibleItem(taskItem)) visibleItemCount++;
                }
                active = ((filters.projects !== undefined && filters.projects.indexOf(name) !== -1) ||
                          (filters.contexts !== undefined && filters.contexts.indexOf(name) !== -1))
                model.append( {"name": name, "active": active, "itemCount": itemCount, "visibleItemCount": visibleItemCount});
            }
        }

    }

    property QtObject sorting: QtObject {
        property bool asc: sortSettings.asc
        onAscChanged: visualModel.resort()

        property int order: sortSettings.order
        onOrderChanged: visualModel.resort()

        property int grouping: sortSettings.grouping
        onGroupingChanged: visualModel.resort()

        property string sortText: qsTr("Sorted by %1").arg(functionList[order][0] + ", " + (asc ? qsTr("asc") : qsTr("desc")))
        property string groupText: (grouping > 0 ? qsTr("Grouped by %1, ").arg(groupFunctionList[grouping][0]) : "")


        //returns a function, which compares two items
        function lessThanFunc() {
            return groupFunctionList[grouping][1]
        }

        //list of functions for sorting; *left* and *right* are the items to compare
        property var functionList: [
            [qsTr("natural"), function(left, right) {
                return (left.fullTxt === right.fullTxt ?
                            false :
                            (left.fullTxt < right.fullTxt) ^ !asc
                        )
            }],
            [qsTr("Creation Date"), function(left, right) {
                return (left.creationDate === right.creationDate ?
                            functionList[0][1](left, right) :
                            (left.creationDate < right.creationDate) ^ !asc
                        )
            }],
            [qsTr("Due Date"), function(left, right) {
                return (left.due === right.due ?
                            functionList[0][1](left, right) :
                            (left.due < right.due) ^ !asc
                        )
            }],
            [qsTr("Subject"), function(left, right) {
                return (left.subject === right.subject ?
                            functionList[0][1](left, right) :
                            (left.subject < right.subject)^ !asc
                        )
            }]
        ]

        //0..Name, 1..lessThanFunc, 2..return list of groups
        property var groupFunctionList: [
            [qsTr("None"),
             function(left, right) {
                 return functionList[order][1](left, right)
             },
             function(line) {
                 return []
             }
            ]
            ,[qsTr("Projects"),
              function(left, right) {
                  //console.log(typeof left.section, right.section)
                  return (left.section === right.section ?
                               functionList[order][1](left, right) :
                              (left.section < right.section) ^ !asc
                          )
              },
              function(line) {
                  return JS.projects.list([line])
              }]
            ,[qsTr("Contexts"),
              function(left, right) {
                  return groupFunctionList[1][1](left,right)
              },
              function(line) {
                  return JS.contexts.list([line])
              }]
        ]
    }

    signal editItem(int index)

    property string defaultPrio: "F"

    function setProperty(index, prop, value) {
        var item = items.get(index)
        //console.log(prop, value, item.model.fullTxt)
        //property up and down
        if (prop === "priority") {
            var p =  item.model.priority
            if (value === "up") {
                if (p === "") value = String.fromCharCode(defaultPrio.charCodeAt(0) + 1);
                else if (p > "A") value = String.fromCharCode(p.charCodeAt(0) - 1);
            } else if (value === "down"){
                if (p !== "" && p < "Z") value = String.fromCharCode(p.charCodeAt(0) + 1);
                else value = ""
            }
        }

        ttm1.tasks.setProperty(item.model.index, prop, value)
        item.groups = "unsorted"

//        var json = ttm1.tasks.lineToJSON(
//                    JS.baseFeatures.modifyLine(item.model.fullTxt, JS.baseFeatures[prop], value))
//        console.log(JSON.stringify(json))
//        var newIndex = insertPosition(sorting.lessThanFunc(), json)
//        if (newIndex > item.itemsIndex) newIndex--
//        ttm1.tasks.set(item.model.index, json)

//        if (filters.visibility(item.model))
//            items.move(item.itemsIndex, newIndex)
//        else item.groups = "invisible"
    }

    function insertPosition(lessThanFunc, item) {
        var lower = 0
        var upper = items.count
        while (lower < upper) {
            var middle = Math.floor(lower + (upper - lower)/2)
            var result =
                    lessThanFunc(
                        (item.model ? item.model : item), items.get(middle).model)
            if (result) {
                upper = middle
            } else {
                lower = middle + 1
            }
        }
        return lower
    }

    function sort(lessThan) {
        console.log("begin sort")
        while (unsortedItems.count > 0) {
            var item = unsortedItems.get(0)
            console.log(item.model.fullTxt, filters.visibility(item.model))
            if (filters.visibility(item.model)) {
                //TODO set section here
                var index = insertPosition(lessThan, item)

                item.groups = "items"
                items.move(item.itemsIndex, index)
            } else item.groups = "invisible"
        }
    }

    function resort() {
        items.setGroups(0, items.count, "unsorted")
        invisibleItems.setGroups(0, invisibleItems.count, "unsorted")
    }

    //https://doc.qt.io/qt-5/qtquick-tutorials-dynamicview-dynamicview4-example.html
    //model: ttm1.tasks
    delegate: TaskListItem {
        id: listItem
        done: model.done
        priority: model.priority
        creationDate: model.creationDate
        subject: model.formattedSubject
        due: model.due


        onToggleDone: setProperty(DelegateModel.itemsIndex, "done", !model.done)
        onPrioUp: setProperty(DelegateModel.itemsIndex, "priority", "up")
        onPrioDown: setProperty(DelegateModel.itemsIndex, "priority", "down")
        onEditItem: visualModel.editItem(model.index)
        //onRemoveItem: ttm1.tasks.removeItem(model.index)

    }
    items.includeByDefault: false

    groups: [
        DelegateModelGroup {
            id: unsortedItems
            name: "unsorted"
            includeByDefault: true
            onChanged: {
                visualModel.sort(sorting.lessThanFunc())
            }
        },
        DelegateModelGroup {
            id: invisibleItems
            name: "invisible"
        }
    ]
}

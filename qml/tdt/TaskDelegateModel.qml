import QtQuick 2.0
import QtQml.Models 2.1

//import Sailfish.Silica 1.0

import "../tdt/todotxt.js" as JS

DelegateModel {
    id: visualModel

    property QtObject filters: QtObject {
        property bool hideDone: filterSettings.hideDone
        onHideDoneChanged: visualModel.resort()
        property var text: function () {
            var ftext = [(hideDone ? qsTr("Hide Complete"): undefined)].concat(
            projects.active.concat(
                contexts.active)).join(", ")
            if (ftext) return ftext
            else return qsTr("None")
        }

        property FilterModel projects: FilterModel {
            name: "projects"
            active: filterSettings.projects.value
            onActiveChanged: visualModel.resort()
        }
        property FilterModel contexts: FilterModel {
            name: "contexts"
            active: filterSettings.contexts.value
            onActiveChanged: visualModel.resort()
        }

        function clearFilter(filterName) {
            switch(filterName) {
            case "projects": filterSettings.projects.value = []; break;
            case "contexts": filterSettings.contexts.value = []; break;
            }
        }

        function visibility(item) {
            if ((hideDone && item.done)) return false;

            for (var p in projects.active) {
                if (item.subject.indexOf(projects.active[p]) === -1) return false;
            }
            for (var c in contexts.active) {
                if (item.subject.indexOf(contexts.active[c]) === -1) return false;
            }
            return true;
        }

        /* set filter; name... filterstring; onOff... turn it on (true) or off (false)*/
        function setByName(name, onOff) {
            var list = [];
            switch (name.charAt(0)) {
            case "+": list = projects.active; break;
            case "@": list = contexts.active; break;
            default: return;
            }
            if (onOff) list.push(name);
            else list.splice(list.indexOf(name), 1);
            list.sort();
            switch (name.charAt(0)) {
            case "+": filterSettings.projects.value = list; break;
            case "@": filterSettings.contexts.value = list; break;
            default: return;
            }
        }

        function parseList() {
            var taskList = visualModel.model
            var filterList = []
            projects.clear()
            contexts.clear()
            for (var i = 0; i < taskList.count; i++) {
                var item = taskList.get(i)
                projects.addFilterItems(JS.projects.listLine(item.fullTxt), filters.visibility(item))
                contexts.addFilterItems(JS.contexts.listLine(item.fullTxt), filters.visibility(item))
            }
        }

    }

    property QtObject sorting: QtObject {
        property bool asc: sortSettings.asc
        onAscChanged: visualModel.resort()

        property int order: sortSettings.order
        onOrderChanged: visualModel.resort()

        //group by: 0..None, 1..projects, 2..contexts
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
                  return JS.projects.listLine(line)
              }]
            ,[qsTr("Contexts"),
              function(left, right) {
                  return groupFunctionList[1][1](left,right)
              },
              function(line) {
                  return JS.contexts.listLine(line)
              }]
        ]
    }

    signal editItem(int index)

    property string defaultPrio: "F"

    function setTaskProperty(id, prop, value) {
        var item = items.get(id)

        //priority up and down
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

        visualModel.model.setTaskProperty(item.model.index, prop, value)

        item.groups = "unsorted"
    }

    function removeItem(index) {
        visualModel.model.removeItem(model.index)
    }


    //return the positon of the item in the list due to function lessThanFunc
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
        console.log(unsortedItems.count)
        while (unsortedItems.count > 0) {
            var item = unsortedItems.get(0)
            defaultPrio = (!item.model.done && item.model.priority !== "" && item.model.priority.charCodeAt(0) > defaultPrio.charCodeAt(0)
                          ? item.model.priority : defaultPrio)

            if (filters.visibility(item.model)) {
                var index = insertPosition(lessThan, item)
                item.groups = ["items"]
                items.move(item.itemsIndex, index)
                console.log("added", item.model.fullTxt)
            } else item.groups = "invisible"
        }
        console.log(items.count, item.groups, filterOnGroup)
        filters.parseList()
    }

    function resort() {
        if (items.count > 0) items.setGroups(0, items.count, "unsorted")
        if (invisibleItems.count > 0) invisibleItems.setGroups(0, invisibleItems.count, "unsorted")
    }

    delegate: TaskListItem {
        done: model.done
        priority: model.priority
        creationDate: model.creationDate
        subject: model.formattedSubject
        due: model.due


        onToggleDone: setTaskProperty(model.index, "done", !model.done)
        onPrioUp: setTaskProperty(model.index, "priority", "up")
        onPrioDown: setTaskProperty(model.index, "priority", "down")
        onEditItem: visualModel.editItem(model.index)
        onRemoveItem: removeItem(model.intex)
    }    


    items.includeByDefault: false
    //filterOnGroup: "items"
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

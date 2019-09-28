import QtQuick 2.0
import QtQml.Models 2.1

import "../components"
import "../tdt/todotxt.js" as JS

DelegateModel {
    id: visualModel

    signal editItem(int index)

    property string defaultPrio: "F"

    function setTaskProperty(id, prop, value) {
//        var item = items.get(id)

//        //priority up and down
//        if (prop === "priority") {
//            var p =  item.model.priority
//            if (value === "up") {
//                if (p === "") value = String.fromCharCode(defaultPrio.charCodeAt(0) + 1);
//                else if (p > "A") value = String.fromCharCode(p.charCodeAt(0) - 1);
//            } else if (value === "down"){
//                if (p !== "" && p < "Z") value = String.fromCharCode(p.charCodeAt(0) + 1);
//                else value = ""
//            }
//        }

        visualModel.model.setTaskProperty(id, prop, value)

        //item.groups = "unsorted"
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
        //console.log(unsortedItems.count)
        while (unsortedItems.count > 0) {
            var item = unsortedItems.get(0)
            defaultPrio = (!item.model.done && item.model.priority !== "" && item.model.priority.charCodeAt(0) > defaultPrio.charCodeAt(0)
                          ? item.model.priority : defaultPrio)

            if (filters.visibility(item.model)) {
                var index = insertPosition(lessThan, item)
                item.groups = ["items"]
                items.move(item.itemsIndex, index)
                //console.log("added", item.model.fullTxt)
            } else item.groups = "invisible"
        }
        //console.log(items.count, item.groups, filterOnGroup)
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


        onToggleDone: setTaskProperty(model.id, "done", !model.done)
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

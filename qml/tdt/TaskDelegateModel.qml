import QtQuick 2.0
import QtQml.Models 2.1

import "qrc:/"
import "../tdt/todotxt.js" as JS

DelegateModel {
    id: visualModel

    signal editItem(int index)

    property string defaultPrio: "F"

    property var lessThanFunc: function (left, right) {
        return false
    }

    property var visibility: function (item) {
        return true
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
        console.log("sorting", unsortedItems.count)
        while (unsortedItems.count > 0) {
            var item = unsortedItems.get(0)
            defaultPrio = (!item.model.done && item.model.priority !== "" && item.model.priority.charCodeAt(0) > defaultPrio.charCodeAt(0)
                          ? item.model.priority : defaultPrio)

            if (visibility(item.model)) {
                var index = insertPosition(lessThan, item)
                item.groups = ["items"]
                items.move(item.itemsIndex, index)
                //console.log("added", item.model.fullTxt)
            } else item.groups = "invisible"
        }
        //console.log(items.count, item.groups, filterOnGroup)
        //filters.parseList()
    }

    function resort() {
        if (items.count > 0) items.setGroups(0, items.count, "unsorted")
        if (invisibleItems.count > 0) invisibleItems.setGroups(0, invisibleItems.count, "unsorted")
    }

    function resortItem(index) {
        for (var i = 0; i < items.count; i++) {
            var item = items.get(i)
            if (item.model.index == index) {
                item.groups = "unsorted"
                return
            }
        }
    }

    delegate: TaskListItem {
        done: model.done
        onToggleDone: model.done = !model.done
        priority: model.priority
        onPrioUp: setTaskProperty(model.index, "priority", "up")
        onPrioDown: setTaskProperty(model.index, "priority", "down")

        creationDate: model.creationDate
        subject: model.formattedSubject
        due: model.due


        onEditItem: visualModel.editItem(model.index)
        onRemoveItem: removeItem(model.intex)

        width: app.width
    }    


    items.includeByDefault: false
    //filterOnGroup: "items"
    groups: [
        DelegateModelGroup {
            id: unsortedItems
            name: "unsorted"
            includeByDefault: true
            onChanged: {
                visualModel.sort(lessThanFunc)
            }
        },
        DelegateModelGroup {
            id: invisibleItems
            name: "invisible"
        }
    ]
}

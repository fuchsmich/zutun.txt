import QtQuick 2.0
import QtQml.Models 2.1

import "qrc:/"
import "../tdt/todotxt.js" as JS

DelegateModel {
    id: visualModel

    //signal editItem(int index)

    property string defaultPrio: "F"

    property var lessThanFunc: function (left, right) {
        return false
    }

    property var visibility: function (item) {
        return true
    }

    function addTask(data) {
        console.log("diesdas")

        items.insert(0, data)
        var newItem = items.create(0)
        newItem.state = "add"
        console.log(newItem.state, newItem.item)
        newItem.item.forceActiveFocus()
    }

    function priorityUpDown(up) {

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
        //console.log("sorting", unsortedItems.count)
        while (unsortedItems.count > 0) {
            var item = unsortedItems.get(0)
            //console.log(item.model.index, item.groups, item.isUnresolved)
            if (visibility(item.model)) {
                if (item.model.priority.charCodeAt(0) > defaultPrio.charCodeAt(0)) defaultPrio = item.model.priority
                var index = insertPosition(lessThan, item)
                item.groups = ["items"]
                items.move(item.itemsIndex, index)
                //Duplicate items
                //model.get(item.model.index).section = "original"
//                if (!item.isUnresolved) {
//                    var data = JSON.parse(JSON.stringify(model.get(item.model.index)))
//                    //data.section = "clone"
//                    items.insert(JSON.parse(JSON.stringify(data)))
//                    console.log(JSON.stringify(data))
//                }
                //}
            } else item.groups = "invisible"
        }
    }

    function resort() {
        console.log("resort called")
//        for (var i = 0; i < persistedItems.count; i++) {
//            persistedItems.get(i).inPersistedItems = false
//        }
        if (items.count > 0) items.setGroups(0, items.count, "unsorted")
        if (invisibleItems.count > 0) invisibleItems.setGroups(0, invisibleItems.count, "unsorted")
    }

    function resortItem(index) {
        console.log("resort item", index)
        for (var i = 0; i < items.count; i++) {
            var item = items.get(i)
            if (item.model.index === index) {
                item.groups = "unsorted"
                return
            }
        }
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

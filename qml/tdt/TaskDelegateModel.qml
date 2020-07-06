import QtQuick 2.0
import QtQml.Models 2.1

import "qrc:/"
import "../tdt/todotxt.js" as JS

DelegateModel {
    id: visualModel

    signal sortFinished()

    property string defaultPriority: "F"

//desktop: move somewhere else
//    function addTaskItem(data) {
//        //console.log("diesdas")

//        items.insert(0, data)
//        var newItem = items.create(0)
//        newItem.state = "add"
//        //console.log(newItem.state, newItem.item)
//        newItem.item.forceActiveFocus()
//    }

//    function cancelAdd() {
//        items.remove(0, 1)
//    }

    //workaround: items.count doesnt seem to have a signal
    property int itemsCount: items.count
    onSortFinished: itemsCount = items.count

    property Filters filters: Filters {
        onFiltersChanged: resort("filters")
    }

    property Sorting sorting: Sorting {
        onSortingChanged: resort("sorting")
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
            if (filters.visibility(item.model)) {
                if (item.model.priority.charCodeAt(0) > defaultPriority.charCodeAt(0)) defaultPriority = item.model.priority
                var index = insertPosition(lessThan, item)
                item.groups = ["items"]
                items.move(item.itemsIndex, index)
            } else item.groups = "invisible"
        }
        sortFinished()
        console.debug("was dauert da so lang....")
    }

    function resort(reason) {
        console.log("resort called", unsortedItems.count, sorting.groupBy, reason)
        if (items.count > 0) items.setGroups(0, items.count, "unsorted")
        if (populatingItems.count > 0) populatingItems.setGroups(0, populatingItems.count, "unsorted")
        if (invisibleItems.count > 0) invisibleItems.setGroups(0, invisibleItems.count, "unsorted")
    }

    items.includeByDefault: false
    groups: [
        DelegateModelGroup {
            id: unsortedItems
            name: "unsorted"
            //includeByDefault: true
            onChanged: {
                console.debug(count, unsortedItems.get(count-1).model.fullTxt)

                visualModel.sort(sorting.lessThanFunc) // changed too late ?? lessThanFunc)
            }
        },
        DelegateModelGroup {
            id: populatingItems
            name: "populating"
            includeByDefault: true
            onChanged: {
                //visualModel.sort(sorting.lessThanFunc) // changed too late ?? lessThanFunc)
            }
        },
        DelegateModelGroup {
            id: invisibleItems
            name: "invisible"
        }
    ]
}

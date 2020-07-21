import QtQuick 2.0
import QtQml.Models 2.1

import "qrc:/"
import "../tdt/todotxt.js" as JS

DelegateModel {
    id: vm

    signal sortFinished()

    property string defaultPriority: "F"

    //workaround: items.count doesnt seem to have a signal
    property int itemsCount: items.count
    onSortFinished: itemsCount = items.count

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
        //console.debug("sorting", unsortedItems.count)
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
    }

    function resort(reason) {
        //console.debug("resort called", unsortedItems.count, sorting.groupBy, reason)
        if (items.count > 0) items.setGroups(0, items.count, "unsorted")
        if (invisibleItems.count > 0) invisibleItems.setGroups(0, invisibleItems.count, "unsorted")
    }

    function filter(group) {
        if (group) {
            while (group.count > 0) {
                var item = unsortedItems.get(0)
                item.groups = (taskListModel.filters.visibility(item.model) ? ["items"] : ["invisible"])
            }
        }
    }

    items.includeByDefault: false
    Connections {
        target: items
        onCountChanged: {
            console.log("items changed")
        }
    }

    groups: [
        DelegateModelGroup {
            id: unsortedItems
            name: "unsorted"
            includeByDefault: true
            onChanged: {
                vm.filter(unsortedItems)
            }
        },
        DelegateModelGroup {
            id: invisibleItems
            name: "invisible"
        }
    ]
}

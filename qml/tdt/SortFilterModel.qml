import QtQuick 2.0
import QtQml.Models 2.1

import "qrc:/"
import "../tdt/todotxt.js" as JS

DelegateModel {
    id: vm

    property var lessThanFunc: function(a,b){return true}
    onLessThanFuncChanged: update()
    property var visibilityFunc: function(item){return true}
    onVisibilityFuncChanged: update()


    function update() {
        items.setGroups(0, items.count, ["unsorted"])
        invisible.setGroups(0, invisible.count, ["unsorted"])
    }

    function insertPosition(item) {
        var lower = 0
        var upper = items.count
        while (lower < upper) {
            var middle = Math.floor(lower + (upper - lower)/2)
            var result =
                    lessThanFunc(item.model, items.get(middle).model)
            if (result) {
                upper = middle
            } else {
                lower = middle + 1
            }
        }
        return lower
    }

    items.includeByDefault: false
    persistedItems.onChanged: console.debug(persistedItems.count)

    groups: [
        DelegateModelGroup {
            id: unsorted
            name: "unsorted"
            includeByDefault: true
            onChanged: {
                console.debug(count)
                while (count > 0) {
                    var item = get(0)
                    console.debug(item.model.fullTxt, visibilityFunc(item.model))
                    if (visibilityFunc(item.model)) {
                        var index = insertPosition(item)
                        item.groups = ["items"]
                        items.move(item.itemsIndex, index)

                    } else item.groups = ["invisible"]
                }
            }
        },
        DelegateModelGroup {
            id: invisible
            name: "invisible"
            includeByDefault: false
        }
    ]
}

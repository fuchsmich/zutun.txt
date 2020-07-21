import QtQuick 2.0
import QtQml.Models 2.1

import "qrc:/"
import "../tdt/todotxt.js" as JS

DelegateModel {
    id: vm

    property var compareFunc: function(a,b){return true}
    property var visibilityFunc: function(item){return true}
    onVisibilityFuncChanged: update()


    function update() {
        for (var i = 0; i < allItems.count; i++) {
            var item = allItems.get(i)
            item.inItems = visibilityFunc(item.model)
            //console.log(item.model.fullTxt, visibilityFunc(item.model), item.groups)
        }
        sort()
    }

    //sort visible items
    function sort(compareFunc) {
        var indexes = []
        for (var i = 0; i < items.count; i++) indexes[i] = i
        console.debug(JSON.stringify(indexes))
        indexes.sort(function (a, b) {
            return vm.compareFunc(items.get(a).model, items.get(b).model)
        } )
        //console.debug(JSON.stringify(indexes))
        var sorted = 0
        while (sorted < indexes.length && sorted === indexes[sorted])
            sorted++
        console.debug(sorted, indexes)
        if (sorted === indexes.length) return
        for (i = sorted; i < indexes.length; i++) {
            var index = indexes[i]
            items.move(index, items.count - 1, 1)
            items.insert(index, { } ) //??
        }
        items.remove(sorted, indexes.length - sorted)
    }

    items.includeByDefault: false
    persistedItems.onChanged: console.debug(persistedItems.count)

    groups: [
        DelegateModelGroup {
            id: allItems
            name: "all"
            includeByDefault: true
            onChanged: update()
        }
    ]
}

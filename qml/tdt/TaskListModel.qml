import QtQuick 2.0

//import Sailfish.Silica 1.0

import "todotxt.js" as JS

ListModel {
    signal sortFinished()

    //0..init, 1..sorting, 2..ready
    property int status: 0
    property bool busy: status === 0 || status === 1

    property var sourceModel: []
    onSourceModelChanged: sort(sorting.lessThanFunc)
    property var projects: {
        return JS.projects.getList(sourceModel)
    }
    //onProjectsChanged: console.log("projects", projects)
    property var contexts: {
        return JS.contexts.getList(sourceModel)
    }

    property Filters filters: Filters {
        onFiltersChanged: resort("filters")
    }

    property Sorting sorting: Sorting {
        onSortingChanged: resort("sorting")
    }

    property string defaultPriority: "F"

    //return the positon of the item in the list due to function lessThanFunc
    function insertPosition(lessThanFunc, item) {
        var lower = 0
        var upper = count
        while (lower < upper) {
            var middle = Math.floor(lower + (upper - lower)/2)
            var result =
                    lessThanFunc(item, get(middle))
            if (result) {
                upper = middle
            } else {
                lower = middle + 1
            }
        }
        return lower
    }

    function sort(lessThan) {
        status = 1
        sourceModel.forEach(function(item){
            if (filters.visibility(item)) {
                if (item.priority.charCodeAt(0) > defaultPriority.charCodeAt(0))
                    defaultPriority = item.priority
                var index = insertPosition(lessThan, item)
                insert(index, item)
            }
        })
        sortFinished()
        status = 2
    }


    function resort(reason) {
        status = 1
        console.debug(reason)
        clear()
        sort(sorting.lessThanFunc)
    }
}

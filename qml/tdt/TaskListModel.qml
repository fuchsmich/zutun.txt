import QtQuick 2.0

//import Sailfish.Silica 1.0

import "todotxt.js" as JS

ListModel {
    signal sortFinished()

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
        sourceModel.forEach(function(item){
            if (filters.visibility(item)) {
                if (item.priority.charCodeAt(0) > defaultPriority.charCodeAt(0))
                    defaultPriority = item.priority
                var index = insertPosition(lessThan, item)
                insert(index, item)
            }
        })
        sortFinished()
    }


    function resort(reason) {
        console.debug(reason)
        clear()
        sort(sorting.lessThanFunc)
    }
}

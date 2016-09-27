import QtQuick 2.0

ListModel {
    id: lm
    property var assArray
    property var filter: []
    property string firstChar: ""
    onAssArrayChanged: populate();

    function populate() {
        clear();
        for ( var a in assArray) {
            if (a.charAt(0) == firstChar) {
                append( {"item": a, "noOfTasks": assArray[a].length,
                           "filterActive": (typeof filter === "undefined" ?
                                                false : filter.indexOf(a) !== -1),
                           "filterAvailable" : true //soll Filter in Filterliste geziegt werden?
                       });
            }
        }
    }

    function loadFilter(filterArray) {
        for (var f = 0; f < filterArray.length; f++) {
            for (var i =0; i < count; i++ ){
                if (get(i).item === filterArray[f]) setProperty(i, "filterActive", true);
            }
        }
    }

    function updateFilter() {
        var f = [];
        for (var i =0; i < count; i++ ){
            if (get(i).filterActive) f.push(get(i).item);
        }
        filter = f;
    }

    function resetFilter() {
        for (var i =0; i < count; i++ ){
            setProperty(i, "filterActive", false);
        }
    }

    onDataChanged: {
        updateFilter();
    }
}


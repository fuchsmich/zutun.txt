import QtQuick 2.0

ListModel {
    id: lm
    property var proConArray
    property var filter: []
    property string firstChar: ""
    property bool syncArrayAndModel: true
    onProConArrayChanged:{
        updateModel();
    }
    onFilterChanged: {
        updateModel();
    }
    onDataChanged: {
        updateFilter();
    }

    function updateModel() {
        if (syncArrayAndModel){
            syncArrayAndModel = false;
            //TODO doch in populate und update der filter bezogenen dinge unterscheiden
            clear();
            for ( var a in proConArray) {
                if (a.charAt(0) === firstChar) {
                    append( {"item": a,
                               "noOfTasks": noOfTasks(a, false),
                               "noOfVisibleTasks": noOfTasks(a, true),
                               "filterActive": (typeof filter === "undefined" ?
                                                    false : filter.indexOf(a) !== -1)
                               //, "filterAvailable" : true //soll Filter in Filterliste geziegt werden?
                           });
                }
            }
        }
        syncArrayAndModel = true;
    }

    function updateFilter() {
        if (syncArrayAndModel){
            syncArrayAndModel = false;
            var f = [];
            for (var i =0; i < count; i++ ){
                if (get(i).filterActive) f.push(get(i).item);
            }
            filter = f;
        }
        syncArrayAndModel = true;
    }

    function noOfTasks(filterName, onlyVisible) {
        var count = 0;
//        console.log(filterName, proConArray[filterName]);
        for (var i = 0; i < proConArray[filterName].length; i++) {
//            console.log(typeof proConArray[filterName][i], proConArray[filterName][i]);
            if (typeof proConArray[filterName][i] === "number") {
                if (!onlyVisible) count++;
                else if (tdt.filters.itemVisible(proConArray[filterName][i])) count++;
            }
        }
        return count;
    }

    //    function loadFilter(filterArray) {
    //        for (var f = 0; f < filterArray.length; f++) {
    //            for (var i =0; i < count; i++ ){
    //                if (get(i).item === filterArray[f]) setProperty(i, "filterActive", true);
    //            }
    //        }
    //    }

    function setFilter(index, value) {
        console.log(index);
        setProperty(index, "filterActive", value);
        updateFilter();
    }


    function resetFilter() {
        for (var i =0; i < count; i++ ){
            setProperty(i, "filterActive", false);
        }
        updateFilter();
    }

    //    onDataChanged: {
    //        updateFilter();
    //    }
}


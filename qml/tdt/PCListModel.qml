import QtQuick 2.0

ListModel {
    id: lm
    property var proConArray: []
    property var filter: []
    property string firstChar: ""
    property bool syncArrayAndModel: true
    onProConArrayChanged:{
        populateModel();
    }
    onFilterChanged: {
        updateModel();
    }
    onDataChanged: {
        updateFilter();
    }

    function populateModel() {
        if (syncArrayAndModel){
            syncArrayAndModel = false;
            //TODO doch in populate und update der filter bezogenen dinge unterscheiden
            clear();
            for ( var a in proConArray) {
                if (a.charAt(0) === firstChar) {
                    append( {"name": a,
                               "noOfTasks": noOfTasks(a, false),
                               "noOfVisibleTasks": noOfTasks(a, true),
                               "filterActive": (typeof filter === "undefined" ?
                                                    false : filter.indexOf(a) !== -1)
                           });
                }
            }
        }
        syncArrayAndModel = true;
    }

    function updateModel() {
        if (syncArrayAndModel){
            syncArrayAndModel = false;
            for (var i =0; i < count; i++ ){
                var a = get(i).name;
                console.log(a, proConArray)
                set(i, {"name": a,
                           "noOfTasks": noOfTasks(a, false),
                           "noOfVisibleTasks": noOfTasks(a, true),
                           "filterActive": (typeof filter === "undefined" ?
                                                false : filter.indexOf(a) !== -1)
                       });
            }
        }
        syncArrayAndModel = true;
    }

    function updateFilter() {
        console.log("updating filter")
        if (syncArrayAndModel){
            syncArrayAndModel = false;
            var f = [];
            for (var i =0; i < count; i++ ){
                if (get(i).filterActive) f.push(get(i).item);
            }
            console.log(f);
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
    //                if (get(i).name === filterArray[f]) setProperty(i, "filterActive", true);
    //            }
    //        }
    //    }

    function setFilter(index, value) {
        console.log(index);
        setProperty(index, "filterActive", value);
        updateModel();
    }


    function resetFilter() {
        for (var i =0; i < count; i++ ){
            setProperty(i, "filterActive", false);
        }
        updateModel();
    }

    //    onDataChanged: {
    //        updateFilter();
    //    }
}


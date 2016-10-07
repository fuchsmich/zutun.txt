import QtQuick 2.0

ListModel {
    id: lm
    property var proConArray: []
    onProConArrayChanged: populateModel();
    property var filter: []
    property string firstChar: ""
//    property bool syncArrayAndModel: true  //TODO weg damit
    signal filterModelChanged;
    onFilterModelChanged: {
        filter = getFilterArray();
        recalcNoOfTasks();
    }

    /* populate Model from proConArray */
    function populateModel() {
        console.log("populating");
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

    /* recalc noOfTasks due to filter Change */
    function recalcNoOfTasks() {
        for (var i =0; i < count; i++ ){
            var a = get(i).name;
//            console.log(a, proConArray)
            set(i, {"name": a,
                    "noOfTasks": noOfTasks(a, false),
                    "noOfVisibleTasks": noOfTasks(a, true),
                    "filterActive": get(i).filterActive
                });
        }
    }

    /* returns filter array from model */
    function getFilterArray() {
            var f = [];
            for (var i =0; i < count; i++ ){
                if (get(i).filterActive) f.push(get(i).name);
            }
            console.log(f);
            return f;
    }

    /*load filter array */
    function setFilterArray(filters) {
//        console.log(filters)
        lm.filter = filters;
        for (var f = 0; f < filters.length; f++) {
            for (var i =0; i < count; i++ ){
                if (filters[f] === get(i).name ) setProperty(i, "filterActive", true);
            }
        }
    }

    /* returns number of tasks containing filter and (which are currently visible) */
    function noOfTasks(filterName, onlyVisible) {
        if (onlyVisible === undefined) onlyVisible = false;
        var count = 0;
//        console.log(filterName, proConArray[filterName]);
        for (var i = 0; i < proConArray[filterName].length; i++) {
//            console.log(typeof proConArray[filterName][i], proConArray[filterName][i]);
            if (typeof proConArray[filterName][i] === "number") {
                if (!onlyVisible) count++;
    //item visible ist zu anfang nicht verfügbar. Funktion besser wo anders hin?
                else if (tdt.filters.itemVisible(proConArray[filterName][i])) count++;
            }
        }
        return count;
    }

    /* change filterActive value from GUI*/
    function setFilter(index, value) {
//        console.log(index);
        setProperty(index, "filterActive", value);        
        filterModelChanged();
    }

    /* change filterActive value from GUI*/
    function setSingleFilter(index, value) {
//        console.log(index);
        for (var i =0; i < count; i++ ){
            setProperty(i, "filterActive", (i === index? value : false));
        }
        filterModelChanged();
    }


    /* remove all filters */
    function resetFilter() {
//        console.log();
        for (var i =0; i < count; i++ ){
            setProperty(i, "filterActive", false);
        }
        filterModelChanged();
    }
}


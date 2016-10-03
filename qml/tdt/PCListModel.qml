import QtQuick 2.0

ListModel {
    id: lm
    property var proConArray
    property var filter: []
    property string firstChar: ""
    onProConArrayChanged: populate();

    function populate() {
        clear();
        for ( var a in proConArray) {
            if (a.charAt(0) === firstChar) {
                append( {"item": a, "noOfTasks": noOfTasks(a),
                           "filterActive": (typeof filter === "undefined" ?
                                                false : filter.indexOf(a) !== -1),
                           "filterAvailable" : true //soll Filter in Filterliste geziegt werden?
                       });
            }
        }
    }

    function noOfTasks(filterName) {
        var count = 0;
        console.log(filterName, proConArray[filterName]);
        for (var i = 0; i < proConArray[filterName].length; i++) {
            console.log(typeof proConArray[filterName][i], proConArray[filterName][i]);
            if (typeof proConArray[filterName][i] === "number" && tdt.filters.itemVisible(proConArray[filterName][i]) === true) {
                count++;
            }
        }
        return count;
    }

    function loadFilter(filterArray) {
        for (var f = 0; f < filterArray.length; f++) {
            for (var i =0; i < count; i++ ){
                if (get(i).item === filterArray[f]) setProperty(i, "filterActive", true);
            }
        }
    }

    function setFilter(index, value) {
        setProperty(index, "filterActive", value);
//        for (var i = 0; i < proConArray[get(index).item].length; i++) {

//        }
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


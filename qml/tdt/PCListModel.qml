import QtQuick 2.0

ListModel {
    id: lm
    property var assArray
    property var filter: []
    onAssArrayChanged: populate(assArray, filter);

    function populate(array, farray) {
//        console.log("popo", assArray, array.length)
        clear();

//        var i = 1;
        for ( var a in array) {
//            console.log(a);

            append( {"item": a, "noOfTasks": array[a].length,
                       "filter": (typeof farray === "undefined" ?
                                      false : farray.indexOf(a) !== -1)
//                       ,
//                       "tasks": array[a].toString(),
//                       "taskList": [{}]
                   });
//            for (var t in array[a]) {
////                console.log(get(i).taskList.count);
//                get(a).taskList.append({"taskIndex": array[a][t]});
//            }
//            i++;
        }
    }

    function loadFilter(filterArray) {
        for (var f = 0; f < filterArray.length; f++) {
            for (var i =0; i < count; i++ ){
                if (get(i).item === filterArray[f]) setProperty(i, "filter", true);
            }
        }
    }

    function updateFilter() {
        var f = [];
        for (var i =0; i < count; i++ ){
            if (get(i).filter) f.push(get(i).item);
        }
        filter = f;
    }

    function resetFilter() {
        for (var i =0; i < count; i++ ){
            setProperty(i, "filter", false);
        }
//        updateFilter();
    }

    onDataChanged: {
        updateFilter();
    }
}


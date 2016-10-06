import QtQuick 2.0
import Sailfish.Silica 1.0
import FileIO 1.0
import "todotxt.js" as JS

Item {
    id: tdt


    readonly property string alphabet: "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

    property string todoTxtLocation

    property ListModel tasksModel: _tasksModel
    property QtObject filters: _filters
    property ListModel projectModel: _filters.projectModel
    property ListModel contextModel: _filters.contextModel



    QtObject {
        id: _m
        readonly property int fullTxt: 0
        readonly property int done: 1
        readonly property int doneDate: 2
        readonly property int priority: 3
        readonly property int creationDate: 4
        readonly property int subject: 5

        property var taskList: [] // 2d array with fullTxt, done, doneDate, priority, creationDate, subject
        property var projects: [] //+ assoziertes Array
        property var contexts: [] //@ assoziertes Array
        property var proConArray: []
    }



    ListModel {
        id: _tasksModel

        property var assArray: _m.taskList
        onAssArrayChanged: populate(assArray);

        function populate(array) {
            for (var a = 0; a < array.length; a++) {
                //bestehende ersetzen
                if (a < count) set(a, { "id": a, "fullTxt": array[a][_m.fullTxt], "done": tdt.getDone(a),
                           "displayText": '<font color="' + tdt.getColor(a) + '">' + tdt.getPriority(a)+ '</font>'
                            + _m.taskList[a][_m.subject]
                       });
                //restliche anhängen
                else append( { "id": a, "fullTxt": array[a][_m.fullTxt], "done": tdt.getDone(a),
                                "displayText": '<b><font color="' + tdt.getColor(a) + '">' + tdt.getPriority(a)+ '</font></b>'
                                 + _m.taskList[a][_m.subject]
                            });
            }

            //Überzählige löschen
            if (a < count) remove(a, (count - a) )

        }
    }


    /* get done state */
    function getDone(index) {
        if (index >= 0 && index < _m.taskList.length) {
            return (typeof _m.taskList[index][_m.done] !== 'undefined' ? (_m.taskList[index][_m.done][0] === 'x') : false);
        } else throw "done: Index out of bounds."
    }

    function today() {
        return Qt.formatDate(new Date(),"yyyy-MM-dd");
    }



    /* set done state and done date */
    function setDone(index, value) {
        if (index >= 0 && index < _m.taskList.length) {
            if (value && !getDone(index))
                _m.taskList[index][_m.fullTxt] =
                        "x " + today() + " " + _m.taskList[index][_m.fullTxt];
            if (!value && getDone(index))
                _m.taskList[index][_m.fullTxt] =
                        _m.taskList[index][_m.fullTxt].match(/(x\s)?(\d{4}-\d{2}-\d{2}\s)?(.*)/)[3]; //Datum muss auch weg!!
            listToFile();
        } else throw "done: Index out of bounds."
    }

    /* delete todo item */
    function removeItem(index) {
        if (index >= 0 && index < _m.taskList.length) {
            var l = [];
            for (var t in _m.taskList) {
                if (t != index) {
                    l.push(_m.taskList[t]);
                }

            }
            _m.taskList = l;
            listToFile();
        } else throw "done: Index out of bounds."
    }

    /* get Priority */
    function getPriority(index) {
        if (index >= 0 && index < _m.taskList.length) {
            return (typeof _m.taskList[index][_m.priority] !== 'undefined' ? _m.taskList[index][_m.priority] : "");
        } else throw "done: Index out of bounds."
    }

    /* find lowest prio*/
    function lowestPrio() {
        var lp = "(A) ";
        for (var t in _m.taskList) {
            lp = (_m.taskList[t][_m.priority] > lp ? _m.taskList[t][_m.priority] : lp);
        }
        return lp;
    }

    /* return increased/decreased Priority-string */
    function incPrioString(p) {
        if (p[1] === alphabet[0]) return p;
        else return "(" + String.fromCharCode(p.charCodeAt(1) - 1) + ") ";
    }

    function decPrioString(p) {
        if (p[1] === alphabet[alphabet.length-1]) return p;
        else return "(" + String.fromCharCode(p.charCodeAt(1) + 1) + ") ";
    }

    function raisePriority(index) {
        if (_m.taskList[index][_m.priority] === undefined)
            _m.taskList[index][_m.fullTxt] = (decPrioString(lowestPrio()) + _m.taskList[index][_m.fullTxt]).trim();

        else if (_m.taskList[index][_m.priority][1] > alphabet[0])
            _m.taskList[index][_m.fullTxt] = incPrioString(_m.taskList[index][_m.priority])
                    + _m.taskList[index][_m.fullTxt].substr(4);

        else return;

        listToFile();
    }

    function lowerPriority(index) {

        if (_m.taskList[index][_m.priority] !== undefined) {
            if (_m.taskList[index][_m.priority][1] < alphabet[alphabet.length-1])
                _m.taskList[index][_m.fullTxt] = decPrioString(_m.taskList[index][_m.priority])
                        + _m.taskList[index][_m.fullTxt].substr(4);

            else if (_m.taskList[index][_m.priority][1] === alphabet[alphabet.length-1])
                _m.taskList[index][_m.fullTxt] = _m.taskList[index][_m.fullTxt].substr(4).trim();
        }

        else return;

        listToFile();
    }

    function setPriority(index, prio) {

    }


    ColorPicker {
        id: cp
    }

    /* get color due to Priority*/
    function getColor(index) {
        //            console.log(index, getPriority(index));
        if (index >= 0 && index < _m.taskList.length) {
            //                console.log(index, getPriority(index), cIndex);
            if (getPriority(index) === "") {
                if (getDone(index)) return Theme.secondaryColor;
                else return Theme.primaryColor;
            }
            //                var cIndex = alphabet.search(getPriority(index)[1]);
//                var cp = new ColorPicker();
            return cp.colors[alphabet.search(getPriority(index)[1]) % 15];
        } else throw "done: Index out of bounds."
    }


    /* set fulltext; index = -1 add Item */
    function setFullText(index, txt) {
        /*replace CR and LF; tasks always comprise a single line*/
        txt.replace(/\r/g," ");
        txt.replace(/\n/g," ");

        txt = txt.trim();

        if (txt !== "") {
            if (index === -1) _m.taskList.push([txt]);
            else _m.taskList[index][_m.fullTxt] = txt;
            listToFile();
        }
    }


    /* sort list and write it to the txtFile*/
    function listToFile() {
        _m.taskList.sort();
        var txt = "";
        for (var t in _m.taskList) {
            txt += _m.taskList[t][_m.fullTxt] + "\n";
        }
        //this writes to the file:
        todoTxtFile.content = txt;
    }


    QtObject {

        id: _filters
//        property string filterString: filterText()
        property bool hideCompletedTasks: filterSettings.hideCompletedTasks
        property var filters: projectModel.filter.concat(contextModel.filter)
        property ListModel projectModel:  PCListModel {
//            id: _projectModel
            proConArray: _m.proConArray
            firstChar: "+"
//            onFilterChanged: contextModel.updateModel()
        }

        property ListModel contextModel:         PCListModel {
//            id: _contextModel
            proConArray: _m.proConArray
            firstChar: "@"
//            onFilterChanged: projectModel.updateModel();
        }


        function loadFilters(p, c) {
            for (var f = 0; f < p.length; f++) {
                for (var i =0; i < projectModel.count; i++ ){
                    if (projectModel.get(i).name === filterArray[f]) projectModel.setProperty(i, "filterActive", true);
                }
            }
            for (var f = 0; f < c.length; f++) {
                for (var i =0; i < contextModel.count; i++ ){
                    if (contextModel.get(i).name === filterArray[f]) contextModel.setProperty(i, "filterActive", true);
                }
            }
        }

        function string() {
//            var pf = tdt.projectModel.filter.toString(), cf = tdt.contextModel.filter.toString();

//            var txt = pf + (pf === "" || cf === "" ? "" : "," ) + cf;
            var txt = filters.join(", ");
            if (txt === "" && hideCompletedTasks) return "Hiding Completed Tasks";
            return ( txt === "" ? "All Tasks" : txt );
        }

        /* returns the visibility in tasklist due to filters */
        function itemVisible(index) {
            //TODO
            var pfilter = projectModel.filter
            var cfilter = contextModel.filter
//            var pc = _m

//            index = index.toString();
            /* filter completed?*/
            var dvis = !(hideCompletedTasks && _m.taskList[index][_m.done] !== undefined);

            var cvis = (cfilter.length === 0), pvis = (pfilter.length === 0);
            for (var p in pfilter) {
                console.log(index, pvis, pfilter, _m.proConArray ) //, projects[pfilter[p]].indexOf(index));
                pvis = pvis || (_m.proConArray[pfilter[p]].indexOf(index) !== -1)
            }
            for (var c in cfilter) {
                cvis = cvis || (_m.proConArray[cfilter[c]].indexOf(index) !== -1)
            }

//            console.log(index, pvis, cvis, dvis)
            return pvis && cvis && dvis;
        }
    }


    function reloadTodoTxt() {
        todoTxtFile.contentChanged();
    }

    FileIO {
        id: todoTxtFile
        path: settings.todoTxtLocation
        onContentChanged:{
            var lists = JS.parseTodoTxt(content);
            console.log(lists.proConArray)
            _m.taskList = lists.taskList;
            _m.projects = lists.projects;
            _m.contexts = lists.contexts;
            _m.proConArray = lists.proConArray;
        }

    }
}

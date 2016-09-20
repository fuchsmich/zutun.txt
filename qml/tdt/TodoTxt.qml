import QtQuick 2.0
import Sailfish.Silica 1.0
import FileIO 1.0
import "todotxt.js" as JS

Item {
    id: tdt

    readonly property int fullTxt: 0
    readonly property int done: 1
    readonly property int doneDate: 2
    readonly property int priority: 3
    readonly property int creationDate: 4
    readonly property int subject: 5

    readonly property string alphabet: "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

    property string todoTxtLocation

    property ListModel tasksModel: _tasksModel
    property ListModel projectModel: _projectModel
    property ListModel contextModel: _contextModel
    property QtObject filters: _filters


    property var taskList: [] // 2d array with fullTxt, done, doneDate, priority, creationDate, subject
    property var projects: [] //+ assoziertes Array
    property var contexts: [] //@ assoziertes Array


//    property string lowestPrio: "(A) "

    /* find lowest prio*/
    function lowestPrio() {
        var lp = "(A) ";
        for (var t in taskList) {
            lp = (taskList[t][priority] > lp ? taskList[t][priority] : lp);
        }
        return lp;
    }

    ListModel {
        id: _tasksModel

        property var assArray: tdt.taskList
        onAssArrayChanged: populate(assArray);

        function populate(array) {
            for (var a = 0; a < array.length; a++) {
                //bestehende ersetzen
                if (a < count) set(a, { "id": a, "fullTxt": array[a][tdt.fullTxt], "done": tdt.getDone(a),
                           "displayText": '<font color="' + tdt.getColor(a) + '">' + tdt.getPriority(a)+ '</font>'
                            + tdt.taskList[a][tdt.subject]
                       });
                //restliche anhängen
                else append( { "id": a, "fullTxt": array[a][tdt.fullTxt], "done": tdt.getDone(a),
                                "displayText": '<b><font color="' + tdt.getColor(a) + '">' + tdt.getPriority(a)+ '</font></b>'
                                 + tdt.taskList[a][tdt.subject]
                            });
            }

            //Überzählige löschen
            if (a < count) remove(a, (count - a) )

        }
    }

    PCListModel {
        id: _projectModel
        assArray: tdt.projects
//        filter: filterSettings.projectFilter
    }

    PCListModel {
        id: _contextModel
        assArray: tdt.contexts
//        filter: filterSettings.contextFilter
    }

    /* get done state */
    function getDone(index) {
        if (index >= 0 && index < taskList.length) {
            return (typeof taskList[index][done] !== 'undefined' ? (taskList[index][done][0] === 'x') : false);
        } else throw "done: Index out of bounds."
    }

    function today() {
        return Qt.formatDate(new Date(),"yyyy-MM-dd");
    }



    /* set done state and done date */
    function setDone(index, value) {
        if (index >= 0 && index < taskList.length) {
            if (value && !getDone(index))
                taskList[index][fullTxt] =
                        "x " + today() + " " + taskList[index][fullTxt];
            if (!value && getDone(index))
                taskList[index][fullTxt] =
                        taskList[index][fullTxt].match(/(x\s)?(\d{4}-\d{2}-\d{2}\s)?(.*)/)[3]; //Datum muss auch weg!!
            listToFile();
        } else throw "done: Index out of bounds."
    }

    /* delete todo item */
    function removeItem(index) {
        if (index >= 0 && index < taskList.length) {
            var l = [];
            for (var t in taskList) {
                if (t != index) {
                    l.push(taskList[t]);
                }

            }
            taskList = l;
            listToFile();
        } else throw "done: Index out of bounds."
    }

    /* get Priority */
    function getPriority(index) {
        if (index >= 0 && index < taskList.length) {
            return (typeof tdt.taskList[index][tdt.priority] !== 'undefined' ? tdt.taskList[index][tdt.priority] : "");
        } else throw "done: Index out of bounds."
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
        if (taskList[index][priority] === undefined)
            taskList[index][fullTxt] = (decPrioString(lowestPrio()) + taskList[index][fullTxt]).trim();

        else if (taskList[index][priority][1] > alphabet[0])
            taskList[index][fullTxt] = incPrioString(taskList[index][priority])
                    + taskList[index][fullTxt].substr(4);

        else return;

        listToFile();
    }

    function lowerPriority(index) {

        if (taskList[index][priority] !== undefined) {
            if (taskList[index][priority][1] < alphabet[alphabet.length-1])
                taskList[index][fullTxt] = decPrioString(taskList[index][priority])
                        + taskList[index][fullTxt].substr(4);

            else if (taskList[index][priority][1] === alphabet[alphabet.length-1])
                taskList[index][fullTxt] = taskList[index][fullTxt].substr(4).trim();
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
        if (index >= 0 && index < taskList.length) {
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
            if (index === -1) taskList.push([txt]);
            else taskList[index][fullTxt] = txt;
            listToFile();
        }
    }


    /* sort list and write it to the txtFile*/
    function listToFile() {
        taskList.sort();
        var txt = "";
        for (var t in taskList) {
            txt += taskList[t][fullTxt] + "\n";
        }
        //this writes to the file:
        todoTxtFile.content = txt;
    }

    QtObject {
        id: _filters
//        property string filterString: filterText()
        property bool hideCompletedTasks: filterSettings.hideCompletedTasks

        property var pfilter: tdt.projectModel.filter
        property var cfilter: tdt.contextModel.filter

        function string() {
            var pf = tdt.projectModel.filter.toString(), cf = tdt.contextModel.filter.toString();

            var txt = pf + (pf === "" || cf === "" ? "" : "," ) + cf;
            if (txt === "" && hideCompletedTasks) return "Hiding Completed Tasks";
            return ( txt === "" ? "All Tasks" : txt );
        }

        /* returns the visibility in tasklist due to filters */
        function itemVisible(index) {
            index = index.toString();
            var dvis = !(hideCompletedTasks && tdt.taskList[index][tdt.done] !== undefined);
            var cvis = (cfilter.length === 0), pvis = (pfilter.length === 0);
            for (var p in pfilter) {
                pvis = pvis || (tdt.projects[pfilter[p]].indexOf(index) !== -1)
//                console.log(index, pvis, pfilter[p], projects[pfilter[p]], typeof index, projects[pfilter[p]].indexOf(index));
            }
            for (var c in cfilter) {
//                console.log(index, cvis, cfilter[c], contexts[cfilter[c]], typeof index, contexts[cfilter[c]].indexOf(index));
                cvis = cvis || (tdt.contexts[cfilter[c]].indexOf(index) !== -1)
            }

//            console.log(pvis, cvis, dvis)
            return pvis && cvis && dvis;
        }
    }


    FileIO {
        id: todoTxtFile
        path: settings.todoTxtLocation
        onContentChanged:{
            var lists = JS.parseTodoTxt(content);
            taskList = lists.taskList;
            projects = lists.projects;
            contexts = lists.contexts;
        }

    }
}

import QtQuick 2.0
import Sailfish.Silica 1.0
import "pages"
import org.nemomobile.configuration 1.0

import FileIO 1.0

//TODO archive to done.txt
//TODO fehler über notifiactions ausgeben



ApplicationWindow
{
    id: app
    initialPage: taskListPage

    TaskList {
        id: taskListPage
    }

    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: Orientation.All
    _defaultPageOrientations: Orientation.All


    ConfigurationGroup {
        //TODO filter p+c+d speichern
        id: settings
        path: "/apps/harbour-zutun/settings"
        property string todoTxtLocation: StandardPaths.documents + '/todo.txt'
        property string doneTxtLocation: StandardPaths.documents + '/done.txt'
        property bool autoSave: true
        Component.onCompleted: {
            console.log("settings", path, todoTxtLocation, doneTxtLocation, autoSave)
        }
    }


    Item {
        id: tdt
        property var initialPage

        readonly property int fullTxt: 0
        readonly property int done: 1
        readonly property int doneDate: 2
        readonly property int priority: 3
        readonly property int creationDate: 4
        readonly property int subject: 5

        readonly property string alphabet: "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

        property url source: StandardPaths.documents + '/todo.txt'
        property var taskList: []
        property var contexts: [] //@
        property var projects: [] //+
        property var pfilter: []
        property var cfilter: []
        onCfilterChanged: console.log(cfilter)
        onPfilterChanged: console.log(cfilter)
        property string filterString: filterText(pfilter, cfilter)
        property bool filterDone: false
        onFilterDoneChanged: console.log(filterDone)

        property string lowestPrio: "(A) "

        onLowestPrioChanged: console.log(lowestPrio)



        function filterText() {
            var txt = (pfilter.toString() + (cfilter.toString() === "" ? "" : "," + cfilter.toString()));
            return ( txt === "" ? "All Projects" : txt );
        }

        function getProjectList() {
            var list = [];
            for (var p in projects) {
                list.push(p);
            }
            return list;
        }

        function getContextList() {
            var list = [];
            for (var c in contexts) {
                list.push(c);
            }
            return list;
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

        /* add/remove done state and done date */
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
                taskList[index][fullTxt] = (decPrioString(lowestPrio) + taskList[index][fullTxt]).trim();

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


        /* get color due to Priority*/
        ColorPicker {
            id: cp
        }

        function getColor(index) {
            //            console.log(index, getPriority(index));
            if (index >= 0 && index < taskList.length) {
                //                console.log(index, getPriority(index), cIndex);
                if (getPriority(index) === "") {
                    if (getDone(index)) return Theme.secondaryColor;
                    else return Theme.primaryColor;
                }
                //                var cIndex = alphabet.search(getPriority(index)[1]);
                return cp.colors[alphabet.search(getPriority(index)[1]) % 15];
            } else throw "done: Index out of bounds."
        }


        /* set fulltext; index = -1 add Item */
        function setFullText(index, txt) {
            /*replace CR and LF; tasks always comprise a single line*/
            txt.replace(/\r/g," ");
            txt.replace(/\n/g," ");

            txt = txt.trim();

            //TODO leerer Text: bestehendes todo löschen, wenn text leer
            if (txt !== "") {
                if (index === -1) taskList.push([txt]);
                else taskList[index][fullTxt] = txt;
                listToFile();
            }
        }

        /* returns the visibility in tasklist due to filters */
        function visibleOnFilter(index) {
            index = index.toString();
            var dvis = !(filterDone && taskList[index][done] !== undefined);
            var cvis = (cfilter.length == 0), pvis = (pfilter.length == 0);
            for (var p in pfilter) {
                pvis = pvis || (projects[pfilter[p]].indexOf(index) !== -1)
                console.log(pvis, pfilter[p], projects[pfilter[p]], typeof index, projects[pfilter[p]].indexOf(index));
            }
            for (var c in cfilter) {
                cvis = cvis || (contexts[cfilter[c]].indexOf(index) !== -1)
            }

            return pvis && cvis && dvis;
        }

        /* sort list and write it to the txtFile*/
        function listToFile() {
            taskList.sort();
            var txt = "";
            for (var t in taskList) {
                txt += taskList[t][fullTxt] + "\n";
            }
            todoTxtFile.content = txt;
        }


        /* parse plain Text*/
        function parseTodoTxt(todoTxt) {
            projects = [];
            contexts = [];
            var list = [];
            var tasks = todoTxt.split("\n");
            tasks.sort();


            //clean lines
            for (var t in tasks) {
                var txt = tasks[t].trim();
                if (txt.length !== 0) list.push(txt);
            }
            tasks = list;

            //parse lines
            list = [];
            for (t in tasks) {
                //                console.log(t, tasks[t]);
                var txt = tasks[t];

                //alles auf einmal fullTxt, done, doneDate, priority, creationDate, subject
                var matches = txt.match(/^(x\s)?(\d{4}-\d{2}-\d{2}\s)?(\([A-Z]\)\s)?(\d{4}-\d{2}-\d{2}\s)?(.*)/);
                list.push(matches);


                /* find lowest prio*/
                lowestPrio = (matches[priority] > lowestPrio ? matches[priority] : lowestPrio);


                /* collect projects (+) and contexts (@)*/
                var m;
                var pmatches = matches[subject].match(/\s\+\w+(\s|$)/g);
                for (var p in pmatches) {
                    m = pmatches[p].toUpperCase().trim();
//                    console.log(pmatches[p].toUpperCase(), projects);
                    if (typeof projects[m] === 'undefined') projects[m] = [];
                    projects[m].push(t);
//                    console.log(m, projects[m]);
                }

                var cmatches = matches[subject].match(/\s@\w+(\s|$)/g);
                for (var c in cmatches) {
                    m = cmatches[c].toUpperCase().trim();
//                    console.log(m);
                    if (typeof contexts[m] === 'undefined') contexts[m] = [];
                    contexts[m].push(t);
//                    console.log(m, contexts[m]);
                }
                //                console.log(t, pmatches, proj, cmatches);



            }
//            console.log(contexts)
            projects.sort();
            contexts.sort();
            taskList = list;
        }


        FileIO {
            id: todoTxtFile
            path: settings.todoTxtLocation
            onContentChanged: tdt.parseTodoTxt(content);
        }
    }
}




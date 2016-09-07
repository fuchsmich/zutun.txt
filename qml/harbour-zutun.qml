import QtQuick 2.0
import Sailfish.Silica 1.0
import "pages"
import org.nemomobile.configuration 1.0

import FileIO 1.0

//TODO set prio
//TODO filters
//TODO archive to done.txt

ApplicationWindow
{
    id: app
    initialPage: Component { FirstPage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: Orientation.All
    _defaultPageOrientations: Orientation.All


    ConfigurationGroup {
        id: settings
        property string todoTxtLocation: StandardPaths.documents + '/todo.txt'
    }


    Item {
        id: tdt
        readonly property int fullTxt: 0
        readonly property int done: 1
        readonly property int doneDate: 2
        readonly property int priority: 3
        readonly property int creationDate: 4
        readonly property int subject: 5

        readonly property string alphabet: "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

        property url source: StandardPaths.documents + '/todo.txt'
        property string error: ''
        property var taskList: []
        property var contexts: [] //+
        property var projects: [] //@
        property string pfilter: ""
        property string lowestPrio: "(A) "

        function getProjectList() {
            var list = [];
            for (var p in projects) {
                list.push(p);
            }
            return list;
        }

//        onTaskListChanged: {
//            console.log("tlc");
//            listToFile();
//        }


        Item {
            /* private stuff */
            id: m
//            property bool noSyncToFile: false
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
            return "(" + String.fromCharCode(p.charCodeAt(1) - 1) + ") "
        }

        function decPrioString(p) {
            return "(" + String.fromCharCode(p.charCodeAt(1) + 1) + ") "
        }

        //TODO !!crash beim erhöhen/erniedrigen... bzw. dann in listToFile
        function raisePriority(index) {
            console.log("raising")
            if (taskList[index][priority] === undefined)
                taskList[index][fullTxt] = (decPrioString(lowestPrio) + taskList[index][fullTxt]).trim();
            else if (taskList[index][priority][1] > alphabet[0]);
                taskList[index][fullTxt] = (incPrioString(taskList[index][priority]) +
                        + taskList[index][fullTxt].substr(4)).trim();
            listToFile();
        }

        function lowerPriority(index) {
            if (taskList[index][priority] !== undefined && taskList[index][priority] < alphabet[0])
                taskList[index][fullTxt] = (decPrioString(taskList[index][priority])
                        + taskList[index][fullTxt].substr(4)).trim();
            else if (taskList[index][priority] !== undefined && taskList[index][priority] === alphabet[0])
                taskList[index][fullTxt] =
                        (taskList[index][fullTxt].substr(4)).trim();
            listToFile();
        }

        function setPriority(index, prio) {

        }

        /* get color due to Priority*/
        ColorPicker {
            id: cp
            Component.onCompleted: console.log(colors.length)
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

            //TODO leeren Text besser behandeln...
            if (txt !== "") {
                if (index === -1) taskList.push([txt]);
                else taskList[index][fullTxt] = txt;
                listToFile();
            }
        }

        /* sort list and write it to the txtFile*/
        function listToFile() {
            console.log("taskList");
//            if (m.noSyncToFile) return;
            taskList.sort();
            var txt = "";
            for (var t in taskList) {
                txt += taskList[t][fullTxt] + "\n";
            }
//            console.log("setting content");
            todoTxtFile.content = txt;
        }


        /* parse plain Text*/
        function parseTodoTxt(todoTxt) {
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


                /* collect projects and contexts */
                var m;
                var pmatches = matches[subject].match(/\s@\w+(\s|$)/g);
                for (var p in pmatches) {
                    m = pmatches[p].toUpperCase().trim();
                    console.log(pmatches[p].toUpperCase(), projects, contexts);
                    if (typeof projects[m] === 'undefined') projects[m] = [];
                    projects[m].push(t);
                }

                var cmatches = matches[subject].match(/\s\+\w+\s/g);
                for (var c in cmatches) {
                    m = cmatches[c].toUpperCase().trim();
                    if (typeof contexts[m] === 'undefined') contexts[m] = [];
                    contexts[m].push(t);
//                    console.log(cmatches[c].toUpperCase(), contexts[cmatches[c].toUpperCase()]);
                }
//                console.log(t, pmatches, proj, cmatches);



            }
            //            console.log("list", list);
//            m.noSyncToFile = true;
            console.log(list);
            //TODO hier crashts
            taskList = list;
//            m.noSyncToFile = false;
        }


        FileIO {
            id: todoTxtFile
            path: StandardPaths.documents + '/todo.txt'
            onContentChanged: tdt.parseTodoTxt(content);
        }
    }

    Component.onCompleted: {
        console.log(pageStack.currentPage)
    }
}




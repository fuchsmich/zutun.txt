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
        property var pfilter: []

        function getProjectList() {
            var list = [];
            for (var p in projects) {
                list.push(p);
            }
            return list;
        }

        onTaskListChanged: listToFile();


        Item {
            /* private stuff */
            id: m
            property bool noSyncToFile: false
        }


        /* get done state */
        function getDone(index) {
            if (index >= 0 && index < taskList.length) {
                return (typeof taskList[index][done] !== 'undefined' ? (taskList[index][done][0] === 'x') : false);
            } else throw "done: Index out of bounds."
        }

        /* add/remove done state and done date */
        function setDone(index, value) {
//            console.log(Qt.formatDate(new Date(),"yyyy-MM-dd"));
            if (index >= 0 && index < taskList.length) {
                if (value && !getDone(index))  taskList[index][fullTxt] = "x " + Qt.formatDate(new Date(),"yyyy-MM-dd") + " " + taskList[index][fullTxt];
                if (!value && getDone(index)) taskList[index][fullTxt] = taskList[index][fullTxt].match(/(x\s)?(\d{4}-\d{2}-\d{2}\s)?(.*)/)[3]; //Datum muss auch weg!!
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
                        //                        console.log(typeof t, t, typeof index, index);
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

        function raisePriority(index) {

        }

        function lowerPriority(index) {

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
                return cp.colors[alphabet.search(getPriority(index)[1])];
            } else throw "done: Index out of bounds."
        }

        /*  */
        function setFullText(index, txt) {
            /*replace CR and LF; tasks always comprise a single line*/
            txt.replace(/\r/g," ");
            txt.replace(/\n/g," ");

            taskList[index][fullTxt] = txt;
            listToFile();
        }

        /* sort list and write it to the txtFile*/
        function listToFile() {
            taskList.sort();
            if (m.noSyncToFile) return;
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

                var pmatches = matches[subject].match(/\s@\w+\s/g);
                for (var p in pmatches) {
                    var m = pmatches[p].toUpperCase().trim();
                    if (typeof projects[m] == 'undefined') projects[m] = [];
                    projects[m].push(t);
//                    console.log(pmatches[p].toUpperCase(), projects[pmatches[p].toUpperCase()]);
                }

                var cmatches = matches[subject].match(/\s\+\w+\s/g);
                for (var c in cmatches) {
                    var m = cmatches[c].toUpperCase().trim();
                    if (typeof contexts[m] == 'undefined') contexts[m] = [];
                    contexts[m].push(t);
//                    console.log(cmatches[c].toUpperCase(), contexts[cmatches[c].toUpperCase()]);
                }
//                console.log(t, pmatches, projects, cmatches);



            }
            //            console.log("list", list);
            m.noSyncToFile = true;
            taskList = list;
            m.noSyncToFile = false;
        }


        FileIO {
            id: todoTxtFile
            path: StandardPaths.documents + '/todo.txt'
            onContentChanged: tdt.parseTodoTxt(content);
        }
    }
}




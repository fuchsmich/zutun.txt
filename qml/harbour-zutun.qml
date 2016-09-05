import QtQuick 2.0
import Sailfish.Silica 1.0
import "pages"
import org.nemomobile.configuration 1.0

import FileIO 1.0

//TODO edit
//TODO set prio
//TODO filters

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
//        property string todoTxt: ''
        property string error: ''
        property var todoList: []
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

//        onTodoTxtChanged: parseTodoTxt();
        onTodoListChanged: listToFile();

        Item {
            id: m
            property bool noSyncToFile: false
        }

        function listToFile() {
            todoList.sort();
            if (m.noSyncToFile) return;
            var txt = "";
            for (var t in todoList) {
                txt += todoList[t][fullTxt] + "\n";
            }
//            console.log("setting content");
            todoTxtFile.content = txt;
        }

        function getDone(index) {
            if (index >= 0 && index < todoList.length) {
                return (typeof tdt.todoList[index][tdt.done] !== 'undefined' ? (tdt.todoList[index][tdt.done][0] === 'x') : false);
            } else throw "done: Index out of bounds."
        }

        function setDone(index, value) {
            //TODO datum setzen
//            console.log(Qt.formatDate(new Date(),"yyyy-MM-dd"));
            if (index >= 0 && index < todoList.length) {
                if (value && !getDone(index))  todoList[index][fullTxt] = "x " + Qt.formatDate(new Date(),"yyyy-MM-dd") + " " + todoList[index][fullTxt];
                if (!value && getDone(index)) todoList[index][fullTxt] = todoList[index][fullTxt].match(/(x\s)?(\d{4}-\d{2}-\d{2}\s)?(.*)/)[3]; //Datum muss auch weg!!
                listToFile();
            } else throw "done: Index out of bounds."
        }

        function removeItem(index) {
            if (index >= 0 && index < todoList.length) {
                var l = [];
                for (var t in todoList) {
                    if (t != index) {
                        l.push(todoList[t]);
                        //                        console.log(typeof t, t, typeof index, index);
                    }

                }
                todoList = l;
            } else throw "done: Index out of bounds."
        }


        function getPriority(index) {
            if (index >= 0 && index < todoList.length) {
                return (typeof tdt.todoList[index][tdt.priority] !== 'undefined' ? tdt.todoList[index][tdt.priority] : "");
            } else throw "done: Index out of bounds."
        }


        ColorPicker {
            id: cp
        }

        function getColor(index) {
//            console.log(index, getPriority(index));
            if (index >= 0 && index < todoList.length) {
//                console.log(index, getPriority(index), cIndex);
                if (getPriority(index) === "") {
                    if (getDone(index)) return Theme.secondaryColor;
                    else return Theme.primaryColor;
                }
//                var cIndex = alphabet.search(getPriority(index)[1]);
                return cp.colors[alphabet.search(getPriority(index)[1])];
            } else throw "done: Index out of bounds."
        }

        function parseTodoTxt(todoTxt) {
            var list = [];
            var todos = todoTxt.split("\n");
            todos.sort();


            //clean lines
            for (var t in todos) {
                var txt = todos[t].trim();
                if (txt.length !== 0) list.push(txt);
            }
            todos = list;

            //parse lines
            list = [];
            for (t in todos) {
                //                console.log(t, todos[t]);
                var txt = todos[t];

                //alles auf einmal fullTxt, done, doneDate, priority, creationDate, subject
                var matches = txt.match(/^(x\s)?(\d{4}-\d{2}-\d{2}\s)?(\([A-Z]\)\s)?(\d{4}-\d{2}-\d{2}\s)?(.*)/);
                list.push(matches);

                var pmatches = matches[subject].match(/@\w+/g);
                for (var p in pmatches) {
                    if (typeof projects[pmatches[p].toUpperCase()] == 'undefined') {
                        projects[pmatches[p].toUpperCase()] = [];
                    }
                    projects[pmatches[p].toUpperCase()].push(t);
//                    console.log(pmatches[p].toUpperCase(), projects[pmatches[p].toUpperCase()]);
                }

                var cmatches = matches[subject].match(/\+\w+/g);
                for (var c in cmatches) {
                    if (typeof contexts[cmatches[c].toUpperCase()] == 'undefined') {
                        contexts[cmatches[c].toUpperCase()] = [];
                    }
                    contexts[cmatches[c].toUpperCase()].push(t);
//                    console.log(cmatches[c].toUpperCase(), contexts[cmatches[c].toUpperCase()]);
                }
//                console.log(t, pmatches, projects, cmatches);



            }
            //            console.log("list", list);
            m.noSyncToFile = true;
            todoList = list;
            m.noSyncToFile = false;
        }


        FileIO {
            id: todoTxtFile
            path: StandardPaths.documents + '/todo.txt'
            onContentChanged: tdt.parseTodoTxt(content);
        }
    }
}




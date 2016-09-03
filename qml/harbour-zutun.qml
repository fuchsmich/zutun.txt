import QtQuick 2.0
import Sailfish.Silica 1.0
import "pages"
import org.nemomobile.configuration 1.0


ApplicationWindow
{
    initialPage: Component { FirstPage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: Orientation.All
    _defaultPageOrientations: Orientation.All

    ConfigurationGroup {
        id: settings
        property string todoTxtLocation: '/home/nemo/Documents/todo.txt'
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

        property string source: settings.todoTxtLocation
        property string todoTxt: ''
        property string error: ''
        property var todoList: []
        property var contexts: [] //+
        property var projects: [] //@

        onTodoTxtChanged: parseTodoTxt();

        function getDone(index) {
            if (index >= 0 && index < todoList.length) {
                return (typeof tdt.todoList[index][tdt.done] !== 'undefined' ? (tdt.todoList[index][tdt.done][0] === 'x') : false);
            } else throw "done: Index out of bounds."
        }

        function setDone(index, value) {
            //TODO datum ??
            if (value && !getDone(index))  todoList[index][fullTxt] = "x " + todoList[index][fullTxt];
            if (!value && getDone(index)) todoList[index][fullTxt] = todoList[index][fullTxt].substr(2);
            listToTodoTxt();
        }

        function listToTodoTxt() {
            var txt = "";
            for (var t in todoList) {
                txt += todoList[t][fullTxt] + "\n";
            }
            todoTxt = txt;
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

        function parseTodoTxt() {
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
                var cmatches = matches[subject].match(/\+\w+/g);
                console.log(t, pmatches, cmatches);


            }
            //            console.log("list", list);
            todoList = list;
            //            sortList();
        }

        function sortList(keys) {
            //            var key = keys[0];
            var list = todoList;
            //            console.log("list",list.toString())
            list.sort(function(a,b){
                if (a[0] !== b[0]) {
                    //                    console.log(a[0] - b[0]);
                    return a[0] - b[0];
                } else if (a[1] !== b[1]) {
                    if (a[1] === "") return  0;
                    if (b[1] === "") return -1;
                    return (a[1] < b[1])*-1;
                } else if (a[2] !== b[2]) {
                    if (a[2] === "") return  0;
                    if (b[2] === "") return -1;
                    return (a[2] < b[2])*-1;
                }
                return 0;
            })
            //            console.log("list",list.toString())
            todoList = list;
        }

        function remove(index) {
            //            console.log(todoList);
            var l = [];
            if (index >= 0 && index < todoList.length) {
                for (var t in todoList) {
                    if (t != index) {
                        l.push(todoList[t]);
                        //                        console.log(typeof t, t, typeof index, index);
                    }

                }
            } else return false;
            todoList = l;
            //            console.log(todoList);
        }

        function getText() {
            var xhr = new XMLHttpRequest;
            //            console.log("gt");
            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    //                console.log("xhr", xhr.responseText);
                    error = '';
                    todoTxt = xhr.responseText;
                    //                    } else {
                    //                        error = xhr.statusText;
                    //                        console.log("error: ", error);
                }
            }
            xhr.open("GET", source);
            xhr.send();
        }
        onSourceChanged: getText();
        Component.onCompleted: getText();
    }
}




/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

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

    ListModel {
        id: todoModel
        property string source: settings.todoTxtLocation
        property string todoTxt: ''
        property string error: ''
        property var todoList: []
        property var contexts: [] //+
        property var projects: [] //@

        onTodoTxtChanged: parsetodoTxt();


        function parsetodoTxt() {
            var list = [];
            var todos = todoTxt.split("\n");
            console.log(todos.toString());

            for (var t in todos) {
//                console.log(todos[t]);

                var txt = todos[t].trim();
                //leere Zeilen weg:
                if (txt.length === 0) break;

                //done?
                var matches = txt.match(/^(x\s)?(.*)/);
                txt = matches[2].trim();
                var done = false; if (typeof matches[1] === "string" && matches[1][0] === "x") done = true;
                console.log("done", typeof matches[1],matches[1], done);

                //priority?
                matches = txt.match(/^\([A-Z]\)\s/);
                var priority = (matches !== null ? matches[0][1] : "");
                console.log("prio:", priority);

                //creationdate?
                matches = txt.match(/^(\([A-Z]\)\s)?(\d{4}-\d{2}-\d{2})/);
                var date  = (matches !== null  ? matches[2] : "") ;
                console.log("date", date);

                list.push([done, priority, date, txt])

                //append({"text": todo, "done": done, "priority": priority, "date": date});
            }
            todoList = list;
            sortList();
        }

        function sortList(keys) {
//            var key = keys[0];
            var list = todoList;
            console.log("list",list.toString())
            list.sort(function(a,b){
                if (a[0] !== b[0]) {
//                    console.log(a[0] - b[0]);
                    return a[0] - b[0];
                } else if (a[1] !== b[1]) {
                    var cmp = 0;
                    if (a[1] === "") return  0;
                    if (b[1] === "") return -1;
                    return (a[1] < b[1])*-1;
                }
                return 0;
            }
            )
            console.log("list",list.toString())
            todoList = list;
        }

        function getText() {
            var xhr = new XMLHttpRequest;
            console.log("gt");
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




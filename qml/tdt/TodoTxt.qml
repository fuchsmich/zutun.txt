import QtQuick 2.0

import Sailfish.Silica 1.0

import "todotxt.js" as JS

QtObject {
    property FileIO file: FileIO {
        path: settings.todoTxtLocation
        onContentChanged:{
            tasksArray = JS.splitLines(content);
        }
    }

    property var tasksArray: []
    onTasksArrayChanged: {
        readArray();
    }

    function reloadFile() {
        file.read();
    }

    signal readArray()
    onReadArray: {
        tasks.populate(tasksArray);
        filters.fetchModels();
    }

    signal listToFile(var newArray)
    onListToFile: {
        newArray.sort();
        var txt = "";
        for (var t in newArray) {
            txt += newArray[t] + "\n";
        }
        //this writes to the file:
        file.content = txt;
    }

    property QtObject filters: QtObject {
        property bool hideDone: filterSettings.hideDone
        property var projects: filterSettings.projects.value
        property var contexts: filterSettings.contexts.value
        property string text: [hideDone? qsTr("Hide Complete"): undefined].concat(projects.concat(contexts)).join(", ")

        property ListModel projectsModel: ListModel {}
        property ListModel contextsModel: ListModel {}

        onProjectsChanged: readArray();
        onContextsChanged: readArray();
        onHideDoneChanged: readArray();

        signal fetchModels()
        onFetchModels: {
            populate(projectsModel, JS.projects.list(tasksArray));
            populate(contextsModel, JS.contexts.list(tasksArray));
        }

        function clearFilter(filterName) {
            switch(filterName) {
            case "projects": filterSettings.projects.value = []; break;
            case "contexts": filterSettings.contexts.value = []; break;
            }
        }

        function visibleItem(item) {
            //            console.log(item.subject, projects, contexts)
            if ((hideDone && item.done)) return false;

            for (var p in projects) {
                //                console.log(item.subject,projects[p],item.subject.indexOf(projects[p]))
                if (item.subject.indexOf(projects[p]) === -1) return false;
            }

            for (var c in contexts) {
                if (item.subject.indexOf(contexts[c]) === -1) return false;
            }

            return true;
        }

        /* set filter; name... filterstring; onOff... turn it on (true) or off (false)*/
        function setByName(name, onOff) {
            var list = [];
            switch (name.charAt(0)) {
            case "+": list = projects; break;
            case "@": list = contexts; break;
            default: return;
            }
            if (onOff) list.push(name);
            else list.splice(list.indexOf(name), 1);
            //console.log(typeof filterSettings.projects, typeof list[0]);
            list.sort();
            switch (name.charAt(0)) {
            case "+": filterSettings.projects.value = list; break;
            case "@": filterSettings.contexts.value = list; break;
            default: return;
            }
        }

        function populate(model, array) {
            model.clear();
            var sortedArray, tmpArray = [];
            var itemCount, active, name, visibleItemCount;
            for ( var a in array) {
                tmpArray.push(a);
            }
            sortedArray = tmpArray.sort();
            for (var i in sortedArray) {
                name = sortedArray[i];
                itemCount = array[name].length;
                visibleItemCount = 0;
                for (var j =0;  j < array[name].length; j++){
                    var taskItem = JS.baseFeatures.parseLine(tasksArray[array[name][j]]);
                    if (visibleItem(taskItem)) visibleItemCount++;
                }
                active = ((filters.projects !== undefined && filters.projects.indexOf(name) !== -1) ||
                          (filters.contexts !== undefined && filters.contexts.indexOf(name) !== -1))
                model.append( {"name": name, "active": active, "itemCount": itemCount, "visibleItemCount": visibleItemCount});
            }
        }

    }


    property QtObject sorting: QtObject {
        property bool asc: sortSettings.asc
        onAscChanged: tasks.populate(tasksArray);

        property int order: sortSettings.order
        onOrderChanged: tasks.populate(tasksArray);

        property int grouping: sortSettings.grouping
        onGroupingChanged: tasks.populate(tasksArray);

        property string sortText: qsTr("Sorted by %1").arg(functionList[order][0] + ", " + (asc ? qsTr("asc") : qsTr("desc")))
        property string groupText: (grouping > 0 ? qsTr("Grouped by %1, ").arg(groupFunctionList[grouping][0]) : "")


        //returns a function, which compares two items
        function lessThanFunc() {
            return groupFunctionList[grouping][1];
        }

        //list of functions for sorting; *left* and *right* are the items to compare
        property var functionList: [
            [qsTr("natural"), function(left, right) {
                return (left.fullTxt === right.fullTxt ?
                            false :
                            (left.fullTxt < right.fullTxt) ^ !asc
                        );
            }],
            [qsTr("Creation Date"), function(left, right) {
                return (left.creationDate === right.creationDate ?
                            functionList[0][1](left, right) :
                            (left.creationDate < right.creationDate) ^ !asc
                        );
            }],
            [qsTr("Due Date"), function(left, right) {
                return (left.due === right.due ?
                            functionList[0][1](left, right) :
                            (left.due < right.due) ^ !asc
                        );
            }],
            [qsTr("Subject"), function(left, right) {
                return (left.subject === right.subject ?
                            functionList[0][1](left, right) :
                            (left.subject < right.subject)^ !asc
                        );
            }]
        ]

        property var groupFunctionList: [
            [qsTr("None"),
             function(left, right) {
                 return functionList[order][1](left, right);
             },
             function(line) {
                 return [];
             }
            ]
            ,[qsTr("Projects"),
              function(left, right) {
                  //console.log(typeof left.section, right.section)
                  return (left.section === right.section ?
                               functionList[order][1](left, right) :
                              (left.section < right.section) ^ !asc
                          );
              },
              function(line) {
                  return JS.projects.list([line]);
              }]
            ,[qsTr("Contexts"),
              function(left, right) {
                  return groupFunctionList[1][1](left,right);
              },
              function(line) {
                  return JS.contexts.list([line]);
              }]
        ]
    }


    property var notifications: {
        "idList": [],
        "removeAll": function() {
            for (var i = 0; i < notifications.idList.length; i++) {
                var notificationComp = Qt.createComponent(Qt.resolvedUrl("./Notification.qml"));

                var notification = notificationComp.createObject(app);
                notification.replacesId =  notifications.idList[i];
                notification.close();
                notification.publish();
            }
            notifications.idList = [];
        }
    }
    property ListModel tasks: ListModel {

        //alles auf einmal 0:fullTxt, 1:done, 2:completionDate, 3:priority, 4:creationDate, 5:subject
        //        property var basicPattern: JS.baseFeatures.pattern
        property string lowestPrio: "A"

        /* überschreiben der Funktion setProperty: */
        function setProperty(index, prop, value) {
            var newArr = tasksArray
            var lineNum = get(index).lineNum

            var feature = -1;
            switch (prop) {
            case "done" : feature = JS.baseFeatures.done; break;
            case "priority" : feature = JS.baseFeatures.priority; break;
            default: break
            }

            newArr[lineNum] = JS.baseFeatures.modifyLine(tasksArray[lineNum], feature, value);
            listToFile(newArr);
        }

        function setFullTxt(index, fullTxt) {
            var newArr = tasksArray;

            if (index === -1) newArr.push(fullTxt);
            else  newArr[get(index).lineNum] = fullTxt;

            listToFile(newArr);
        }


        /*raise/lower priority*/
        function alterPriority(index, raise) {
            var newPrio = get(index).priority
            if (raise) {
                if (newPrio === "") newPrio = String.fromCharCode(lowestPrio.charCodeAt(0) + 1);
                else if (newPrio > "A") newPrio = String.fromCharCode(newPrio.charCodeAt(0) - 1);
            } else  {
                if (newPrio !== "") {
                    if (newPrio < "Z") newPrio = String.fromCharCode(newPrio.charCodeAt(0) + 1);
                    else newPrio = "";
                }
            }
            setProperty(index, "priority", newPrio);
        }

        function removeItem(index) {
            var newArr = tasksArray;
            newArr.splice(get(index).lineNum, 1);
            listToFile(newArr);
        }

        function prioColor(prio) {
            //        aus ColorPicker.qml:
            var colors = ["#e60003", "#e6007c", "#e700cc", "#9d00e7",
                          "#7b00e6", "#5d00e5", "#0077e7", "#01a9e7",
                          "#00cce7", "#00e696", "#00e600", "#99e600",
                          "#e3e601", "#e5bc00", "#e78601"];

            return colors[JS.alphabet.search(prio) % colors.length];
        }

        //returns position where to insert *item* decieded by *lessThanFunc*
        function insertPosition(lessThanFunc, item) {
            var lower = 0;
            var upper = count;
            while (lower < upper) {
                var middle = Math.floor(lower + (upper - lower) / 2);
                var result =
                        lessThanFunc(item, get(middle)); //JS.baseFeatures.parseLine(tasksArray[get(middle).lineNum]));
                if (result) {
                    upper = middle;
                } else {
                    lower = middle + 1;
                }
            }
            return lower;
        }

        function populate(array) {
            clear();
            notifications.removeAll();
            for (var a = 0; a < array.length; a++) {
                var line = array[a];
                var groups = sorting.groupFunctionList[sorting.grouping][2](line)
                if (Object.keys(groups).length === 0) {
                    groups[""] = [];
                }
                for (var g in groups) {
                    var item = JS.baseFeatures.parseLine(line);
                    var dueRes = JS.due.get(item.subject)
                    item["due"] = dueRes[0];
                    item.subject = dueRes[1];
                    //console.log(item.due, item.subject);

                    lowestPrio = (!item.done && item.priority !== "" && item.priority.charCodeAt(0) > lowestPrio.charCodeAt(0)
                                  ? item.priority : lowestPrio);

                    if (filters.visibleItem(item)) {
                        var formattedPSubject = item.subject.replace(
                                    JS.projects.pattern,
                                    function(x) { return ' <font color="' + Theme.highlightColor + '">' + x + ' </font>'});
                        var formattedSubject = formattedPSubject.replace(
                                    JS.contexts.pattern,
                                    function(x) { return ' <font color="' + Theme.secondaryHighlightColor + '">' + x + ' </font>'});
                        var displayText = (item.priority !== "" ?
                                               '<font color="' + prioColor(item.priority) + '">(' + item.priority + ') </font>' : "")
                                + formattedSubject //item.subject //+ '<br/>' +item.creationDate

                        var json = {"lineNum": a, "fullTxt": item.fullTxt, "done": item.done,
                            "priority": item.priority, "displayText": displayText,
                            "creationDate": item.creationDate, "due": item.due,
                            "section": g //section
                        };

                        var index = insertPosition(sorting.lessThanFunc(), json); //item)
                        insert(index, json);
                        if (item.due !== "") {
                            var notificationComp = Qt.createComponent(Qt.resolvedUrl("./Notification.qml"));

                            var notification = notificationComp.createObject(app);
                            notification.timestamp = Date.fromLocaleString(Qt.locale(), item.due, "yyyy-MM-dd");
                            notification.body = item.subject;
                            notification.summary = item.due;
                            notification.publish();
                            notifications.idList.push(notification.replacesId)
                            //console.log(notification.replacesId, notifications.idList);
                        }
                    }
                }

            }
        }
    }
    Component.onDestruction: {
        notifications.removeAll();
    }
}

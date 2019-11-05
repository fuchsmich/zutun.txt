import QtQuick 2.12
import QtQuick.Controls 2.5
//import org.kde.kirigami 2.4 as Kirigami
import Qt.labs.settings 1.0
import Qt.labs.platform 1.1
import QtQuick.Layouts 1.1

import QtQml.Models 2.2

import "qrc:/tdt/qml/tdt/"
import "qrc:/tdt/qml/tdt/todotxt.js" as JS

import FileIO 1.0

//TODO icons don't work in Windows

ApplicationWindow {
    id: app
    visible: true
    width: 480
    height: 640
    title: qsTr("ZuTun.txt")

    property int currentTaskIndex: -1
    property var completerCalendardKeywords: ["due:", "t:"]
    property var completerKeywords: {
        var k = []
        k = k.concat(taskListModel.projects)
        k = k.concat(taskListModel.contexts)
        for (var a in JS.alphabet) {
            k.push("(" + JS.alphabet[a] + ")")
        }
        k = k.concat(completerCalendardKeywords)
        k.sort()
        //console.log(k, taskListModel.projects, completerCalendardKeywords)
        return k
    }


    //// Settings


    Settings {
        id: settings
        property alias todoTxtFileLocation: todoTxtFile.path
        property alias width: app.width
        property alias height: app.height
    }

    Settings {
        category: "Filters"
        property alias hideDone: filters.hideDone
        //kann kein array speichern??
        //property alias projectsActive: filters.projects.active
        //property alias contextsActive: filters.contexts.active
        property alias showSearchBar: showSearchBarAction.checked
    }

    Settings {
        category: "Sorting"
        property alias asc: sorting.asc
        property alias key: sorting.order
        property alias grouping: sorting.grouping
    }


    //// Actions

    Action {
        id: addTaskAction
        icon.name: "list-add"
        text: qsTr("&Add Task")
        onTriggered: {
            taskDelegateModel.addTaskItem(taskListModel.lineToJSON(""))
        }
    }

    Action {
        //TODO remorse delete
        id: deleteTaskAction
        icon.name: "delete"
        text: qsTr("&Delete Task")
        onTriggered: {
            //console.log(source, source.taskIndex)
            if (source.taskIndex > -1 && source.taskIndex < taskListModel.count) {
                taskListModel.removeTask(source.taskIndex)
            }
        }
        shortcut: "Delete"
    }

    Action {
        id: filterHideDoneAction
        icon.name: "checkbox"
        text: qsTr("Hide &Done")
        checkable: true
        checked: filters.hideDone
        onToggled: filters.hideDone = !filters.hideDone
        shortcut: "Ctrl+D"
    }

    Action {
        id: filterActivateSearch
        shortcut: "Ctrl+F"
        onTriggered: {
            showSearchBarAction.checked = true
        }
    }

    Action {
        id: toogleSortOrderAction
        icon.name: "view-sort-ascending-name"
        icon.cache: false
        text: (!checked ? "Ascendending" : "Descendending")
        checkable: true
        checked: sorting.asc
        onToggled: sorting.asc = !sorting.asc
        shortcut: "Ctrl+S"
    }

    Action {
        id: showSearchBarAction
        icon.name: "search"
        text: "Show Search"
        checkable: true
    }

    FileIO {
        id: todoTxtFile
        path: StandardPaths.writableLocation(StandardPaths.DocumentsLocation) + '/todo.txt'

        function read() {
            taskListModel.setTextList(content)
        }

        function save(text) {
            content = text
        }

    }

    TaskListModel {
        id: taskListModel
        //section: sorting.grouping
        projectColor: "red"
        contextColor: "blue"
        onListChanged: taskDelegateModel.resort()
        //onItemChanged: taskDelegateModel.resortItem(index)
    }

    Filters {
        id: filters
        onFiltersChanged: taskDelegateModel.resort()
        taskList: taskListModel
    }

    Sorting {
        id: sorting
        onSortingChanged: {
            taskDelegateModel.resort()
        }
    }

    TaskDelegateModel {
        id: taskDelegateModel
        model: taskListModel
        lessThanFunc: sorting.lessThanFunc //changed too late in sorting ??
        getSectionFunc: sorting.getGroup //changed too late in sorting ??
        visibility: filters.visibility
        delegate: TaskListItem {
            id: item
            width: app.width
            onAddTask: taskListModel.addTask(text)
            defaultPriority: taskDelegateModel.defaultPriority
        }
    }

    header: ToolBar {
        contentHeight: menuButton.implicitHeight
        RowLayout {
            width: app.width
            ToolButton {
                id: menuButton
                text: stackView.depth > 1 ? "\u25C0" : "\u2630"
                font.pixelSize: Qt.application.font.pixelSize * 1.6
                onClicked: {
                    if (stackView.depth > 1) {
                        stackView.pop()
                    } else {
                        drawer.open()
                    }
                }
            }

            Label {
                id: titleLbl
                Layout.fillWidth: true
                text: stackView.currentItem.title
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
    menuBar:  ToolBar {
        //width: app.window.width
        RowLayout {
            //Actions
            ToolButton {
                action: addTaskAction
            }

            //Filter
            ToolButton {
                action: filterHideDoneAction
            }
            ToolButton {
                action: showSearchBarAction
            }

            //Sort
            ToolButton {
                action: toogleSortOrderAction
            }
            ComboBox {
                model: {
                    var m = []
                    for (var i in sorting.groupFunctionList) {
                        m.push(sorting.groupFunctionList[i][0])
                    }
                    return m
                }
                currentIndex: sorting.grouping
                onCurrentIndexChanged: sorting.grouping = currentIndex
            }
        }
    }

    footer: ToolBar {
        RowLayout {
            width: app.width
            Label {
                text: "Messages go here."
            }
        }
    }


    Component {
        id: fdComp
        FileDialog {
            id: fd
        }
    }

    Drawer {
        id: drawer
        width: app.width * 0.66
        height: app.height

        Column {
            anchors.fill: parent


            ItemDelegate {
                text: qsTr("Open File")
                width: parent.width
                onClicked: {
                    var dialog = fdComp.createObject(app)
                    dialog.open()
                    dialog.accepted.connect(function () {
                        todoTxtFile.path = dialog.file
                        drawer.close()
                    })
                }
            }
            //            ItemDelegate {
            //                text: qsTr("(Re)Read File")
            //                width: parent.width
            //                onClicked: {
            //                    todoTxtFile.read()
            //                    drawer.close()
            //                }
            //            }
            ItemDelegate {
                text: qsTr("Filters")
                width: parent.width
                onClicked: {
                    stackView.push("FilterPage.qml")
                    drawer.close()
                }
            }
            ItemDelegate {
                text: qsTr("Settings")
                width: parent.width
                onClicked: {
                    stackView.push("SettingsPage.qml")
                    drawer.close()
                }
            }
        }
    }

    StackView {
        id: stackView
        initialItem: "TaskListPage.qml"
        anchors.fill: parent
    }

    //TODO Datei in edit mode vllt nicht lesen??
    // -> auf tasklistpage verlagern??
    onActiveChanged: if (active) todoTxtFile.read()
}

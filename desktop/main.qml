import QtQuick 2.12
import QtQuick.Controls 2.5
//import org.kde.kirigami 2.4 as Kirigami
import Qt.labs.settings 1.0
import Qt.labs.platform 1.1
import QtQuick.Layouts 1.1

import QtQml.Models 2.2

import "qrc:/tdt/tdt/"
import "qrc:/tdt/tdt/todotxt.js" as JS

import FileIO 1.0

//TODO icons don't work in Windows

ApplicationWindow {
    id: app
    visible: true
    width: 480
    height: 640
    readonly property bool inPortrait: app.width < app.height
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

//    Settings {
//        category: "Filters"
//        property alias hideDone: filters.hideDone
//        //kann kein array speichern??
//        //property alias projectsActive: filters.projects.active
//        //property alias contextsActive: filters.contexts.active
//        property alias showSearchBar: showSearchBarAction.checked
//    }

//    Settings {
//        category: "Sorting"
//        property alias asc: sorting.asc
//        property alias key: sorting.order
//        property alias grouping: sorting.grouping
//    }


    //// ---> Actions Start

    Action {
        id: addTaskAction
        icon.name: "list-add"
        icon.source: "icons/list-add.svg"
        text: qsTr("&Add Task")
    }

    Action {
        //TODO remorse delete
        id: deleteTaskAction
        icon.name: "edit-delete"
        icon.source: "icons/edit-delete.svg"
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
        icon.source: "icons/checkbox.svg"
        text: qsTr("Hide &Done")
        checkable: true
        checked: taskListModel.filters.hideDone
        onToggled: taskListModel.filters.hideDone = !taskListModel.filters.hideDone
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
        icon.name: "view-sort-ascending"
        icon.source: "icons/view-sort-ascending.svg"
        //icon.cache: false
        text: (!checked ? "Ascendending" : "Descendending")
        checkable: true
        checked: taskListModel.sorting.asc
        onToggled: taskListModel.sorting.asc = !taskListModel.sorting.asc
        shortcut: "Ctrl+S"
    }

    Action {
        id: showSearchBarAction
        icon.name: "edit-find"
        icon.source: "icons/edit-find.svg"
        text: "Show Search"
        checkable: true
    }

    //// ---> Actions Ende <---

    FileIO {
        id: todoTxtFile
        path: StandardPaths.writableLocation(StandardPaths.DocumentsLocation) + '/todo.txt'

        onPathChanged: {
            taskListModel.setFileContent("")
            read("path changed")
        }

        function read() {
            taskListModel.setFileContent(content)
        }

        function save(text) {
            content = text
        }
    }

    TaskListModel {
        id: taskListModel
        //section: sorting.grouping
        onSaveTodoTxtFile: todoTxtFile.save(content)

        filters {
//            hideDone: filterSettings.hideDone
//            and: filterSettings.and.value
//            or: filterSettings.or.value
//            not: filterSettings.not.value
            onFiltersChanged: visualModel.update()
        }

        sorting {
//            asc: sortSettings.asc
//            order: sortSettings.order
//            groupBy: sortSettings.grouping
            onSortingChanged: visualModel.update()
        }


    }

    SortFilterModel {
        id: visualModel
        model: taskListModel
        visibilityFunc: taskListModel.filters.visibility
        lessThanFunc: taskListModel.sorting.lessThanFunc
        delegate: TaskListItem {
            id: item
            width: app.width
            //onAddTask: taskListModel.addTask(text)
            //defaultPriority: visualModel.defaultPriority
        }
    }

    header: ToolBar {
        contentHeight: menuButton.implicitHeight
        RowLayout {
            //width: app.width
            anchors.fill: parent
            anchors.leftMargin: !inPortrait ? drawer.width : undefined
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
            anchors.fill: parent
            anchors.leftMargin: !inPortrait ? drawer.width : undefined
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
                    for (var i in taskListModel.sorting.groupFunctionList) {
                        m.push(taskListModel.sorting.groupFunctionList[i][0])
                    }
                    return m
                }
                currentIndex: taskListModel.sorting.groupBy
                onCurrentIndexChanged: taskListModel.sorting.groupBy = currentIndex
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
        width: 300
        height: app.height
        modal: inPortrait
        interactive: inPortrait
        position: inPortrait ? 0 : 1
        visible: !inPortrait

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
        anchors.leftMargin: !inPortrait ? drawer.width : undefined
    }

    //TODO Datei in edit mode vllt nicht lesen??
    // -> auf tasklistpage verlagern??
    onActiveChanged: if (active) todoTxtFile.read()
}

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


//TODO icons don't work (in KDE??)

ApplicationWindow {
    id: app
    visible: true
    width: 480
    height: 640
    title: qsTr("ZuTun.txt")

    property int currentTaskIndex: -1
    property real maxZ: -100
    onMaxZChanged: console.log("maxZ", maxZ)

    Action {
        id: addTaskAction
        icon.name: "list-add"
        text: qsTr("&Add Task")
        onTriggered: {
            taskDelegateModel.addTaskItem(taskListModel.lineToJSON(""))
        }
    }

    Action {
        id: deleteTaskAction
        icon.name: "delete"
        text: qsTr("&Delete Task")
        onTriggered: {
            if (currentTaskIndex > -1 && currentTaskIndex < taskListModel.count) {
                taskListModel.removeTask(currentTaskIndex)
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
        id: filterShowSearchBar
        icon.name: "search"
        text: "Show Search"
        checkable: true
    }

    Action {
        id: filterActivateSearch
        shortcut: "Ctrl+F"
        onTriggered: {
            filterShowSearchBar.checked = true
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

    Settings {
        id: settings
        property alias todoTxtFileLocation: todoTxtFile.path
        property alias width: app.width
        property alias height: app.height
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

    Settings {
        category: "Filters"
        property alias hideDone: filters.hideDone
        //property alias projectsActive: filters.projects.active
        //property alias contextsActive: filters.contextsActive
        property alias showSearchBar: filterShowSearchBar.checked
    }
    Filters {
        id: filters
        onFiltersChanged: taskDelegateModel.resort()
        tasksModel: taskListModel
    }

    Settings {
        category: "Sorting"
        property alias asc: sorting.asc
        property alias key: sorting.order
        property alias grouping: sorting.grouping
    }
    Sorting {
        id: sorting
        onSortingChanged: taskDelegateModel.resort()
        onGroupingChanged: taskDelegateModel.resort()
    }

    TaskDelegateModel {
        id: taskDelegateModel
        model: taskListModel
        lessThanFunc: sorting.lessThanFunc
        visibility: filters.visibility
        getSection: sorting.getGroup
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
            ItemDelegate {
                text: qsTr("(Re)Read File")
                width: parent.width
                onClicked: {
                    todoTxtFile.read()
                    drawer.close()
                }
            }
            ItemDelegate {
                text: qsTr("Project Filters")
                width: parent.width
                onClicked: {
                    stackView.push("FiltersPage.qml")
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

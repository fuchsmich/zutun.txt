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

    Action {
        id: addTaskAction
        icon.name: "list-add"
        text: qsTr("&Add Task")
        onTriggered: {
            taskDelegateModel.addTask(taskListModel.lineToJSON("test"))
        }
    }

    Action {
        id: deleteTaskAction
        icon.name: "delete"
        icon.color: "red"
        text: qsTr("Delete Task")
        onTriggered: {
            console.log(source.taskIndex)
        }
    }

    Action {
        id: hideDoneAction
        text: "✓"
        checkable: true
        checked: !filters.hideDone
        onToggled: filters.hideDone = !filters.hideDone
        shortcut: "Ctrl+D"
    }

    Action {
        id: toogleSortOrderAction
        //icon.name: (!checked ? "view-sort-ascending-name" : "view-sort-descending-name")
        text: "abc" + (!checked ? "\u2193" : "\u2191")
        checkable: true
        checked: !sorting.asc
        onToggled: {
            sorting.asc = !checked
            icon.name = (!checked ? "view-sort-ascending-name" : "view-sort-descending-name")
        }
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

        //        onContentChanged: {
        //            taskListModel.setTextList(content)
        //        }
        function read() {
            taskListModel.setTextList(content)
        }

        function save(text) {
            content = text
        }

    }

    TaskListModel {
        id: taskListModel
        section: sorting.grouping
        projectColor: "red"
        contextColor: "blue"
        onListChanged: taskDelegateModel.resort()
        onItemChanged: taskDelegateModel.resortItem(index)
    }

    Settings {
        category: "Filters"
        property alias hideDone: filters.hideDone
        //property alias projectsActive: filters.projects.active
        //property alias contextsActive: filters.contextsActive
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
    }

    TaskDelegateModel {
        id: taskDelegateModel
        model: taskListModel
        lessThanFunc: sorting.lessThanFunc()
        visibility: filters.visibility
        delegate: TaskListItem {
            id: item
            width: app.width
            onResort: {
                console.log(DelegateModel.inItems)
                item.DelegateModel.inUnsorted = true
            }
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
                    })
                }
            }
            ItemDelegate {
                text: qsTr("(Re)Read File")
                width: parent.width
                onClicked: {
                    todoTxtFile.read()
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

    onActiveChanged: if (active) todoTxtFile.read()
}

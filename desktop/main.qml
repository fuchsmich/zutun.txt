import QtQuick 2.12
import QtQuick.Controls 2.5
import org.kde.kirigami 2.4 as Kirigami
import Qt.labs.settings 1.0
import Qt.labs.platform 1.1
import QtQuick.Layouts 1.1

import "qrc:/tdt/qml/tdt/"

import "qrc:/tdt/qml/tdt/todotxt.js" as JS

ApplicationWindow {
    id: app
    visible: true
    width: 480
    height: 640
    title: qsTr("Stack")

    Settings {
        id: settings
        property string todoTxtLocation: StandardPaths.writableLocation(StandardPaths.DocumentsLocation) + '/todo.txt'
        property alias width: app.width
        property alias height: app.height
    }

    FileIO {
        id: todoTxtFile
        path: settings.todoTxtLocation

        onContentChanged: {
            taskListModel.setTextList(content)
        }

    }

    TaskListModel {
        id: taskListModel
        //        section: sorting.grouping
        //      onListChanged: taskDelegateModel.resort()
        projectColor: "red"
        contextColor: "blue"
        onListChanged: taskDelegateModel.resort()
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
    }

    ////array of Strings
    property var taskListArray: []
    onTaskListArrayChanged: populateJSObjects()

    function populateArray (taskListText) {
        taskListArray = JS.splitLines(taskListText)
    }

    ////array of objects
    property var taskListJSObjects: []

    function populateJSObjects () {
        var tmp = []
        for (var line in taskListArray) {
            var item = JS.baseFeatures.parseLine(line)
            tmp.push(item)
        }
        taskListJSObjects = tmp
        //console.log(taskListJSObjects.length)
    }


    header: ToolBar {
        contentHeight: toolButton.implicitHeight
        RowLayout {
        ToolButton {
            id: toolButton
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

        ToolButton {
            text: "✓"
            checkable: true
        }

        Label {
            text: stackView.currentItem.title
            //anchors.centerIn: parent
        }
        }
    }

    Drawer {
        id: drawer
        width: app.width * 0.66
        height: app.height

        Column {
            anchors.fill: parent

            ItemDelegate {
                text: qsTr("Read File")
                width: parent.width
                onClicked: {
                    todoTxtFile.read()
                }
            }
            ItemDelegate {
                text: qsTr("Settings")
                width: parent.width
                onClicked: {
                    stackView.push("Page2Form.ui.qml")
                    drawer.close()
                }
            }
        }
    }

    StackView {
        id: stackView
        initialItem: "Home.qml"
        anchors.fill: parent
    }

    onActiveChanged: if (active) todoTxtFile.read()
}

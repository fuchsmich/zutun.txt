import QtQuick 2.12
import QtQuick.Controls 2.5
//import org.kde.kirigami 2.4 as Kirigami
import Qt.labs.settings 1.0
import Qt.labs.platform 1.1
import QtQuick.Layouts 1.1

import "qrc:/tdt/qml/tdt/"

import "qrc:/tdt/qml/tdt/todotxt.js" as JS

import FileIO 1.0

ApplicationWindow {
    id: app
    visible: true
    width: 480
    height: 640
    title: qsTr("ZuTun.txt")

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
        //        section: sorting.grouping
        //      onListChanged: taskDelegateModel.resort()
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
                        console.log(dialog.file)
                        todoTxtFile.path = dialog.file
                    })
                }
            }
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
        initialItem: "TaskListPage.qml"
        anchors.fill: parent
    }

    onActiveChanged: if (active) todoTxtFile.read()
}

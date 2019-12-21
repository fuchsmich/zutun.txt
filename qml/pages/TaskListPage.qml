import QtQuick 2.0
import Sailfish.Silica 1.0

import "../components"
import "../tdt"

Page {
    id: page
    property string name: "TaskList"

    SilicaListView {
        id: lv
        anchors.fill: parent

        VerticalScrollDecorator {}
        PullDownMenu {
            MenuItem {
                text: qsTr("Settings")
                onClicked: pageStack.push(Qt.resolvedUrl("Settings.qml"))
            }
            MenuItem {
                text: qsTr("Sorting & Grouping")
                onClicked: pageStack.push(Qt.resolvedUrl("SortPage.qml"))
            }
            MenuItem {
                visible: todoTxtFile.writeable
                text: qsTr("Add New Task")
                onClicked: app.addTask()
            }
            MenuItem {
                visible: todoTxtFile.pathExists && !todoTxtFile.exists
                text: qsTr("Create file")
                onClicked: todoTxtFile.create()
            }
        }


        PushUpMenu {
            MenuItem {
                text: (filterSettings.hideDone ? qsTr("Show") : qsTr("Hide")) + qsTr(" Completed Tasks")
                onClicked: filterSettings.hideDone = !filterSettings.hideDone
            }
        }

        header: Item {
            width: page.width
            height: pgh.height + flbl.height
            PageHeader {
                id: pgh
                title: qsTr("Tasklist")
                description: visualModel.sorting.groupText + visualModel.sorting.sortText
            }
            Label { /*from PageHeaderDescription.qml */
                id: flbl
                width: pgh.width - pgh.leftMargin - pgh.rightMargin
                anchors {
                    top: pgh.bottom
                    topMargin: -Theme.paddingMedium
                    right: pgh.right
                    rightMargin: pgh.rightMargin
                }
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.highlightColor
                opacity: 0.6
                horizontalAlignment: Text.AlignRight
                truncationMode: TruncationMode.Fade
                text: qsTr("Filter: %1").arg(visualModel.filters.text())
            }
        }

        footer: Item {
            width: page.width
            height: lv.spacing*2
        }

        section {
            property: "section"
            criteria: ViewSection.FullString
            delegate: SectionHeader {
                text: section //"Section: %1".arg(section)
            }
        }

        ViewPlaceholder {
            enabled: lv.count === 0
            text: qsTr("No Tasks")
            hintText: (todoTxtFile.hintText === ""? qsTr("Pull down to add task.")
                                                : todoTxtFile.hintText)
        }

        function editTask(index, taskTxt) {
            pageStack.push(Qt.resolvedUrl("TaskEditPage.qml"), {taskIndex: index, text: taskTxt});
        }

        model: visualModel.parts.list
    }

    onStatusChanged: {
        if (status === PageStatus.Active) {
            todoTxtFile.read()
            /* attach filter page: */
            if ( pageStack.depth === 1) {
                if (settings.projectFilterLeft) {
                    //                    console.log("replacing tl")
                    pageStack.replace(Qt.resolvedUrl("FiltersPage.qml"),
                                      {state: "projects", skip: true}, PageStackAction.Immediate);
                } else {
                    pageStack.pushAttached(Qt.resolvedUrl("FiltersPage.qml"), {state: "projects"})
                }
            } else {
                if (!settings.projectFilterLeft){
                    pageStack.replaceAbove(null, Qt.resolvedUrl("TaskListPage.qml"),
                                           {}, PageStackAction.Immediate);
                } else {
                    pageStack.pushAttached(Qt.resolvedUrl("FiltersPage.qml"), {state: "contexts"})
                }
            }
        }
    }
}



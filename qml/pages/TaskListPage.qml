import QtQuick 2.0
import Sailfish.Silica 1.0

import "../components"
import "../tdt"

import "../tdt/todotxt.js" as JS

Page {
    id: page

    SilicaListView {
        id: lv
        anchors.fill: parent
        //spacing: Theme.paddingSmall

        VerticalScrollDecorator {}
        PullDownMenu {
            MenuItem {
                //: PullDown menu: go to settings page
                text: qsTr("Settings")
                onClicked: pageStack.push(Qt.resolvedUrl("Settings.qml"))
            }
            MenuItem {
                //: PullDown menu: go to sorting & grouping page
                text: qsTr("Sorting & Grouping")
                onClicked: pageStack.push(Qt.resolvedUrl("SortPage.qml"))
            }
            MenuItem {
                visible: todoTxtFile.writeable
                //: PullDown menu: add new task
                text: qsTr("Add new task")
                onClicked: app.addTask()
            }
            MenuItem {
                visible: todoTxtFile.pathExists && !todoTxtFile.exists
                //: PullDown menu: create todo.txt file. Entry only visible if a) path to todo.txt file exists and b) file was NOT created yet
                text: qsTr("Create file")
                onClicked: todoTxtFile.create()
            }
        }


        PushUpMenu {
            MenuItem {
                //: PushUp menu: show / hide completed tasks
                text: (filterSettings.hideDone ? qsTr("Show") : qsTr("Hide")) + qsTr(" completed tasks")
                onClicked: filterSettings.hideDone = !filterSettings.hideDone
            }
        }

        header: Item {
            width: page.width
            height: pgh.height + flbl.height
            PageHeader {
                id: pgh
                //: PageHeader for tasklist main page
                title: qsTr("Tasklist")
                description: taskListModel.sorting.groupText + taskListModel.sorting.sortText
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
                //: Information about filter settings at the top of main page
                text: qsTr("Filter: %1").arg(taskListModel.filters.text) +
                      " (%1/%2)".arg(taskListModel.visibleTextList.length).arg(taskListModel.count)
            }
        }

        footer: Item {
            width: page.width
            height: lv.spacing*2
        }

        section {
            property: taskListModel.sorting.sectionProperty//"section"
            criteria: ViewSection.FullString
            delegate: SectionHeader {
                text: section //"Section: %1".arg(section)
            }
        }

        ViewPlaceholder {
            enabled: taskListModel.visibleTextList.length === 0
            //: Placeholder if todo.txt file does not contain any unfinished tasks
            text: qsTr("No tasks")
            hintText: (todoTxtFile.hintText === ""? qsTr("Pull down to add task.")
                                                : todoTxtFile.hintText)
        }

        BusyIndicator {
            size: BusyIndicatorSize.Large
            anchors.centerIn: parent
            enabled: false
            running: app.busy
        }

        function editTask(index, taskTxt) {
            pageStack.push(Qt.resolvedUrl("TaskEditPage.qml"), {taskIndex: index, text: taskTxt});
        }

        model: visualModel.parts.list
    }

    onStatusChanged: {
        if (status === PageStatus.Active) {
            //todoTxtFile.read()
            /* attach filter page: */
            pageStack.pushAttached(Qt.resolvedUrl("FiltersPage.qml"))
//            if ( pageStack.depth === 1) {
//                if (settings.projectFilterLeft) {
//                    //                    console.log("replacing tl")
//                    pageStack.replace(Qt.resolvedUrl("FiltersPage.qml"),
//                                      {state: "projects", skip: true}, PageStackAction.Immediate);
//                } else {
//                    pageStack.pushAttached(Qt.resolvedUrl("FiltersPage_copy.qml"))
//                }
//            } else {
//                if (!settings.projectFilterLeft){
//                    pageStack.replaceAbove(null, Qt.resolvedUrl("TaskListPage.qml"),
//                                           {}, PageStackAction.Immediate);
//                } else {
//                    pageStack.pushAttached(Qt.resolvedUrl("FiltersPage.qml"), {state: "contexts"})
//                }
//            }
        }
    }
}



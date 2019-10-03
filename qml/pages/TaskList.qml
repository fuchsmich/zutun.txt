import QtQuick 2.0
import Sailfish.Silica 1.0

import "../components"

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
                visible: file.writeable
                text: qsTr("Add New Task")
                onClicked: app.addTask()
            }
            MenuItem {
                visible: file.pathExists && !file.exists
                text: qsTr("Create file")
                onClicked: {
                    taskListModel.file.create()
                }
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
                description: sorting.groupText + sorting.sortText
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
                text: qsTr("Filter") + ": " + filters.text()
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
                text: "Section: %1".arg(section)
            }
        }

        ViewPlaceholder {
            enabled: lv.count === 0
            text: qsTr("No Tasks")
            hintText: (file.hintText === ""? qsTr("Pull down to add task.")
                                                : file.hintText)
        }

        model: taskDelegateModel

        Connections {
            target: taskDelegateModel
            onEditItem: pageStack.push(Qt.resolvedUrl("TaskEdit.qml"),
                                       {
                                           taskIndex: index,
                                           text: taskListModel.get(index).fullTxt
                                       })
        }
    }

    onStatusChanged: {
        if (status === PageStatus.Active) {
            taskListModel.readFile()
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
                    pageStack.replaceAbove(null, Qt.resolvedUrl("TaskList.qml"),
                                           {}, PageStackAction.Immediate);
                } else {
                    pageStack.pushAttached(Qt.resolvedUrl("FiltersPage.qml"), {state: "contexts"})
                }
            }
        }
    }
}



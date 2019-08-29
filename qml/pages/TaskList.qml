//TODO multiple tasklists?? (-> one model per view, but one global tastkarray)

import QtQuick 2.0
import Sailfish.Silica 1.0

import "../components"
//import "../tdt/todotxt.js" as JS

Page {
    id: page
    property string name: "TaskList"

    SilicaListView {
        id: lv
        anchors.fill: parent
        spacing: Theme.paddingMedium

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
                visible: ttm1.file.writeable
                text: qsTr("Add New Task")
                onClicked: pageStack.push(Qt.resolvedUrl("TaskEdit.qml"), {itemIndex: -1, text: ""});
            }
            MenuItem {
                visible: ttm1.file.pathExists && !ttm1.file.exists
                text: qsTr("Create file")
                onClicked: {
                    ttm1.file.create()
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
                description: ttm1.sorting.groupText + ttm1.sorting.sortText
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
                text: qsTr("Filter") + ": " + ttm1.filters.text
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
                text: section
            }
        }

        ViewPlaceholder {
            enabled: lv.count === 0
            text: qsTr("No Tasks")
            hintText: (ttm1.file.hintText === ""? qsTr("Pull down to add task.")
                                                : ttm1.file.hintText)
        }

        model: ttm1.tasks
        delegate: TaskListItem {
            subject: model.formattedSubject
            done: model.done
            creationDate: model.creationDate
            due: model.due

            onToggleDone: ttm1.tasks.setProperty(model.index, "done", !model.done)
            onEditItem: pageStack.push(Qt.resolvedUrl("TaskEdit.qml"), {itemIndex: model.index, text: model.fullTxt})
            onRemoveItem: ttm1.tasks.removeItem(model.index)
            onPrioUp: ttm1.tasks.alterPriority(model.index, true)
            onPrioDown: ttm1.tasks.alterPriority(model.index, false)
        }

    }

    onActiveFocusChanged: {
        console.log("af", activeFocus)
    }

    onStatusChanged: {
        if (status === PageStatus.Active) {
            ttm1.reloadFile()
            /* attach filter page: */
            if ( pageStack.depth === 1) {
                if (settings.projectFilterLeft) {
//                    console.log("replacing tl")
                    pageStack.replace(Qt.resolvedUrl("FiltersPage.qml"), {state: "projects", skip: true}, PageStackAction.Immediate);
                } else {
                    pageStack.pushAttached(Qt.resolvedUrl("FiltersPage.qml"), {state: "projects"})
                }
            } else {
                if (!settings.projectFilterLeft){
                    pageStack.replaceAbove(null, Qt.resolvedUrl("TaskList.qml"), {}, PageStackAction.Immediate);
                } else {
                    pageStack.pushAttached(Qt.resolvedUrl("FiltersPage.qml"), {state: "contexts"})
                }
            }
        }
    }
}



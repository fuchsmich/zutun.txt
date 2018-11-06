//TODO multiple tasklists?? (-> one model per view, but one global tastkarray)

import QtQuick 2.0
import Sailfish.Silica 1.0
//import QtQml.Models 2.1

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
                text: qsTr("Add New Task")
                onClicked: pageStack.push(Qt.resolvedUrl("TaskEdit.qml"), {itemIndex: -1, text: ""});
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
        }

        model: ttm1.tasks
        delegate:
            ListItem {

            id: listItem
            function remove() {
                remorseAction("Deleting", function() { ttm1.tasks.removeItem(index) })
            }
            onClicked: pageStack.push(Qt.resolvedUrl("TaskEdit.qml"), {itemIndex: index, text: model.fullTxt})
            contentHeight: col.height + lv.spacing

            Column {
                id: col
                width: page.width
                anchors.verticalCenter: parent.verticalCenter
                Row {
                    id: row
                    //            x: Theme.horizontalPageMargin
                    Switch {
                        id: doneSw
                        height: lbl.height
                        automaticCheck: false
                        checked: model.done
                        onClicked: ttm1.tasks.setProperty(model.index, "done", !model.done);
                    }

                    Label {
                        id:lbl
                        width: listItem.width - doneSw.width - 2*Theme.horizontalPageMargin
                        text: model.displayText
                        wrapMode: Text.Wrap
                        font.strikeout: model.done
                        font.pixelSize: settings.fontSizeTaskList
                    }
                }
                Row {
                    //                            x: Theme.horizontalPageMargin
                    spacing: Theme.paddingSmall
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.horizontalPageMargin
                    Label {
                        visible: model.creationDate !== "";
                        text: qsTr("created:");
                        font.pixelSize: Theme.fontSizeExtraSmall
                        //font.bold: true;
                        color: Theme.highlightColor
                    }
                    Label {
                        //anchors.leftMargin: Theme.paddingSmall
                        visible: model.creationDate !== "";
                        text: model.creationDate;
                        font.pixelSize: Theme.fontSizeExtraSmall
                    }
                    Label {
                        visible: model.due !== "";
                        text: qsTr("due:");
                        font.pixelSize: Theme.fontSizeExtraSmall
                        //font.bold: true;
                        color: Theme.highlightColor
                    }
                    Label {
                        //anchors.leftMargin: Theme.paddingSmall
                        visible: model.due !== "";
                        text: model.due;
                        font.pixelSize: Theme.fontSizeExtraSmall
                    }
                }
            }

            menu: ContextMenu {
                //                    DetailItem { visible: model.creationDate !== ""; label: qsTr("Creation Date"); value: model.creationDate }
                MenuItem {
                    visible: !(model.done || model.priority === "A")
                    text: qsTr("Priority Up")
                    onClicked: ttm1.tasks.alterPriority(index, true)
                }
                MenuItem {
                    visible: !(model.done || model.priority === "")
                    text: qsTr("Priority Down")
                    onClicked: ttm1.tasks.alterPriority(index, false)
                }
                MenuItem {
                    text: qsTr("Remove")
                    onClicked: remove()
                }
            }
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



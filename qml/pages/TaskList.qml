//TODO grouping function(index, field) {

import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQml.Models 2.1

Page {
    id: page


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
            //            MenuItem {
            //                text: qsTr("Filter Contexts")
            //                onClicked: pageStack.push(Qt.resolvedUrl("ContextFilter.qml"));
            //            }
            //            MenuItem {
            //                text: qsTr("Filters")
            //                onClicked: pageStack.push(Qt.resolvedUrl("FiltersPage.qml"), {state: "projects"});
            //            }
            MenuItem {
                text: qsTr("Add New Task")
                onClicked: pageStack.push(Qt.resolvedUrl("TaskEdit.qml"), {itemIndex: -1, text: ""});
            }
            MenuItem {
                text: qsTr("Sorting")
                onClicked: pageStack.push(Qt.resolvedUrl("SortPage.qml")) //ttm1.tasks.sortOrder = (ttm1.tasks.sortOrder ===  0 ? 1 : 0)
            }
        }


        PushUpMenu {
            MenuItem {
                text: (filterSettings.hideDone ? "Show" : "Hide") + " Completed Tasks"
                onClicked: filterSettings.hideDone = !filterSettings.hideDone
            }
            //            MenuItem {
            //                text: qsTr("Reload todo.txt")
            ////                onClicked: tdt.reloadTodoTxt();
            //            }
        }

        header: Item {
            width: page.width
            height: pgh.height + flbl.height
            PageHeader {
                id: pgh
                title: qsTr("Tasklist")
                description: "Sorted by " + ttm1.sorting.text
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
                text: "Filter: " + ttm1.filters.text
            }
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
                    Label { visible: model.creationDate !== "";
                        text: "Creation"; font.pixelSize: Theme.fontSizeExtraSmall
                        //                                font.bold: true;
                        color: Theme.highlightColor
                    }
                    Label {
                        //                                anchors.leftMargin: Theme.paddingSmall
                        visible: model.creationDate !== "";
                        text: model.creationDate; font.pixelSize: Theme.fontSizeExtraSmall}
                }
            }

            menu: ContextMenu {
                //                    DetailItem { visible: model.creationDate !== ""; label: qsTr("Creation Date"); value: model.creationDate }
                MenuItem {
                    visible: !(model.done || model.priority === "A")
                    text: "Priority Up"
                    onClicked: ttm1.tasks.alterPriority(index, true)
                }
                MenuItem {
                    visible: !(model.done || model.priority === "")
                    text: "Priority Down"
                    onClicked: ttm1.tasks.alterPriority(index, false)
                }
                MenuItem {
                    text: "Remove"
                    onClicked: remove()
                }
            }
        }

    }


    onStatusChanged: {
        if (status === PageStatus.Active /*&& pageStack.depth === 1*/) {
            //            tdt.reloadTodoTxt();
            //            ttm.reloadTodoTxt();

            /* attach project filter page: */
            pageStack.pushAttached(Qt.resolvedUrl("FiltersPage.qml"), {state: "projects"});
        }
    }
}



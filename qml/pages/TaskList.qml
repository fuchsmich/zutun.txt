
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
            MenuItem {
                text: qsTr("Reload todo.txt")
//                onClicked: tdt.reloadTodoTxt();
            }
            MenuItem {
                text: qsTr("Filters")
                onClicked: pageStack.push(Qt.resolvedUrl("FiltersPage.qml"), {state: "projects"});
            }
            MenuItem {
                text: qsTr("Add New Task")
                onClicked: pageStack.push(Qt.resolvedUrl("TaskEdit.qml"), {itemIndex: -1, text: ""});
            }
//            MenuItem {
//                text: qsTr("Sort: ") + ttm.sortOrder //(ttm.sortOrder ==  0 ? "asc" : "desc")
//                onClicked: ttm.sortOrder = (ttm.sortOrder ==  0 ? 1 : 0)
//            }
        }


        PushUpMenu {
            MenuItem {
                text: (filterSettings.hideDone ? "Show" : "Hide") + " Completed Tasks"
                onClicked: filterSettings.hideDone = !filterSettings.hideDone
                //tdt.filters.hideCompletedTasks = !tdt.filters.hideCompletedTasks
            }
            //            MenuItem {
            //                text: qsTr("Archive Completed Tasks")
            ////                onClicked: pageStack.push(Qt.resolvedUrl("ProjectFilter.qml"))
            //            }
        }

        header: PageHeader {
            title: qsTr("Tasklist")
            description: ttm1.filters.text
        }
        //        property var list: tdt.taskList
        model: ttm1.tasks  //ttm //tasksDelegateModel //tdt.tasksModel //tdt.count

        delegate: ListItem {
                id: listItem
                function remove() {
                    remorseAction("Deleting", function() { ttm1.tasks.removeItem(index) })
                }
                onClicked: pageStack.push(Qt.resolvedUrl("TaskEdit.qml"), {itemIndex: index, text: model.fullTxt})
                contentHeight: row.height + lv.spacing

                Row {
                    id: row
                    //            x: Theme.horizontalPageMargin
                    anchors.verticalCenter: parent.verticalCenter
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
                menu: ContextMenu {
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
            //            console.log("im active")
            //            tdt.initialPage = pageStack.currentPage;
//            tdt.reloadTodoTxt();
//            ttm.reloadTodoTxt();

            /* attach project filter page: */
            pageStack.pushAttached(Qt.resolvedUrl("FiltersPage.qml"), {state: "projects"});
        }
    }
}




import QtQuick 2.0
import Sailfish.Silica 1.0


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
                onClicked: tdt.reloadTodoTxt();
            }
            MenuItem {
                text: qsTr("Filters")
                onClicked: pageStack.push(Qt.resolvedUrl("FiltersPage.qml"), {state: "projects"});
            }
            MenuItem {
                text: qsTr("Add New Task")
                onClicked: pageStack.push(Qt.resolvedUrl("TaskEdit.qml"), {itemIndex: -1, text: ""});
            }
        }


        PushUpMenu {
            MenuItem {
                text: (tdt.filters.hideCompletedTasks ? "Show" : "Hide") + " Completed Tasks"
                onClicked: tdt.filters.hideCompletedTasks = !tdt.filters.hideCompletedTasks
            }
//            MenuItem {
//                text: qsTr("Archive Completed Tasks")
////                onClicked: pageStack.push(Qt.resolvedUrl("ProjectFilter.qml"))
//            }
        }

        header: PageHeader {
            title: qsTr("Tasklist")
            description: tdt.filters.string()
        }
//        property var list: tdt.taskList
        model: tdt.tasksModel //tdt.count
        delegate: ListItem {
            id: listItem

            visible: tdt.filters.itemVisible(index)

            contentHeight: (row.height + lv.spacing)*visible //(Math.max(lbl.height /*,doneSw.height*/ ) + 2*Theme.paddingLarge)*visible
            width: page.width
            anchors.rightMargin: Theme.horizontalPageMargin

            ListView.onRemove: animateRemoval(listItem)
            function remove() {
                remorseAction("Deleting", function() { tdt.removeItem(index) })
            }

            Row {
                id: row
                height: lbl.height
                Switch {
                    id: doneSw
                    x: Theme.horizontalPageMargin
                    anchors.top: lbl.top
//                    anchors.topMargin: -height/3.8 //-Theme.paddingLarge
                    height: lbl.height
                    automaticCheck: false
                    checked: model.done
//                    iconSource: "image://theme/icon-s-task?" + (model.done ? "green" : "red")
                    onClicked: tdt.setDone(index, !model.done);
                }

                Label {
                    id:lbl
                    width: page.width - doneSw.width - 2*Theme.horizontalPageMargin
                    text: model.displayText
                    wrapMode: Text.Wrap
                    font.strikeout: model.done
                    font.pixelSize: settings.fontSizeTaskList
                }
            }
            menu: ContextMenu {
                MenuItem {
                    visible: !model.done
                    text: "Priority Up"
                    onClicked: tdt.raisePriority(index)
                }
                MenuItem {
                    visible: !model.done
                    text: "Priority Down"
                    onClicked: tdt.lowerPriority(index)
                }
                MenuItem {
                    text: "Remove"
                    onClicked: remove()
                }
            }

            onClicked: {
//                console.log(index);
                pageStack.push(Qt.resolvedUrl("TaskEdit.qml"), {itemIndex: index, text: model.fullTxt});
            }
        }
    }
    onStatusChanged: {
        if (status === PageStatus.Active /*&& pageStack.depth === 1*/) {
//            console.log("im active")
//            tdt.initialPage = pageStack.currentPage;
            tdt.reloadTodoTxt();
            pageStack.pushAttached(Qt.resolvedUrl("FiltersPage.qml"), {state: "projects"});
        }
    }
}




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
            MenuItem {
                text: qsTr("Sort: ") + tasksDelegateModel.sortOrder //(tasksDelegateModel.sortOrder ==  0 ? "asc" : "desc")
                onClicked: tasksDelegateModel.sortOrder = (tasksDelegateModel.sortOrder ==  0 ? 1 : 0)
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
        model: ttm //tasksDelegateModel //tdt.tasksModel //tdt.count

        DelegateModel {
            id: tasksDelegateModel
            property var filters: [
                function (item) { return !item.model.done }
            ]

            property var lessThan: [
                function(left, right) { return left.fullTxt < right.fullTxt }, //natural
                function(left, right) { return left.fullTxt > right.fullTxt }
            ]

            property int filterSet: 0
            property int sortOrder: 0
            onSortOrderChanged: {
                resorting = true
                items.setGroups(0, items.count, "unsorted")
                resorting = false
            }

            function insertPosition(lessThanFunc, item) {
                var lower = 0
                var upper = items.count
                while (lower < upper) {
                    var middle = Math.floor(lower + (upper - lower) / 2)
                    var result = lessThanFunc(item.model, items.get(middle).model);
                    if (result) {
                        upper = middle
                    } else {
                        lower = middle + 1
                    }
                }
                return lower
            }

            function sort(lessThanFunc) {
                while (visibleItems.count > 0) {
                    var item = visibleItems.get(0)
//                    if (item.itemVisible) {
                        var index = insertPosition(lessThanFunc, item)
                    console.log(visibleItems.count, items.count, index, item.groups);

                        item.groups = "items"
                        items.move(item.itemsIndex, index)
//                    }
//                    else item.groups = "hidden"
                }
            }

            function filter(filterFunc) {
                console.log("filtering")
                for (var i = 0; i < unsortedItems.count; i++ ) {
                    console.log("filtering")
                    var item = unsortedItems.get(i)
                    if (filterFunc(item)) item.groups = "visible"
                }
            }

            model: tdt.tasksModel
            items.includeByDefault: false
            groups:[ DelegateModelGroup {
                id: unsortedItems
                name: "unsorted"

                includeByDefault: true
                onChanged: {
                    console.log("filtering")
                    tasksDelegateModel.filter(tasksDelegateModel.filters[tasksDelegateModel.filterSet])
                }
                }, DelegateModelGroup {
                    id: visibleItems
                    name: "visible"
                    onChanged: {
                        console.log("sorting")
                        if (tasksDelegateModel.sortOrder == tasksDelegateModel.lessThan.length)
                            setGroups(0, count, "items")
                        else
                            tasksDelegateModel.sort(tasksDelegateModel.lessThan[tasksDelegateModel.sortOrder])
                }
                } ]

            delegate: ListItem {
                id: listItem
                width: page.width

//                visible: tdt.filters.itemVisible(index)

                contentHeight: (row.height + lv.spacing)//*visible //(Math.max(lbl.height /*,doneSw.height*/ ) + 2*Theme.paddingLarge)*visible
//                anchors.rightMargin: Theme.horizontalPageMargin

//TODO: Animation zum Entfernen kollidiert mit sortieren
                //                ListView.onRemove: if (!tasksDelegateModel.resorting) animateRemoval(listItem)
//                ListView.onRemove:
//                    RemoveAnimation{ target:listItem }

                function remove() {
                    remorseAction("Deleting", function() { tdt.removeItem(index) })
                }

                Row {
                    id: row
                    x: Theme.horizontalPageMargin
                    anchors.verticalCenter: parent.verticalCenter
                    Switch {
                        id: doneSw
                        height: lbl.height
                        automaticCheck: false
                        checked: model.done
                        onClicked: ttm.model.setDone(index, !model.done);
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
                    Label { text: index }
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
    }
    onStatusChanged: {
        if (status === PageStatus.Active /*&& pageStack.depth === 1*/) {
            //            console.log("im active")
            //            tdt.initialPage = pageStack.currentPage;
//            tdt.reloadTodoTxt();
            ttm.reloadTodoTxt();
            pageStack.pushAttached(Qt.resolvedUrl("FiltersPage.qml"), {state: "projects"});
        }
    }
}



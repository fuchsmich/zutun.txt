
import QtQuick 2.0
import Sailfish.Silica 1.0


Page {
    id: page


    SilicaListView {
        id: lv
        anchors.fill: parent

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
                text: qsTr("Filters")
                onClicked: pageStack.push(Qt.resolvedUrl("Filters.qml"), {state: "projects"});
            }
            MenuItem {
                text: qsTr("Add New Task")
                onClicked: pageStack.push(taskEdit, {itemIndex: -1, text: ""});
            }
        }

        Component {
            id: taskEdit
            TaskEdit {  }
        }
        Component {
            id: contextFiler
            ContextFilter  {  }
        }

        PushUpMenu {
            MenuItem {
                text: qsTr("Hide Completed Tasks")
                onClicked: pageStack.push(Qt.resolvedUrl("ProjectFilter.qml"))
            }
            MenuItem {
                text: qsTr("Archive Completed Tasks")
                onClicked: pageStack.push(Qt.resolvedUrl("ProjectFilter.qml"))
            }
        }

        header: PageHeader {
            title: qsTr("Aufgaben")
            description: (tdt.pfilter === ""? "All Projects" : tdt.pfilter)
        }
        model: tdt.taskList
        delegate: ListItem {
            id: listItem

            visible: tdt.visibleOnFilter(index)

            contentHeight: (Math.max(lbl.height /*,doneSw.height*/ ) + 2*Theme.paddingLarge)*visible
            width: page.width
            anchors.rightMargin: Theme.horizontalPageMargin

            ListView.onRemove: animateRemoval(listItem)
            function remove() {
                remorseAction("Deleting", function() { tdt.removeItem(index) })
            }

            Row {
                id: row
                Switch {
                    id: doneSw
                    //                    anchors.verticalCenter: parent.verticalCenter
                    x: Theme.horizontalPageMargin
                    checked: tdt.getDone(index)
                    iconSource: "image://theme/icon-s-task?" + (checked ? "green" : "red")
                        //"image://theme/icon-s-certificates?" + (checked ? "green" : "red")
                    //                    Component.onCompleted: console.log(index, typeof tdt.taskList[index][tdt.done])
                    onClicked: tdt.setDone(index, checked);
                }

                Label {
                    id:lbl
                    anchors.top: doneSw.top
                    anchors.topMargin: Theme.paddingLarge + 3
                    width: page.width - doneSw.width - 2*Theme.horizontalPageMargin
                    text:'<font color="' + tdt.getColor(index) + '">' + tdt.getPriority(index)+ '</font>'
                         + tdt.taskList[index][tdt.subject]
                    wrapMode: Text.Wrap
//                    color: tdt.getColor(index)
                    font.strikeout: doneSw.checked
                }
            }
            menu: ContextMenu {
                MenuItem {
                    text: "Priority Up"
                    onClicked: tdt.raisePriority(index)
                }
                MenuItem {
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
                pageStack.push(taskEdit, {itemIndex: index, text: tdt.taskList[index][tdt.fullTxt]});
            }
        }
    }
    onStatusChanged: {
        if (status === PageStatus.Active /*&& pageStack.depth === 1*/) {
            console.log("im active")
            tdt.initialPage = pageStack.currentPage;
            pageStack.pushAttached(Qt.resolvedUrl("Filters.qml"), {state: "projects"});
        }
    }
}



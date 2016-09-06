
import QtQuick 2.0
import Sailfish.Silica 1.0


Page {
    id: page

    SilicaListView {
        id: lv
        VerticalScrollDecorator {}
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                text: qsTr("Settings")
                onClicked: pageStack.push(Qt.resolvedUrl("Settings.qml"))
            }
            MenuItem {
                text: qsTr("Filter Projects")
                onClicked: pageStack.push(Qt.resolvedUrl("ProjectFilter.qml"))
            }
            MenuItem {
                text: qsTr("Add new task")
                onClicked: pageStack.push(taskEdit, {itemIndex: -1, text: ""});
            }
        }

        header: PageHeader {
            title: qsTr("Aufgaben")
            description: (tdt.pfilter.length === 0? "All" : tdt.pfilter.toString())
        }
        model: tdt.taskList
        delegate: ListItem {
            //TODO lange Texte überlappen
            id: listItem
            contentHeight: Math.max(lbl.height,doneSw.height) + 2*Theme.paddingLarge
            ListView.onRemove: animateRemoval(listItem)
            width: page.width
            anchors.rightMargin: Theme.horizontalPageMargin

            function remove() {
                remorseAction("Deleting", function() { tdt.removeItem(index) })
            }

            Row {
                //TODO row in ein Item umwandeln? für bessere Positionierung
                id: row
                Switch {
                    id: doneSw
                    //                    anchors.verticalCenter: parent.verticalCenter
                    x: Theme.horizontalPageMargin
                    checked: tdt.getDone(index)
                    iconSource: "image://theme/icon-s-certificates?" + (checked ? "green" : "red")
                    //                    Component.onCompleted: console.log(index, typeof tdt.taskList[index][tdt.done])
                    onClicked: tdt.setDone(index, checked);
                }
                Label {
                    id:lbl
                    anchors.top: doneSw.top
                    anchors.topMargin: Theme.paddingLarge + 3
                    width: page.width - doneSw.width - 2*Theme.horizontalPageMargin
                    text: tdt.getPriority(index) + tdt.taskList[index][tdt.subject]
                    wrapMode: Text.Wrap
                    color: tdt.getColor(index)
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
                console.log(index);
                pageStack.push(taskEdit, {itemIndex: index, text: tdt.taskList[index][0]});
            }
        }
    }
    onStatusChanged: {
        if (status === PageStatus.Active && pageStack.depth === 1) {
            pageStack.pushAttached("ProjectFilter.qml", {});
        }
    }

    TaskEdit {
        id: taskEdit
    }
}



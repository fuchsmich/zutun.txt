
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
        }

        header: PageHeader {
            title: qsTr("Aufgaben")
            description: (tdt.pfilter.length === 0? "All" : tdt.pfilter.toString())
        }
        model: tdt.todoList
        delegate: ListItem {
            id: listItem
            contentHeight: Math.max(lbl.height,doneSw.height) + Theme.paddingLarge
            ListView.onRemove: animateRemoval(listItem)

            function remove() {
                remorseAction("Deleting", function() { tdt.removeItem(index) })
            }

            Row {
                Switch {
                    id: doneSw
                    //                    anchors.verticalCenter: parent.verticalCenter
                    checked: tdt.getDone(index)
                    iconSource: "image://theme/icon-s-certificates?" + (checked ? "green" : "red")
                    //                    Component.onCompleted: console.log(index, typeof tdt.todoList[index][tdt.done])
                    onClicked: tdt.setDone(index, checked);
                }
                Label {
                    id:lbl
                    width: page.width - doneSw.width
                    //                    anchors.bottom: doneSw.bottom
                    anchors.verticalCenter: doneSw.verticalCenter
                    text: tdt.getPriority(index) + tdt.todoList[index][tdt.subject]
                    wrapMode: Text.Wrap
                    color: tdt.getColor(index)//(doneSw.checked ? Theme.secondaryColor : Theme.primaryColor)
                    font.strikeout: doneSw.checked
                }
            }
            menu: ContextMenu {
                MenuItem {
                    text: "Remove"
                    onClicked: remove()
                }
            }

            onClicked: {
                console.log(index);
                pageStack.push(textDialog, {itemIndex: index, text: tdt.todoList[index][0]});
            }
        }
    }
    onStatusChanged: {
        if (status === PageStatus.Active && pageStack.depth === 1) {
            pageStack.pushAttached("ProjectFilter.qml", {});
        }
    }
    Component {
        id: textDialog
        Dialog {
            id: dialog
            acceptDestination: page
            acceptDestinationAction: PageStackAction.Pop
            property int itemIndex
            property string text
            onItemIndexChanged: {
                console.log(text);
//                ta.text = tdt.todoList[dialog.itemIndex][0];
            }

            Column {
                anchors.fill: parent
                DialogHeader {
                    title: "Edit Item " + itemIndex
                }
                TextArea {
                    id: ta
                    width: dialog.width
                    text: dialog.text
                }
            }
            onAccepted: {
                tdt.setFullText(itemIndex, ta.text);
                pageStack.pop();
            }
            onCanceled: {
                pageStack.pop();
            }
        }
    }
}



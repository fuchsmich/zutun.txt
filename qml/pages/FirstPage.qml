
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
        }

        header: PageHeader {
            title: qsTr("Aufgaben")
            description: qsTr("Alle")
        }
        model: tdt.todoList
        delegate: ListItem {
            id: listItem
            contentHeight: Math.max(lbl.height,doneSw.height) + Theme.paddingLarge
            ListView.onRemove: animateRemoval(listItem)

            function remove() {
                remorseAction("Deleting", function() { tdt.remove(index) })
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
        }

    }
}



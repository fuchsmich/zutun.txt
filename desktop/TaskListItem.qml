import QtQuick 2.0
import QtQuick.Controls 2.5

import QtQml.Models 2.2

Loader {
    id: loader
    state: "view"

    signal addTask(string text)

    property string defaultPriority: "F"

    function priorityUpDown(priority, up) {
        //console.log("A"++)
        if (up) {
            if (priority === "") return String.fromCharCode(defaultPriority.charCodeAt(0));
            else if (priority > "A") return String.fromCharCode(priority.charCodeAt(0) - 1);
        } else  {
            if (priority !== "") {
                if (priority < "Z") return String.fromCharCode(priority.charCodeAt(0) + 1);
                return ""
            }
        }
        return priority
    }

    Component {
        id: viewComp
        Column {
            id: taskListItem

            Row {
                CheckBox {
                    id: doneCB
                    checked: model.done
                    onClicked: {
                        model.done = !model.done
                        loader.DelegateModel.groups = "unsorted"
                    }
                    anchors.verticalCenter: id.verticalCenter
                }
                ItemDelegate {
                    id: id
                    text: model.formattedSubject
                    width: loader.width - doneCB.width
                    highlighted: loader.DelegateModel.itemsIndex === loader.ListView.view.currentIndex
                    onClicked:{
                        loader.state = "edit"
                    }
                    MouseArea {
                        id: mouse
                        anchors.fill: parent
                        acceptedButtons: Qt.RightButton
                        onClicked: {
                            if (mouse.button === Qt.RightButton)
                                contextMenu.popup()
                        }
                        hoverEnabled: true
                    }
                    Row {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        //height: parent.height
                        visible: mouse.containsMouse
                        ToolButton {
                            display: AbstractButton.TextOnly
                            icon.name: "font-size-up"
                            text: "(B)" + "\u2191"
                            opacity: 0.5
                            onClicked: {
                                model.priority = priorityUpDown(model.priority, true)
                                loader.DelegateModel.groups = "unsorted"
                            }
                        }
                        ToolButton {
                            display: AbstractButton.TextOnly
                            icon.name: "font-size-down"
                            text: "(A)" + "\u2193"
                            opacity: 0.5
                            onClicked: {
                                model.priority = priorityUpDown(model.priority, false)
                                loader.DelegateModel.groups = "unsorted"
                            }
                        }
                        ToolButton {
                            property int taskIndex: model.index
                            display: AbstractButton.IconOnly
                            action: deleteTaskAction
//                            icon.name: "delete"
                            //icon.color: "red"
                            icon.color: "transparent"
//                            text: "\u007F"
                            opacity: 0.5
                        }
                    }
                }
            }
            Row {
                anchors.right: parent.right
                anchors.rightMargin: spacing
                spacing: 10
                Label {
                    visible: model.creationDate !== ""
                    text: qsTr("created:")
                    font.italic: true
                }
                Label {
                    id: cdLbl
                    visible: model.creationDate !== ""
                    text: model.creationDate
                }
                Label {
                    visible: model.due !== "";
                    text: qsTr("due:");
                    font.italic: true
                }
                Label {
                    id: dueLbl
                    visible: model.due !== ""
                    text: model.due
                }
            }
        }
    }

    Component {
        id: editComp
        TextField {
            text: model.fullTxt
            Keys.onEscapePressed: {
                loader.state = "view"
            }
            onEditingFinished: {
                model.fullTxt = text
                loader.state = "view"
                loader.DelegateModel.groups = "unsorted"
            }
            Component.onCompleted: forceActiveFocus()
        }
    }

    Component {
        id: addComp
        TextField {
            text: model.fullTxt
            Keys.onEscapePressed: {
                loader.state = "view"
                loader.DelegateModel.inItems = false
            }
            onEditingFinished: {
                loader.state = "view"
                loader.addTask(text)
                loader.DelegateModel.inItems = false
            }
            Component.onCompleted: forceActiveFocus() //doe not work here??
        }
    }

    states: [
        State {
            name: "view"
            PropertyChanges {
                target: loader
                sourceComponent: viewComp
            }
        },
        State {
            name: "edit"
            PropertyChanges {
                target: loader
                sourceComponent: editComp
            }
        },
        State {
            name: "add"
            extend: "edit"
            PropertyChanges {
                target: loader
                sourceComponent: addComp
            }
        }
    ]
    //onStateChanged: console.log("Item:", model.index,  "state:", state, )

//    Component.onCompleted: {
//        console.log("Item:", model.index,  "state:", state)
//    }
}

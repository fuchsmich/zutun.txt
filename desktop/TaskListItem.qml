import QtQuick 2.0
import QtQuick.Controls 2.5

import QtQml.Models 2.2
import "qrc:/tdt/tdt/todotxt.js" as JS

Loader {
    id: loader
    state: "view"

    signal resortItem()

    Component {
        id: viewComp
        Column {
            id: taskListItem

            Row {
                ItemDelegate {
                    id: id
                    //text: model.formattedSubject
                    width: taskListItem.width//loader.width - doneCB.width
                    height: Math.max(doneCB.height, subjectLbl.height)
                    highlighted: loader.DelegateModel.itemsIndex === loader.ListView.view.currentIndex
                    onClicked: loader.ListView.view.currentIndex = loader.DelegateModel.itemsIndex
                    onDoubleClicked:{
                        loader.state = "edit"
                    }
                    CheckBox {
                        id: doneCB
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        checked: model.done
                        onClicked: {
                            taskListModel.setTaskProperty(model.index, JS.baseFeatures.done, checked)
                            resortItem()
                        }
                    }
                    Label {
                        id: subjectLbl
                        anchors.left: doneCB.right
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        text: model.formattedSubject
                        onLinkActivated: Qt.openUrlExternally(link)
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
                        visible: mouse.containsMouse || loader.ListView.isCurrentItem
                        opacity: 0.7
                        ToolButton {
                            display: AbstractButton.TextOnly
                            icon.name: "font-size-up"
                            text: "(B)" + "\u2191"
                            onClicked: {
                                var prio = taskListModel.alterPriority(model.priority, true)
                                taskListModel.setTaskProperty(model.index, JS.baseFeatures.priority, prio)
                                resortItem()
                            }
                        }
                        ToolButton {
                            display: AbstractButton.TextOnly
                            icon.name: "font-size-down"
                            text: "(A)" + "\u2193"
                            onClicked: {
                                var prio = taskListModel.alterPriority(model.priority, false)
                                taskListModel.setTaskProperty(model.index, JS.baseFeatures.priority, prio)
                                resortItem()
                            }
                        }
                        ToolButton {
                            property int taskIndex: model.index
                            display: AbstractButton.IconOnly
                            action: deleteTaskAction
                            icon.color: "transparent"
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
                taskListModel.setTaskProperty(model.index, JS.baseFeatures.fullTxt, text)
                loader.state = "view"
                resortItem()
            }
            Component.onCompleted: forceActiveFocus()
        }
    }

    Component {
        id: addComp
        TextField {
            text: model.fullTxt
            Keys.onEscapePressed: {
                //loader.state = "view"
                loader.DelegateModel.groups = ""
            }
            onEditingFinished: {
                loader.DelegateModel.groups = ""
                //loader.state = "view"
                loader.addTask(text)
            }
            Completer {
               model: app.completerKeywords
               calendarKeywords: app.completerCalendardKeywords
            }
            //Component.onCompleted: console.log("groups", loader.DelegateModel.groups)
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
    //onStateChanged: console.log("state", loader.state, "groups", loader.DelegateModel.groups)
}

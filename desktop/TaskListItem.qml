import QtQuick 2.0
import QtQuick.Controls 2.5

import QtQml.Models 2.2

Loader {
    id: loader
    state: "view"

    signal resort()

    Component {
        id: viewComp
        Column {
            id: taskListItem

            Row {
                CheckBox {
                    id: doneCB
                    //checkState: model.done*2
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
                    //text: ListView.model.
                    width: loader.width - doneCB.width
                    highlighted: true //ListView.isCurrentItem
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
                            display: AbstractButton.IconOnly
                            icon.name: "font-size-up"
                            text: "up"
                            opacity: 0.5
                        }
                        ToolButton {
                            display: AbstractButton.IconOnly
                            icon.name: "font-size-down"
                            text: "down"
                            opacity: 0.5
                        }
                        ToolButton {
                            property int taskIndex: model.index
                            display: AbstractButton.IconOnly
                            action: deleteTaskAction
//                            icon.name: "delete"
                            icon.color: "red"
//                            text: "delete"
                            opacity: 0.5
                        }
                    }
                }
            }
//            Row {
//                anchors.right: parent.right
//                anchors.rightMargin: spacing
//                spacing: 10
//                property int fontSize: Qt.application.font.pixelSize * 0.7

//                Label {
//                    visible: creationDate !== ""
//                    text: qsTr("created:")
//                    font.pixelSize: parent.fontSize
//                    font.italic: true
//                    //color: Theme.highlightColor
//                }
//                Label {
//                    id: cdLbl
//                    visible: creationDate !== ""
//                    font.pixelSize: parent.fontSize
//                }
//                Label {
//                    visible: due !== "";
//                    text: qsTr("due:");
//                    font.pixelSize: parent.fontSize
//                    font.italic: true
//                    //color: Theme.highlightColor
//                }
//                Label {
//                    id: dueLbl
//                    visible: due !== ""
//                    font.pixelSize: parent.fontSize
//                }
//            }
        }
    }

    Component {
        id: editComp
        TextField {
            text: model.fullTxt
            Keys.onEscapePressed: loader.state = "view"
            onEditingFinished: {
                model.fullTxt = text
                loader.state = "view"
            }
            Component.onCompleted: forceActiveFocus()
        }
    }

    states: [
        State {
            name: "view"
            PropertyChanges {
                target: loader
                sourceComponent: viewComp
                //height: Math.max(taskLine.item.lblHeight, Theme.minRowHeight)
            }
        },
        State {
            when: loader.DelegateModel.isUnresolved
            name: "edit"
            PropertyChanges {
                target: loader
                sourceComponent: editComp
//                height: Math.max(taskLine.item.contentHeight, Theme.minRowHeight)
            }
        }
    ]
}

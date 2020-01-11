import QtQuick 2.2
import Sailfish.Silica 1.0

import "../components"
import "../tdt/todotxt.js" as JS

Dialog {
    id: dialog

    //-1 for adding new task
    property int taskIndex: -1
    property alias text: ta.text

    function setText(type, txt) {
        //console.debug(type, txt)
        var cp = ta.cursorPosition
        var l = ta.text.length
        switch (type) {
        case "priority":
            var arg =  (txt ? txt.charAt(1) : false)
            //console.log(arg)
            ta.text = JS.baseFeatures.modifyLine(ta.text, JS.baseFeatures.priority, arg)
            ta.cursorPosition = cp + (ta.text.length - l)
            break
        case "project":
        case "context":
            var before = ta.text.substr(0,cp)
            var after = ta.text.substr(cp)
            txt = (before.charAt(before.length - 1) === " " ? "" : " ")
                    + txt
                    + (after.charAt(0) === " " ? "" : " ")
            ta.text = before + txt + after
            ta.cursorPosition = cp + txt.length
            break
        case "due":
            ta.text = JS.due.set(ta.text, txt)
            break
        case "creationDate":
            ta.text = JS.baseFeatures.modifyLine(ta.text, JS.baseFeatures.creationDate, txt)
            ta.cursorPosition = cp + (ta.text.length - l)
            break
        }
        ta.focusTimer.start()
    }

    acceptDestinationAction: PageStackAction.Pop
    canAccept: text.length > 0

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: col.height
        VerticalScrollDecorator {}
        Column {
            id: col
            width: dialog.width
            DialogHeader {
                //: DialogHeader for new task / edit task
                title: (taskIndex == -1 ? qsTr("Add new task") : qsTr("Edit task"))
            }
            TextArea {
                id: ta
                width: parent.width
                autoScrollEnabled: true

                focus: true
                property Timer focusTimer: Timer {
                    interval: 200
                    repeat: false
                    onTriggered: {
                        ta.forceActiveFocus();
                    }
                }
                text: dialog.text
                EnterKey.enabled: text.length > 0
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                EnterKey.onClicked: dialog.accept()
                Component.onCompleted: cursorPosition = ta.text.length
            }

            Grid {
                id: grid
                width: parent.width - 2*x
                horizontalItemAlignment: Grid.AlignHCenter
                verticalItemAlignment: Grid.AlignTop
                columns: Math.floor(width/Theme.itemSizeMedium)
                property real itemWidth: width/columns

                EditItemContextList {
                    //set priority
                    Label {
                        width: parent.width
                        height: width
                        text: "(A)"
                        font.pixelSize: Theme.fontSizeLarge
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
//                    onClicked: {
//                        openMenu()
//                    }

                    model: ListModel {
                        id: prioritiesModel
                        Component.onCompleted: {
                            for (var a in JS.alphabet) {
                                append({"name": "(" + JS.alphabet[a] + ") "});
                            }
                        }
                    }
                    onListItemSelected: setText("priority", text)
                }
                EditItem {
                    //remove priority
                    Label {
                        width: parent.width
                        height: width
                        text: "(A)"
                        font.pixelSize: Theme.fontSizeLarge
                        font.strikeout: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        setText("priority", false)
                    }
                }

                EditItemDatePicker {
                    //creation date
                    Image {
                        width: parent.width
                        height: width
                        source: "image://theme/icon-l-date"
                    }
                    onClicked: setText("creationDate", JS.today())
                    onPressAndHold: ta.focus = false
                    onDateClicked: {
                        setText("creationDate", date)
                        closeMenu()
                    }
                }
                EditItemContextList {
                    //projects
                    Label {
                        width: parent.width
                        height: width
                        text: "+"
                        font.pixelSize: Theme.fontSizeLarge
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    model: taskListModel.projects
                    onListItemSelected: setText("project", text)
                }

                EditItemContextList {
                    //contexts
                    Label {
                        width: parent.width
                        height: width
                        text: "@"
                        font.pixelSize: Theme.fontSizeLarge
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    model: taskListModel.contexts
                    onListItemSelected: setText("context", text)
                }

                EditItemDatePicker {
                    //due date
                    Label {
                        width: parent.width
                        height: width
                        text: "due:"
                        font.pixelSize: Theme.fontSizeLarge
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        ta.focus = false
                        var dueDate = JS.due.get(ta.text)[0]
                        date = (dueDate === "" ? new Date() : new Date(dueDate))
                        openMenu()
                    }
                    openMenuOnPressAndHold: false
                    onDateClicked: {
                        setText("due", date)
                        closeMenu()
                    }
                }

                EditItem {
                    //remove due date
                    Label {
                        width: parent.width
                        height: width
                        text: "due:"
                        font.pixelSize: Theme.fontSizeLarge
                        font.strikeout: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        setText("due", "")
                    }
                }
            }


            Loader {
                id: bottomLoader
                width: parent.width
            }
        }
    }

    Component.onCompleted: {
        ta.cursorPosition = ta.text.length
    }

    onAccepted: {
        if (taskIndex > -1) taskListModel.setTaskProperty(taskIndex, JS.baseFeatures.fullTxt, text)
        if (taskIndex === -1) taskListModel.addTask(text)
    }
}

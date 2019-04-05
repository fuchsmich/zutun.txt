import QtQuick 2.2
import Sailfish.Silica 1.0

import "../components"
import "../tdt/todotxt.js" as JS

Dialog {
    id: dialog

    //-1 for adding new task
    property int itemIndex: -1
    property alias text: ta.text

    function setText(type, txt) {
        console.debug(type, txt)
        var cp = ta.cursorPosition
        var l = ta.text.length
        switch (type) {
        case "priorities":
            ta.text = JS.baseFeatures.modifyLine(ta.text, JS.baseFeatures.priority, txt.charAt(1))
            ta.cursorPosition = cp + (ta.text.length - l)
            break
        case "projects":
        case "contexts":
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
            ta.focusTimer.start()
            ta.cursorPosition = cp + (ta.text.length - l)
            break
        }
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
                title: (itemIndex == -1 ? qsTr("Add New Task") : qsTr("Edit Task"))
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

                EditItem {
                    //set priority
                    id: eip
                    Label {
                        width: parent.width
                        height: width
                        text: "(A)"
                        font.pixelSize: Theme.fontSizeLarge
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        openMenu()
                    }

                    menu: EditContextMenu {
                        SilicaListView {
                            width: parent.width
                            height: Theme.itemSizeMedium
                            orientation: ListView.Horizontal
                            model: ListModel {
                                id: prioritiesModel
                                Component.onCompleted: {
                                    for (var a in JS.alphabet) {
                                        append({"name": "(" + JS.alphabet[a] + ") "});
                                    }
                                }
                            }

                            delegate: MouseArea {
                                width: Theme.itemSizeMedium
                                height: parent.height
                                //anchors.fill: parent
                                onClicked: {
                                    console.log(text)
                                    eip.closeMenu()
                                    setText("priorities", model.name)
                                }
                                Label {
                                    anchors.centerIn: parent
                                    text: model.name
                                }
                            }
                            HorizontalScrollDecorator { }
                        }
                    }
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
                        var cp = ta.cursorPosition;
                        var tl = ta.text.length
                        ta.text = JS.baseFeatures.modifyLine(ta.text, JS.baseFeatures.priority, false)
                        ta.focusTimer.start()
                        ta.cursorPosition = cp + (ta.text.length - tl)
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

                    model: ttm1.filters.projectsModel
                    onListItemSelected: setText("projects", text)
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

                    model: ttm1.filters.contextsModel
                    onListItemSelected: setText("contexts", text)
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
                        var cp = ta.cursorPosition;
                        var tl = ta.text.length
                        ta.text = JS.due.set(ta.text, "")
                        ta.focusTimer.start()
                        ta.cursorPosition = cp + (ta.text.length - tl)
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
        ttm1.tasks.setFullTxt(itemIndex, ta.text);
    }
}

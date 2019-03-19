import QtQuick 2.5
import Sailfish.Silica 1.0
//import QtQuick.Layouts 1.0

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
            Grid { //turn into GridLayout for more Icons?
                x: Theme.horizontalPageMargin
                spacing: Theme.paddingSmall
                width: parent.width
                horizontalItemAlignment: Grid.AlignHCenter
                verticalItemAlignment: Grid.AlignVCenter
                columns: Math.floor(width/btn.width)
                Button {
                    //set priority
                    id: btn
                    width: height
                    text: "(A)"
                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("TextSelect.qml"), {state: "priorities"})
                    }
                }
                Button {
                    //remove priority
                    width: height
                    Label {
                        anchors.centerIn: parent
                        text: "(A)"
                        font.strikeout: true
                    }
                    onClicked: {
                        var cp = ta.cursorPosition;
                        var tl = ta.text.length
                        ta.text = JS.baseFeatures.modifyLine(ta.text, JS.baseFeatures.priority, false)
                        ta.focusTimer.start()
                        ta.cursorPosition = cp + (ta.text.length - tl)
                    }
                }
                IconButton {
                    //
                    icon.source: "image://theme/icon-l-date"
                    onClicked: {
                        var cp = ta.cursorPosition;
                        var tl = ta.text.length
                        ta.text = JS.baseFeatures.modifyLine(ta.text, JS.baseFeatures.creationDate, JS.today())
                        ta.focusTimer.start()
                        ta.cursorPosition = cp + (ta.text.length - tl)
                    }
                }
                Button {
                    width: height
                    text: "+"
                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("TextSelect.qml"), {state: "projects"})
                    }
                }
                Button {
                    width: height
                    text: "@"
                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("TextSelect.qml"), {state: "contexts"})
                    }
                }
                Button {
                    width: height
                    text: "due:"
                    onClicked: {
                        var dueDate = JS.due.get(ta.text)[0]
                        dueDate = (dueDate === "" ? new Date() : new Date(dueDate))
                        var datePicker = pageStack.push("DateSelect.qml", {date: dueDate})
                        datePicker.accepted.connect(function() {
                            console.log(Qt.formatDate(datePicker.date, 'yyyy-MM-dd'));
                            ta.text = JS.due.set(ta.text, datePicker.date);
//                            ta.text = JS.due.set(ta.text, Qt.formatDate(datePicker.date, 'yyyy-MM-dd'));
                        })
                    }
                    Component {
                        id: datePickerComp
                        DateSelect { }
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

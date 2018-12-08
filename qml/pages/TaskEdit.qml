import QtQuick 2.5
import Sailfish.Silica 1.0
//import QtQuick.Layouts 1.0

import "../tdt/todotxt.js" as JS

Dialog {
    id: dialog

    //-1 for adding new task
    property int itemIndex: -1
    property alias text: ta.text

    property string selectedPriority
    onSelectedPriorityChanged:{
        var cp = ta.cursorPosition;
        var l = ta.text.tim().length;
        ta.text = JS.baseFeatures.modifyLine(ta.text, JS.baseFeatures.priority, selectedPriority);
        ta.cursorPosition = cp + (ta.text.length - l);
    }

    property string appendText
    onAppendTextChanged: {
        var cp = ta.cursorPosition;
        var l = ta.text.trim().length;
        ta.text = (ta.text.trim() + " " + appendText).trim() + " ";
        //ta.cursorPosition = cp + (ta.text.length - l);
    }

    property string insertText
    onInsertTextChanged: {
        var cp = ta.cursorPosition;
        var l = ta.text.trim().length;
        ta.text = (ta.text.trim() + " " + appendText).trim() + " ";
        //ta.cursorPosition = cp + (ta.text.length - l);
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
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: focus = false
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
                    id: btn
//                    height: Theme.iconSizeExtraLarge
                    width: height
                    text: "(A)"
                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("TextSelect.qml"), {state: "priorities"})
                    }
                }
                Button {
//                    height: Theme.iconSizeLarge
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
//                    height: Theme.iconSizeLarge
                    width: height
                    text: "+"
                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("TextSelect.qml"), {state: "projects"})
                    }
                }
                Button {
//                    height: Theme.iconSizeLarge
                    width: height
                    text: "@"
                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("TextSelect.qml"), {state: "contexts"})
                    }
                }
                Button {
//                    height: Theme.iconSizeLarge
                    width: height
                    text: "due:"
                    onClicked: {
                        var datePicker = pageStack.push(datePickerComp)
                        datePicker.accepted.connect(function() {
                            console.log(Qt.formatDate(datePicker.date, 'yyyy-MM-dd'));
                            ta.text = JS.due.set(ta.text, datePicker.date);
//                            ta.text = JS.due.set(ta.text, Qt.formatDate(datePicker.date, 'yyyy-MM-dd'));
                        })
                    }
                    Component {
                        id: datePickerComp
                        DatePickerDialog {
//                            date: JS.today()
                        }
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

import QtQuick 2.0
import Sailfish.Silica 1.0

import "../tdt/todotxt.js" as JS

Dialog {
    id: dialog

    property int itemIndex: -1
    property alias text: ta.text

    property string selectedPriority
    onSelectedPriorityChanged: {
        var cp = ta.cursorPosition;
        var tl = ta.text.length;
        ta.text = JS.baseFeatures.modifyLine(ta.text, JS.baseFeatures.priority, selectedPriority)
        ta.forceActiveFocus()
        ta.cursorPosition = cp + (ta.text.length - tl)
    }

    property string appendText
    onAppendTextChanged: {
        var cp = ta.cursorPosition
        ta.text += " " + appendText + " "
        ta.forceActiveFocus()
        ta.cursorPosition = cp
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
                title: "Edit Task"
            }
            TextArea {
                id: ta
                width: dialog.width
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
            }
            Row { //turn into GridLayout for more Icons?
                x: Theme.horizontalPageMargin
                spacing: Theme.paddingSmall
                Button {
                    height: parent.height
                    width: height
                    text: "(A)"
                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("TextSelect.qml"), {state: "priorities"})
                    }
                }
                Button {
                    height: parent.height
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
                    height: parent.height
                    width: height
                    text: "+"
                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("TextSelect.qml"), {state: "projects"})
                    }
                }
                Button {
                    height: parent.height
                    width: height
                    text: "@"
                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("TextSelect.qml"), {state: "contexts"})
                    }
                }
// TODO                Button {
//                    height: parent.height
//                    width: height
//                    text: "due:"
//                    onClicked: {
//                open calendar
//                    }
//                }
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

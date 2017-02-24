import QtQuick 2.0
import Sailfish.Silica 1.0

import "../tdt/todotxt.js" as JS



Dialog {
    id: dialog
    //    acceptDestination: page
    acceptDestinationAction: PageStackAction.Pop

    property int itemIndex: -1
    property string text
    property string selectedPriority
    onSelectedPriorityChanged:
        ta.text = JS.baseFeatures.modifyLine(ta.text, JS.baseFeatures.priority, selectedPriority)

    property string appendText
    onAppendTextChanged: {
        ta.text += " " + appendText;
    }


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
                text: dialog.text
                EnterKey.enabled: text.length > 0
                EnterKey.iconSource: "images://theme/icon-m-enter-close"
                EnterKey.onClicked: focus = false
            }
            Row {
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
                    onClicked: ta.text = JS.baseFeatures.modifyLine(ta.text, JS.baseFeatures.priority, false)
                    Label {
                        anchors.centerIn: parent
                        text: "(A)"
                        font.strikeout: true
                    }
                }
                IconButton {
                    icon.source: "image://theme/icon-l-date"

                    onClicked: {
                        ta.text = JS.baseFeatures.modifyLine(ta.text, JS.baseFeatures.creationDate, JS.today())
                        ta.focus = true; //soll eigentl das keyboard wieder aktivieren, geht aber nicht immer.
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
            }
        }

    }
    Component {
        id: ts
        TextSelect {

        }
    }

    Component.onCompleted: ta.focus = true;

    onAccepted: {
        ta.focus = false; //damit das Keyboard einklappt
        ttm1.tasks.setFullTxt(itemIndex, ta.text);
        pageStack.navigateBack();
    }
    onCanceled: {
        ta.focus = false; //damit das Keyboard einklappt
        pageStack.navigateBack();
    }
}

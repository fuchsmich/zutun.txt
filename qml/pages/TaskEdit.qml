import QtQuick 2.0
import Sailfish.Silica 1.0



Dialog {
    id: dialog
    //    acceptDestination: page
    acceptDestinationAction: PageStackAction.Pop

    property int itemIndex
    property string text
    property string selectedPriority
    onSelectedPriorityChanged: {
        var matches = ta.text.match(/^(x\s)?(\d{4}-\d{2}-\d{2}\s)?(\([A-Z]\)\s)?(\d{4}-\d{2}-\d{2}\s)?(.*)/);
        var newstring = "";
        for (var m in matches) {
            if ( m == 3) newstring += selectedPriority;
            else if ( m > 0 && matches[m] !== undefined ) {
                newstring += matches[m];
            }
            //            console.log(m, newstring, selectedPriority)
        }
        ta.text = newstring;
    }

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
                IconButton {
                    icon.source: "image://theme/icon-l-date"

                    onClicked: {
                        //TODO manchmal wird der ganze Text durchs datum ersetzt
                        var matches = ta.text.match(/^(x\s)?(\d{4}-\d{2}-\d{2}\s)?(\([A-Z]\)\s)?(\d{4}-\d{2}-\d{2}\s)?(.*)/);
                        var newstring = "";
                        for (var m in matches) {
                            if ( m == 4) newstring += tdt.today() + " ";
                            else if ( m > 0 && matches[m] !== undefined ) {
                                newstring += matches[m];
                            }
                            //            console.log(m, newstring, selectedPriority)
                        }
                        ta.text = newstring;
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
        tdt.setFullText(itemIndex, ta.text);
        pageStack.navigateBack();
    }
    onCanceled: {
        ta.focus = false; //damit das Keyboard einklappt
        pageStack.navigateBack();
    }
}

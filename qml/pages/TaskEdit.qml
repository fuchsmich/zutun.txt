import QtQuick 2.0
import Sailfish.Silica 1.0


//TODO project/context einfügen

Dialog {
    id: dialog
    //    acceptDestination: page
    acceptDestinationAction: PageStackAction.Pop

    property int itemIndex
    property string text

    Column {
        anchors.fill: parent
        DialogHeader {
            title: "Edit Task"
        }
        TextArea {
            id: ta
            width: dialog.width
            text: dialog.text
        }
        Row {
            x: Theme.horizontalPageMargin
            spacing: Theme.paddingSmall
            IconButton {
                icon.source: "image://theme/icon-l-date"
                onClicked: {
                    ta.text = tdt.today() + " " + ta.text;
                    ta.focus = true; //soll eigentl das keyboard wieder aktivieren, geht aber nicht immer.
                }
            }
            Button {
                height: parent.height
                width: height
                text: "@"
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("ProjectFilter.qml"))
                }
            }
            Button {
                height: parent.height
                width: height
                text: "+"
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("ProjectFilter.qml"))
                }
            }
        }
    }
    //TODO sh. Hilfe für Dialog!!
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

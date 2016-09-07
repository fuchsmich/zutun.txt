import QtQuick 2.0
import Sailfish.Silica 1.0


Dialog {
    id: dialog
    //    acceptDestination: page
    acceptDestinationAction: PageStackAction.Pop

    property int itemIndex
    property string text

    onItemIndexChanged: {
        console.log(text);
        //                ta.text = tdt.taskList[dialog.itemIndex][0];
    }

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
            IconButton {
                icon.source: "image://theme/icon-l-date"
                onClicked: {
                    ta.text = tdt.today() + " " + ta.text
                }
            }
        }
    }
    onAccepted: {
        tdt.setFullText(itemIndex, ta.text);
        pageStack.pop();
    }
    onCanceled: {
        pageStack.pop();
    }
}

import QtQuick 2.0
import Sailfish.Silica 1.0


Dialog {
    acceptDestination: firstPage
    acceptDestinationAction: PageStackAction.Pop
    property int index

    Column {
        anchors.fill: parent
        TextArea {
            id: ta
            text: tdt.taskList[index][tdt.fullTxT]
        }
    }
    onAccepted: {
        tdt.setFullText(index, ta.text);
        pageStack.pop();
    }
    onCanceled: {
        pageStack.pop();
    }
}






import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {

    Image {
        //TODO nochmal aus SVG erstellen -> git sh. ownnotes
        source: "coversmall.png"
        anchors.centerIn: parent
        opacity: 0.2
        scale: 1.0

    }

    Column {
        anchors.fill: parent
        anchors.margins: Theme.paddingMedium
        Repeater {
            model: tdt.tasksModel
            Label {
                text: model.displayText
                width: parent.width
                truncationMode: TruncationMode.Elide
                visible: !(model.done || !tdt.filters.itemVisible(index))
            }
        }
    }

    CoverActionList {
        id: coverAction

        CoverAction {
            iconSource: "image://theme/icon-cover-new"
            onTriggered: {
                pageStack.push("../pages/TaskEdit.qml", {index: -1, text: ""});
                app.activate();
            }
        }
    }
//    Component.onCompleted: console.log(width, height)
}



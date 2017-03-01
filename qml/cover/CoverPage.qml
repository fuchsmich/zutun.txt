import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {
id: cb
    Image {
        source: "coversmall.png"
        anchors.centerIn: parent
        opacity: 0.2
        scale: 1.0

    }

    Column {
        anchors.fill: parent
//        anchors.margins: Theme.paddingMedium
        Repeater {
            model: ttm1.tasks
            Label {
                x: Theme.paddingMedium
                text: model.displayText
                width: cb.width - 2*x
                truncationMode: TruncationMode.Elide
//                visible: model.done
            }
        }
    }

    CoverActionList {
        id: coverAction

        CoverAction {
            iconSource: "image://theme/icon-cover-new"
            onTriggered: {
                pageStack.push("../pages/TaskEdit.qml", {itemIndex: -1, text: ""});
                app.activate();
            }
        }
    }

    onStatusChanged: {
        if (status === Cover.Active ) {
            ttm1.reloadFile();
        }
    }
}



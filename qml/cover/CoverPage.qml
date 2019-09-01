import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {
    id: cb
    Image {
        source: "coversmall.png"
        anchors.centerIn: parent
        opacity: 0.2
        anchors.fill: parent
        fillMode: Image.PreserveAspectFit
    }

    SilicaListView {
        anchors.fill: parent
        anchors.margins: Theme.paddingMedium
        clip: true
        model: ttm1.tasks
        delegate: Label {
            text: model.formattedSubject
            width: parent.width - 2*Theme.paddingMedium
            truncationMode: TruncationMode.Elide
        }
    }

    CoverActionList {
        CoverAction {
            iconSource: "image://theme/icon-cover-new"
            onTriggered: {
                app.addTask();
            }
        }
    }

    onStatusChanged: {
        if (status === Cover.Active ) {
            ttm1.readFile();
        }
    }
}



import QtQuick 2.12
import QtQuick.Controls 2.5

Page {
    id: page
    anchors.fill: parent
    title: "Tasklist"


    ListView {
        id: taskListView
        anchors.fill: parent
        model: taskDelegateModel

        section.delegate: Rectangle {
            width: page.width
            height: childrenRect.height
            color: "lightsteelblue"
            Label {
                text: section
                font.pixelSize: Qt.application.font.pixelSize * 1.6
            }
        }
        section.property: "section"

        ScrollIndicator.vertical: ScrollIndicator { }
        keyNavigationEnabled: true
    }

    Column {
        id: column
        anchors.centerIn: parent
        visible: taskListView.count == 0
        Button {
            text: "Load File"
            onClicked: todoTxtFile.read()
        }

        Label { text: "Path: %1".arg(todoTxtFile.path) }
        Label { text: "Path exists: %1".arg(todoTxtFile.pathExists ? "Yes" : "No") }
        Label { text: "File exists: %1".arg(todoTxtFile.exists ? "Yes" : "No") }
        Label { text: "File readable: %1".arg(todoTxtFile.readable ? "Yes" : "No") }
        Label { text: "File writeable: %1".arg(todoTxtFile.writeable ? "Yes" : "No") }
    }
}

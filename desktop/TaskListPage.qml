import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.1


//TODO add task UI (in list header?)
//TODO highlight follows mouse hover?

Page {
    id: page
    anchors.fill: app.window
    title: "Tasklist" + " " + todoTxtFile.path

    ListView {
        id: taskListView
        anchors.fill: parent
        //clip: true

        model: visualModel

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
        focus: true

        headerPositioning: ListView.OverlayHeader
        header: Item {
            height: showSearchBarAction.checked * searchBar.height + addBar.height * addBar.visible
            SearchBar {
                //TODO animate show/hide
                id: searchBar
                width: page.width
                visible: showSearchBarAction.checked
            }
            TextField {
                //TODO animate show/hide
                id: addBar
                property bool show: false
                width: page.width
                visible: show
                Keys.onEscapePressed: {
                    //loader.state = "view"
                    addBar.clear()
                    addBar.show = false
                }
                onEditingFinished: {
                    taskListModel.addTask(addBar.text.trim())
                    addBar.clear()
                    addBar.show = false
                }

                Completer {
                   model: app.completerKeywords
                   calendarKeywords: app.completerCalendardKeywords
                }
                Connections {
                    target: addTaskAction
                    function onTriggered() {
                        addBar.show = true
                    }
                }
            }
        }

        //Keys.onPressed: console.log(currentIndex)
        //Component.onCompleted: forceActiveFocus()
        onCurrentIndexChanged: app.currentTaskIndex = currentIndex
        //onActiveFocusChanged: console.log("lv activeFocus", activeFocus)
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
        //        Label { text: "Path exists: %1".arg(todoTxtFile.pathExists ? "Yes" : "No") }
        //        Label { text: "File exists: %1".arg(todoTxtFile.exists ? "Yes" : "No") }
        //        Label { text: "File readable: %1".arg(todoTxtFile.readable ? "Yes" : "No") }
        //        Label { text: "File writeable: %1".arg(todoTxtFile.writeable ? "Yes" : "No") }
    }
}

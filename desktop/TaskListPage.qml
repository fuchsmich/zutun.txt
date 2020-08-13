import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.1


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

        section {
            property: taskListModel.sorting.sectionProperty //"section"
            criteria: ViewSection.FullString
            delegate: Rectangle {
                width: page.width
                height: childrenRect.height
                color: "lightsteelblue"
                Label {
                    text: section
                    font.pixelSize: Qt.application.font.pixelSize * 1.4
                }
            }
        }

        ScrollIndicator.vertical: ScrollIndicator { }
        focus: true

        headerPositioning: ListView.OverlayHeader
        header: Column {
            //height: showSearchBarAction.checked * searchBar.height + addBar.height * addBar.visible
            SearchBar {
                //TODO animate show/hide
                id: searchBar
                width: page.width
                visible: showSearchBarAction.checked
            }
            ToolBar {
                id: addBar
                property bool show: false
                onShowChanged: {
                    if (show) forceActiveFocus()
                    else addTF.clear()
                }
                visible: show
                width: page.width
                RowLayout {
                    width: parent.width
                    Label {
                        text: qsTr("Add Task:")
                    }

                    TextField {
                        //TODO animate show/hide
                        id: addTF
                        Layout.fillWidth: true

                        Keys.onEscapePressed: {
                            console.log("escape pressed")
                            clear()
                            addBar.show = false
                        }
                        onAccepted: {
                            taskListModel.addTask(text.trim())
                            clear()
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
                    ToolButton {
                        icon.name: "dialog-close"
                        onClicked: addBar.show = false
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

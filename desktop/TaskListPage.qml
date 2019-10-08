import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.1

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
        focus: true

        headerPositioning: ListView.OverlayHeader
        header: ToolBar {
            width: page.width
            Column {
                width: parent.width
                RowLayout {
                    //Actions
                    ToolButton {
                        action: addTaskAction
                    }

                    //Filter
                    ToolButton {
                        action: filterHideDoneAction
                    }
                    ToolButton {
                        action: filterShowSearchBar
                    }

                    //Sort
                    ToolButton {
                        action: toogleSortOrderAction
                    }
                    ComboBox {
                        model: {
                            var m = []
                            for (var i in sorting.groupFunctionList) {
                                m.push(sorting.groupFunctionList[i][0])
                            }
                            return m
                        }
                        currentIndex: sorting.grouping
                        onCurrentIndexChanged: sorting.grouping = currentIndex
                    }
                }
                RowLayout {
                    visible: filterShowSearchBar.checked
                    width: parent.width
                    TextField {
                        //TODO searchbar loses focus. Timer?
                        id: searchField
                        property bool searchBarActive: false
                        Layout.fillWidth: true
                        placeholderText: qsTr("Search")
                        onTextChanged: {
                            searchBarActive = true
                            taskListView.focus = false
                            filters.searchString = text
                        }
                        onVisibleChanged: {
                            if (!visible) text = ""
                            else forceActiveFocus()
                        }
                        Keys.onEscapePressed: filterShowSearchBar.checked = false
                        Connections {
                            target: filterActivateSearch
                            onTriggered: {
                                searchField.forceActiveFocus()
                                searchField.selectAll()
                            }
                        }
                        Connections {
                            target: taskDelegateModel
                            onSortFinished: {
                                if (searchField.searchBarActive) searchField.forceActiveFocus()
                            }
                        }
                    }
                    ToolButton {
                        icon.name: "edit-clear"
                        onClicked: searchField.clear()
                    }
                }
            }
        }
        //Keys.onPressed: console.log(currentIndex)
        //Component.onCompleted: forceActiveFocus()
        onCurrentIndexChanged: app.currentTaskIndex = currentIndex
        onActiveFocusChanged: console.log("lv activeFocus", activeFocus)
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

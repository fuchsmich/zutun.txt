import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.1

Page {
    id: page
    anchors.fill: app.window
    title: "Tasklist" + " " + todoTxtFile.path

    ListView {
        id: taskListView
        anchors.fill: parent
        //clip: true

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
        header:
        SearchBar {
            width: page.width
            z: 2
            //visible: false
        }


            /*Item {
            id: headerItem
            width: page.width
            height: 40* showSearchBarAction.checked //headerLoader.height//(headerLoader.status === Loader.Ready ? headerLoader.item.height : 0)
            Loader {
                id: headerLoader
                Component {
                    id: searchComp
                    SearchBar {
                        width: page.width
                    }
                }
                states: [
                    State {
                        name: "search"
                        when: showSearchBarAction.checked
                        PropertyChanges {
                            target: headerLoader
                            sourceComponent: searchComp
                            //height: headerLoader.item.height
                        }
                    }
//                    ,
//                    State {
//                        name: "empty"
//                        when: !showSearchBarAction.checked
//                        PropertyChanges {
//                            target: headerLoader
//                            sourceComponent: emptyComp
//                            height: 0
//                        }
//                    }
                ]
                onHeightChanged: console.log("height", height)
            }
        }*/

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

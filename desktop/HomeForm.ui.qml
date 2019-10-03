import QtQuick 2.12
import QtQuick.Controls 2.5

Page {
    width: 600
    height: 400

    title: qsTr("Home")

    ListView {
        id: taskListView
        anchors.fill: parent
        //        model: ListModel {
        //            ListElement {
        //                name: "Grey"
        //                colorCode: "grey"
        //            }

        //            ListElement {
        //                name: "Red"
        //                colorCode: "red"
        //            }

        //            ListElement {
        //                name: "Blue"
        //                colorCode: "blue"
        //            }

        //            ListElement {
        //                name: "Green"
        //                colorCode: "green"
        //            }
        //        }
        model: taskListModel
        delegate: Item {
            x: 5
            width: 80
            height: 40
            Row {
                id: row1
                Rectangle {
                    width: 40
                    height: 40
                    color: colorCode
                }

                Text {
                    text: fullTxt
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }
                spacing: 10
            }
        }

        Column {
            id: column
            anchors.centerIn: parent
            Label {
                text: "Path exists: %1".arg(
                          todoTxtFile.pathExists ? "Yes" : "No")
            }
        }
    }
}

/*##^##
Designer {
    D{i:1;anchors_height:160;anchors_width:110;anchors_x:0;anchors_y:0}
}
##^##*/


import QtQuick 2.0
import QtQuick.Controls 2.5

Column {
    id: taskListItem
    property alias done: cb.checked
    property string priority: ""
    property alias subject: id.text
    property alias creationDate: cdLbl.text
    property alias due: dueLbl.text

    signal toggleDone()
    signal editItem()
    signal removeItem()
    signal prioUp()
    signal prioDown()

    Row {
        CheckBox {
            id: cb
            //checkState: model.done*2
            onClicked: toggleDone()
        }
        ItemDelegate {
            id: id
            text: model.formattedSubject
            //text: ListView.model.
            width: taskListItem.width - cb.width
            onClicked: editItem()
        }
    }
    Row {
        anchors.right: parent.right
        anchors.rightMargin: spacing
        spacing: 10
        property int fontSize: 10 //Theme.fontSizeExtraSmall

        Label {
            visible: creationDate !== ""
            text: qsTr("created:")
            font.pixelSize: parent.fontSize
            font.italic: true
            //color: Theme.highlightColor
        }
        Label {
            id: cdLbl
            visible: creationDate !== ""
            font.pixelSize: parent.fontSize
        }
        Label {
            visible: due !== "";
            text: qsTr("due:");
            font.pixelSize: parent.fontSize
            font.italic: true
            //color: Theme.highlightColor
        }
        Label {
            id: dueLbl
            visible: due !== ""
            font.pixelSize: parent.fontSize
        }
    }
}

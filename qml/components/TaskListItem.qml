import QtQuick 2.6
import QtQml.Models 2.2
import Sailfish.Silica 1.0

import "../tdt/todotxt.js" as JS

ListItem {
    id: listItem

//    property alias done: doneSw.checked
//    property string priority: ""
//    property alias subject: lbl.text
//    property alias creationDate: cdLbl.text
//    property alias due: dueLbl.text

//    signal toggleDone()
    signal editItem()
//    signal removeItem()
//    signal prioUp()
//    signal prioDown()

    property string minPriority: "F"

    function priorityUpDown(priority, up) {
        //console.log("A"++)
        if (up) {
            if (priority === "") return String.fromCharCode(minPriority.charCodeAt(0));
            else if (priority > "A") return String.fromCharCode(priority.charCodeAt(0) - 1);
        } else  {
            if (priority !== "") {
                if (priority < "Z") return String.fromCharCode(priority.charCodeAt(0) + 1);
                return ""
            }
        }
        return priority
    }

    function remove() {
        remorseAction(qsTr("Deleting"), function() {
            removeItem()
        }, 3000)
    }

    width: ListView.view.width
    contentHeight: Math.max(col.height, Theme.itemSizeExtraSmall)
    onClicked: editItem()

    Column {
        id: col
        width: parent.width
        anchors.verticalCenter: parent.verticalCenter
        Row {
            id: row
            height: lbl.height
            Switch {
                id: doneSw
                height: parent.height
                automaticCheck: false
                checked: model.done
                onClicked: {
                    model.done = !checked
                    listItem.DelegateModel.groups = "unsorted"
                }
            }
            Label {
                id:lbl
                width: listItem.width - doneSw.width - 2*Theme.horizontalPageMargin
                text: model.formattedSubject
                linkColor: Theme.primaryColor
                textFormat: Text.StyledText
                wrapMode: Text.Wrap
                font.strikeout: model.done
                font.pixelSize: settings.fontSizeTaskList
                onLinkActivated: {
                    console.log("link activated", link)
                    Qt.openUrlExternally(link)
                }
            }
        }
        Row {
            height: cdLbl.height
            anchors.right: parent.right
            anchors.rightMargin: Theme.horizontalPageMargin
            spacing: Theme.paddingSmall
            property int fontSize: Theme.fontSizeExtraSmall

            Label {
                visible: model.creationDate !== ""
                text: qsTr("created:")
                font.pixelSize: parent.fontSize
                color: Theme.highlightColor
            }
            Label {
                id: cdLbl
                visible: model.creationDate !== ""
                text: model.creationDate
                font.pixelSize: parent.fontSize
            }
            Label {
                visible: model.due !== ""
                text: qsTr("due:")
                font.pixelSize: parent.fontSize
                color: Theme.highlightColor
            }
            Label {
                id: dueLbl
                visible: model.due !== ""
                text: model.due
                font.pixelSize: parent.fontSize
            }
        }
    }

    menu: ContextMenu {
        MenuItem {
            visible: !(model.done || model.priority === "A")
            text: qsTr("Priority Up")
            onClicked: {
                model.priority = priorityUpDown(model.priority, true)
                listItem.DelegateModel.groups = "unsorted"
            }
        }
        MenuItem {
            visible: !(model.done || model.priority === "")
            text: qsTr("Priority Down")
            onClicked: {
                model.priority = priorityUpDown(model.priority, true)
                listItem.DelegateModel.groups = "unsorted"
            }
        }
        MenuItem {
            text: qsTr("Remove")
            onClicked: remove()
        }
    }

}

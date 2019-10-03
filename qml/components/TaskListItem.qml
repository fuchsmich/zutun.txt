import QtQuick 2.6
import Sailfish.Silica 1.0

import "../tdt/todotxt.js" as JS

ListItem {
    id: listItem

    property alias done: doneSw.checked
    property string priority: ""
    property alias subject: lbl.text
    property alias creationDate: cdLbl.text
    property alias due: dueLbl.text

    signal toggleDone()
    signal editItem()
    signal removeItem()
    signal prioUp()
    signal prioDown()

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
                height: lbl.height
                automaticCheck: false
                checked: listItem.done
                onClicked: toggleDone()
            }

            Label {
                id:lbl

                width: listItem.width - doneSw.width - 2*Theme.horizontalPageMargin
                linkColor: Theme.primaryColor
                textFormat: Text.StyledText
                wrapMode: Text.Wrap
                font.strikeout: listItem.done
                font.pixelSize: settings.fontSizeTaskList

                onLinkActivated: {
                    console.log("opening", link)
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
                visible: creationDate !== "";
                text: qsTr("created:");
                font.pixelSize: parent.fontSize
                color: Theme.highlightColor
            }
            Label {
                id: cdLbl
                visible: creationDate !== "";
                font.pixelSize: parent.fontSize
            }
            Label {
                visible: due !== "";
                text: qsTr("due:");
                font.pixelSize: parent.fontSize
                color: Theme.highlightColor
            }
            Label {
                id: dueLbl
                visible: due !== ""
                font.pixelSize: parent.fontSize
            }
        }
    }

    menu: ContextMenu {
        MenuItem {
            visible: !(done || priority === "A")
            text: qsTr("Priority Up")
            onClicked: prioUp()
        }
        MenuItem {
            visible: !(done || priority === "")
            text: qsTr("Priority Down")
            onClicked: prioDown()
        }
        MenuItem {
            text: qsTr("Remove")
            onClicked: remove()
        }
    }

}

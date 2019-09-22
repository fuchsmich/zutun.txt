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
    contentHeight: Math.max(col.height, Theme.itemSizeExtraSmall)*fadeFactor
    onClicked: editItem()

    Column {
        id: col
        width: parent.width
        anchors.verticalCenter: parent.verticalCenter
        Row {
            id: row
            //            x: Theme.horizontalPageMargin
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
                //text: formatText(parser.linkedText)
                textFormat: Text.StyledText
                wrapMode: Text.Wrap
                font.strikeout: listItem.done
                font.pixelSize: settings.fontSizeTaskList

                onLinkActivated: {
                    //if (defaultLinkActions) {
                    console.log("opening", link)
                    Qt.openUrlExternally(link)
                    //}
                }
            }
        }
        Row {
            //                            x: Theme.horizontalPageMargin
            height: cdLbl.height
            anchors.right: parent.right
            anchors.rightMargin: Theme.horizontalPageMargin
            spacing: Theme.paddingSmall
            property int fontSize: Theme.fontSizeExtraSmall

            Label {
                visible: creationDate !== "";
                text: qsTr("created:");
                font.pixelSize: parent.fontSize
                //font.bold: true;
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
        //                    DetailItem { visible: model.creationDate !== ""; label: qsTr("Creation Date"); value: model.creationDate }
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

    property real fadeFactor: 1
//    opacity: fadeFactor

//    ListView.onAdd: SequentialAnimation{
////        alwaysRunToEnd:  true
////        PropertyAction {
////            target: listItem
////            property: "fadeFactor"
////            value: 1
////        }
////        NumberAnimation {
////            target: listItem
////            properties: "fadeFactor, opacity"
////            //from: 0;
////            to: 1
////            duration: 1500
////            easing.type: Easing.InOutQuad
////        }
//        ScriptAction {
//            script: {
////                listItem.fadeFactor= 1
//                console.log("adding", listItem.fadeFactor, listItem.subject)
//            }
//        }
//    }

//    ListView.onRemove:  SequentialAnimation {
////        ScriptAction {
////            script: listItem.ListView.delayRemove = true
////        }
////        alwaysRunToEnd:  true
////        NumberAnimation {
////            target: listItem;
////            properties: "fadeFactor, opacity";
////            to: 0;
////            duration: 1500;
////            easing.type: Easing.InOutQuad
////        }
//        ScriptAction {
//            script: {
////                listItem.ListView.delayRemove = false
//                console.log("removing", listItem.fadeFactor, listItem.subject)
//            }
//        }
//    }

    Component.onDestruction: console.log(model.index, "I'm gone.")
}

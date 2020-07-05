import QtQuick 2.6
import QtQml.Models 2.2
import Sailfish.Silica 1.0

import "../tdt/todotxt.js" as JS

ListItem {
    id: listItem

    signal editItem()
    onEditItem: ListView.view.editTask(model.index, model.fullTxt)
    signal resortItem()

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
            JS.taskList.removeTask(model.index)
        }, 3000)
    }

    width: ListView.view.width //app.width //ListView.view.width
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
                    //model.done = !checked //geht nicht in 5.6
                    JS.taskList.modifyTask(model.index, JS.baseFeatures.done, !checked)
                    listItem.resortItem()
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
            Label {
                visible: model.completionDate !== ""
                text: qsTr("completed:")
                font.pixelSize: parent.fontSize
                color: Theme.highlightColor
            }
            Label {
                //id: compLbl
                visible: model.completionDate !== ""
                text: model.completionDate
                font.pixelSize: parent.fontSize
            }
        }
    }

    menu: ContextMenu {
        MenuItem {
            visible: !(model.done || model.priority === "A")
            text: qsTr("Priority Up")
            onClicked: {
                JS.taskList.modifyTask(model.index, JS.baseFeatures.priority, priorityUpDown(model.priority, true))
                //model.priority = priorityUpDown(model.priority, true)
                resortItem()
            }
        }
        MenuItem {
            visible: !(model.done || model.priority === "")
            text: qsTr("Priority Down")
            onClicked: {
                JS.taskList.modifyTask(model.index, JS.baseFeatures.priority, priorityUpDown(model.priority, false))
                //model.priority = priorityUpDown(model.priority, true)
                resortItem()
            }
        }
        MenuItem {
            text: qsTr("Remove")
            onClicked: remove()
        }
    }

}

import QtQuick 2.6
import QtQml.Models 2.2
import Sailfish.Silica 1.0
import QtQml 2.2

import "../tdt/todotxt.js" as JS


ListItem {
    id: listItem

    signal editItem()

    function remove() {
        remorseAction(qsTr("Deleting"), function() {
            taskListModel.removeTask(model.index)
        }, 3000)
    }

    width: ListView.view.width
    contentHeight: (Math.max(col.height, Theme.itemSizeExtraSmall) + Theme.paddingSmall)// * visible
    onClicked: editItem()
    //visible: taskListModel.filters.visibility(model)
    //Component.onCompleted: console.debug(model)

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
                //automaticCheck: true
                checked: model.done
                onClicked: {
                    taskListModel.setTaskProperty(model.index, JS.baseFeatures.done, checked)
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
                    console.debug("link activated", link)
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
                text: JS.tools.isoToDate(model.due, Locale.NarrowFormat)
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
                text: JS.tools.isoToDate(model.completionDate, Locale.NarrowFormat)
                font.pixelSize: parent.fontSize
            }
        }
    }

    menu: ContextMenu {
        MenuItem {
            visible: !(model.done || model.priority === "A")
            text: qsTr("Priority Up")
            onClicked: {
                var prio = taskListModel.alterPriority(model.priority, true)
                console.debug(prio)
                taskListModel.setTaskProperty(model.index, JS.baseFeatures.priority, prio)
            }
        }
        MenuItem {
            visible: !(model.done || model.priority === "")
            text: qsTr("Priority Down")
            onClicked: {
                var prio = taskListModel.alterPriority(model.priority, false)
                console.debug(prio)
                taskListModel.setTaskProperty(model.index, JS.baseFeatures.priority, prio)
            }
        }
        MenuItem {
            text: qsTr("Remove")
            onClicked: remove()
        }
    }

}

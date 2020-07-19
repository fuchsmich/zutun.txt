import QtQuick 2.6
import QtQml.Models 2.2
import Sailfish.Silica 1.0

import "../tdt/todotxt.js" as JS


ListItem {
    id: listItem

    signal editItem()

    function remove() {
        remorseAction(qsTr("Deleting"), function() {
            visualModel.removeTask(model.index)
        }, 3000)
    }

    width: ListView.view.width
    contentHeight: Math.max(col.height, Theme.itemSizeExtraSmall) * visible
    onClicked: editItem()
    visible: visualModel.filters.visibility(model)
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
                    visualModel.setTaskProperty(model.index, JS.baseFeatures.done, checked)
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
                text: (Date.fromLocaleString(Qt.locale(), model.due, "yyyy-MM-dd")).toLocaleDateString(Qt.locale(), Locale.NarrowFormat)
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
                text: (Date.fromLocaleString(Qt.locale(), model.completionDate, "yyyy-MM-dd")).toLocaleDateString(Qt.locale(), Locale.NarrowFormat)
                font.pixelSize: parent.fontSize
            }
        }
    }

    menu: ContextMenu {
        MenuItem {
            visible: !(model.done || model.priority === "A")
            text: qsTr("Priority Up")
            onClicked: {
                var prio = visualModel.alterPriority(model.priority, true)
                console.debug(prio)
                visualModel.setTaskProperty(model.index, JS.baseFeatures.priority, prio)
            }
        }
        MenuItem {
            visible: !(model.done || model.priority === "")
            text: qsTr("Priority Down")
            onClicked: {
                var prio = visualModel.alterPriority(model.priority, false)
                console.debug(prio)
                visualModel.setTaskProperty(model.index, JS.baseFeatures.priority, prio)
            }
        }
        MenuItem {
            text: qsTr("Remove")
            onClicked: remove()
        }
    }

}

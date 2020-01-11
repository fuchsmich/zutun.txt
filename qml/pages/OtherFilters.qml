import QtQuick 2.0
import Sailfish.Silica 1.0


//TODO filter tasks with/without creationDate etc.

Page {
    id: page
    SilicaFlickable {
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                //: PullDown menu: go to filter contexts page
                text: qsTr("Filter contexts")
                onClicked: pageStack.pop();
            }
            MenuItem {
                //: PullDown menu: go to filter projects page
                text: qsTr("Filter projects")
                onClicked: pageStack.pop();
            }
            MenuItem {
                //: PullDown menu: go to task list
                text: qsTr("Back to Tasklist")
                onClicked: {
                    pageStack.pop(pageStack.find(function(p){ return (p._depth === 0)}))
                }
            }
        }

        contentHeight: column.height + Theme.paddingLarge


        Column {
            id: column
            width: parent.width
            PageHeader {
                //: PageHeader for other filters
                title: qsTr("Other filters");
            }

            TextSwitch {
                x: Theme.horizontalPageMargin
                //: TextSwitch for handling of completed task visibility
                text: qsTr("Hide completed tasks")
                checked: filterSettings.hideDone
                onClicked: filterSettings.hideDone = checked
            }
        }
    }
}

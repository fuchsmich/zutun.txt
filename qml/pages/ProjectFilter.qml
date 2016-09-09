import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page

    SilicaListView {
        id: lv
        anchors.fill: parent
        VerticalScrollDecorator {}
        PullDownMenu {
            MenuItem {
                text: qsTr("Other Filters")
                onClicked: pageStack.push(Qt.resolvedUrl("ProjectFilter.qml"));
            }
            MenuItem {
                text: qsTr("Context Filters")
                onClicked: pageStack.push(Qt.resolvedUrl("ContextFilter.qml"));
            }
            MenuItem {
                text: qsTr("Project Filters")
                onClicked: pageStack.push(Qt.resolvedUrl("ProjectFilter.qml"));
            }
            MenuItem {
                text: qsTr("Back To Tasklist")
                onClicked:{
                    //pageStack.replaceAbove(null, app.initialPage);
                    pageStack.pop(taskListPage);
                }
            }
        }

        header: PageHeader {
            title: qsTr("Projects")
            description: pageStack.depth
        }

        property var plist: tdt.getProjectList();
        model: plist
        delegate: Item {
            width: page.width
            height: Math.max(btn.height, lbl.height) + Theme.paddingLarge
            Button {
                id: btn
                visible: index === 0
                anchors.centerIn: parent
                text: "clear filter"
                onClicked: if (index === 0) tdt.pfilter = "";
            }
            ListItem {
                visible: index !== 0
                Label {
                    id: lbl
                    x: Theme.horizontalPageMargin
                    text: lv.plist[index]
                }
                onClicked: {
                    if (index === 0) tdt.pfilter = "";
                    else tdt.pfilter = lbl.text;
                    pageStack.navigateBack();
                }
            }
        }
    }
    onStatusChanged: {
        if (status === PageStatus.Active /*&& pageStack.depth === 1 */) {
            pageStack.pushAttached("ContextFilter.qml", {list: tdt.getContextList()});
        }
    }
}

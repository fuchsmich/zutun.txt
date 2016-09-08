import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page

    SilicaListView {
        id: lv
        anchors.fill: parent
        VerticalScrollDecorator {}
        header: PageHeader {
            title: qsTr("Contexts") + pageStack.depth;
        }

        PullDownMenu {
            MenuItem {
                text: qsTr("Other Filters")
                onClicked: pageStack.push(Qt.resolvedUrl("ProjectFilter.qml"));
            }
            MenuItem {
                text: qsTr("Context Filters")
                onClicked: pageStack.push(Qt.resolvedUrl("ProjectFilter.qml"));
            }
            MenuItem {
                text: qsTr("Project Filters")
                onClicked: pageStack.push(Qt.resolvedUrl("ProjectFilter.qml"));
            }
            MenuItem {
                text: qsTr("Back To Tasklist")
                onClicked: {
                    pageStack.replaceAbove(null, app.initialPage);
//                    pageStack.popAttached();
//                    pageStack.pop();
//                    pageStack.popAttached(pageStack.previousPage());
                }
            }
        }

        property var plist: tdt.getContextList();
        model: plist
        delegate: ListItem {
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
    onStatusChanged: {
        if (status === PageStatus.Active /*&& pageStack.depth === 1 */) {
            pageStack.pushAttached("ContextFilter.qml", {});
        }
    }
}

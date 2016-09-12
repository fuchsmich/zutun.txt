import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page
    property var list: tdt.getContextList();

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
                text: qsTr("Project Filters")
                onClicked: pageStack.push(Qt.resolvedUrl("ProjectFilter.qml"));
            }
            MenuItem {
                text: qsTr("Back To Tasklist")
                onClicked: {
                    //                    pageStack.replaceAbove(null, app.initialPage);
                    //                    pageStack.pop(taskListPage);
                    pageStack.pop(pageStack.find(function(p){ return (p._depth === 0)}))
                }
            }
        }

        model: list
        delegate: Item {
            width: page.width
            height: Math.max(btn.height, lbl.height) + Theme.paddingLarge
            Button {
                id: btn
                visible: index === 0
                anchors.centerIn: parent
                text: "clear filter"
            }

            TextSwitch {
                visible: index !== 0
                id: lbl
                x: Theme.horizontalPageMargin
                text: list[index]
            }
        }
    }

    onStatusChanged: {
//        if (status === PageStatus.Active /*&& pageStack.depth === 1 */) {
//            pageStack.pushAttached("OtherFilters.qml", {});
//        }
    }
}

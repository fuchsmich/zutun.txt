import QtQuick 2.0
import Sailfish.Silica 1.0


Page {
    id:page

    SilicaListView {
        id: lv
        anchors.fill: parent
        VerticalScrollDecorator {}
        header: Item {
            width: page.width
            height: pgh.height + cbtn.height

            PageHeader {
                id: pgh
                title: qsTr("Sort Order")
                //                description:
            }
            Button {
                id: cbtn
                width: Theme.buttonWidthLarge
                anchors {
                    top: pgh.bottom
                    topMargin: -Theme.paddingMedium
                    horizontalCenter: parent.horizontalCenter
                }
                text: qsTr("Toggle Order (") + (sortSettings.asc ? "asc" :"desc") + ")"
                onClicked: sortSettings.asc = !sortSettings.asc
            }
        }

        VerticalScrollDecorator {}
        PullDownMenu {
            MenuItem {
                text: qsTr("Reset")
                //                iconsource: "image://theme/icon-m-" + (sortSettings.asc ? "down" :"up")
                onClicked:{
                    sortSettings.asc = true
                    sortSettings.order = 0
                }
            }
            //            MenuItem {
            //                text: qsTr("Toggle order (") + (sortSettings.asc ? "asc" :"desc") + ")"
            ////                iconsource: "image://theme/icon-m-" + (sortSettings.asc ? "down" :"up")
            //                onClicked: sortSettings.asc = !sortSettings.asc
            //            }
        }

        property var list: ttm1.sorting.list
        model: list.length

        delegate: ListItem {
            highlighted: sortSettings.order === model.index
            Label {
                x: Theme.horizontalPageMargin
                anchors.verticalCenter: parent.verticalCenter
                text: lv.list[model.index][0]
            }
            onClicked:{
                sortSettings.order = model.index
                pageStack.navigateBack();
            }
        }
    }
}

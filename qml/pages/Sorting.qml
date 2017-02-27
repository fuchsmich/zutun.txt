import QtQuick 2.0
import Sailfish.Silica 1.0


Page {

//    Row {
//        x: Theme.horizontalPageMargin
//        IconButton {
//            icon.source: "image://theme/icon-m-" + (sortSettings.asc ? "down" :"up")
//            onClicked: sortSettings.asc = !sortSettings.asc
//        }
//        IconButton {
//            icon.source: "image://theme/icon-m-reset"
//            onClicked: {
//                sortSettings.asc = true
//                sortSettings.order = 0
//            }
//        }
//    }


    SilicaListView {
        id: lv
        anchors.fill: parent
        VerticalScrollDecorator {}
        header: PageHeader {
            title: qsTr("Sort Order")
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
            MenuItem {
                text: qsTr("Toggle order (") + (sortSettings.asc ? "asc" :"desc") + ")"
//                iconsource: "image://theme/icon-m-" + (sortSettings.asc ? "down" :"up")
                onClicked: sortSettings.asc = !sortSettings.asc
            }
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

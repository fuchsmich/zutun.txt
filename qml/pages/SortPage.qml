import QtQuick 2.0
import Sailfish.Silica 1.0

//TODO grouping

Page {
    id:page

    SilicaFlickable {
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: col.height + Theme.paddingLarge

        VerticalScrollDecorator {}

        PullDownMenu {
            MenuItem {
                //: PullDown menu: reset SortPage
                text: qsTr("Reset")
                onClicked:{
                    sortSettings.asc = true
                    sortSettings.order = 0
                    sortSettings.grouping = 0
                }
            }
        }

        Column {
            id: col
            spacing: Theme.paddingMedium
            width: parent.width
            PageHeader {
                id: pgh
                //: Title of SortPage
                title: qsTr("Sorting & Grouping")
            }
            Button {
                id: cbtn
                width: Theme.buttonWidthLarge
                anchors.horizontalCenter: parent.horizontalCenter
                //: Button to toggle order
                text: qsTr("Toggle order (%1)").arg(
                          sortSettings.asc ? qsTr("asc") : qsTr("desc"))
                onClicked: sortSettings.asc = !sortSettings.asc
            }

            SectionHeader {
                //: SectionHeader for sorting
                text: qsTr("Sorting")
            }

            Repeater {
                id: rep
                property var list: taskListModel.sorting.functionList
                model: list.length

                delegate: TextSwitch {
                    checked: sortSettings.order === model.index
                    text: rep.list[model.index][0]
                    automaticCheck: false
                    onClicked:{
                        sortSettings.order = model.index
                    }
                }
            }

            SectionHeader {
                //: SectionHeader for grouping
                text: qsTr("Grouping")
            }

            Repeater {
                id: groupRep
                property var list: taskListModel.sorting.groupFunctionList
                model: list.length

                delegate: TextSwitch {
                    checked: sortSettings.grouping === model.index
                    text: groupRep.list[model.index][0]
                    automaticCheck: false
                    onClicked:{
                        sortSettings.grouping = model.index
                    }
                }
            }
        }
    }
}

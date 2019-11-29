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
                text: qsTr("Reset")
                //                iconsource: "image://theme/icon-m-" + (sorting.asc ? "down" :"up")
                onClicked:{
                    sorting.asc = true
                    sorting.order = 0
                    sorting.grouping = 0
                }
            }
        }

        Column {
            id: col
            spacing: Theme.paddingMedium
            width: parent.width
            PageHeader {
                id: pgh
                title: qsTr("Sorting & Grouping")
            }
            Button {
                id: cbtn
                width: Theme.buttonWidthLarge
                                    anchors {
                //                        top: pgh.bottom
                //                        topMargin: -Theme.paddingMedium
                                        horizontalCenter: parent.horizontalCenter
                                    }
                text: qsTr("Toggle Order (") + (sorting.asc ? "asc" :"desc") + ")"
                onClicked: sorting.asc = !sorting.asc
            }

            SectionHeader {
                text: qsTr("Sorting")
            }

            Repeater {
                id: rep
                property var list: sorting.functionList
                model: list.length

                delegate: TextSwitch {
                    checked: sorting.order === model.index
                    text: rep.list[model.index][0]
                    automaticCheck: false
                    onClicked:{
                        sorting.order = model.index
//                        pageStack.navigateBack();
                    }
                }
            }

            SectionHeader {
                text: qsTr("Grouping")
            }

            Repeater {
                id: groupRep
                property var list: sorting.groupFunctionList
                model: list.length

                delegate: TextSwitch {
                    checked: sorting.grouping === model.index
                    text: groupRep.list[model.index][0]
                    automaticCheck: false
                    onClicked:{
                        sorting.grouping = model.index
//                        pageStack.navigateBack();
                    }
                }
            }
        }
    }

}

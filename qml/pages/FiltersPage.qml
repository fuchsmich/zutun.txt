import QtQuick 2.0
import Sailfish.Silica 1.0

import "../tdt"
import "../tdt/todotxt.js" as JS

Page {
    id: page

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: col.height
        PullDownMenu {
            MenuItem {
                text: qsTr("Clear Filters")
                onClicked: taskListModel.filters.clearFilters()
            }
        }

        Column {
            id: col
            width: parent.width


            VerticalScrollDecorator {}

            PageHeader {
                title: qsTr("Filters")
                //: PageHeader for currently set filters
                description: qsTr("Active Filters: %1").arg(taskListModel.filters.text)
            }

            SectionHeader {
                text: qsTr("Projects")
            }

            Component {
                id: pcFilterDelegate
                Row {
                    id: row
                    x: Theme.horizontalPageMargin
                    height: Math.max(ts.height, bt.height)
                    TextSwitch {
                        id: ts
                        width: page.width - 2*row.x - 2*bt.width
                        anchors.verticalCenter: parent.verticalCenter
                        _label.wrapMode: Text.NoWrap
                        text: modelData + " (%1/%2)".arg(
                                  taskListModel.visibleTextList.join("\n").split(modelData).length - 1).arg(
                                  taskListModel.textList.join("\n").split(modelData).length - 1)
                        automaticCheck: false
                        checked: taskListModel.filters.inAnd(modelData) //|| taskListModel.filters.inOr(modelData)
                        onClicked: taskListModel.filters.toggleFilterItem(modelData)
                    }
                    TextSwitch {
                        id: bt
                        enabled: taskListModel.filters.inAnd(modelData)
                        text: "!"
                        width: height
                        checked: taskListModel.filters.inNot(modelData)
                        onClicked: taskListModel.filters.toggleNot(modelData)
                    }
                    TextSwitch {
                        text: "|"
                        enabled: taskListModel.filters.inAnd(modelData)
                        width: height
                        checked: taskListModel.filters.inOr(modelData)
                        onClicked: taskListModel.filters.toggleOr(modelData)
                    }
                }
            }

            Repeater {
                model: JS.projects.getList(taskListModel.textList) //taskListModel.filters.projectList
                delegate: pcFilterDelegate
            }

            SectionHeader {
                text: qsTr("Contexts")
            }

            Repeater {
                model: JS.contexts.getList(taskListModel.textList)
                delegate: pcFilterDelegate

            }


            SectionHeader {
                text: qsTr("Other Filters")
            }

            TextSwitch {
                x: Theme.horizontalPageMargin
                text: qsTr("Hide complete tasks")
                automaticCheck: false
                checked: filterSettings.hideDone
                onClicked: filterSettings.hideDone = !filterSettings.hideDone
            }
        }
    }
}

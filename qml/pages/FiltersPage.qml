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
                onClicked: visualModel.filters.clearFilters()
            }
        }

        Column {
            id: col
            width: parent.width


            VerticalScrollDecorator {}

            PageHeader {
                title: qsTr("Filters")
                //: PageHeader for currently set filters
                description: qsTr("Active Filters: %1").arg(visualModel.filters.text)
            }

            SectionHeader {
                text: qsTr("Projects")
            }

            Repeater {
                model: visualModel.filters.projectList
                delegate: TextSwitch {
                    x: Theme.horizontalPageMargin
                    text: modelData + " (%1/%2)".arg(
                              visualModel.visibleTextList.join("\n").split(modelData).length - 1).arg(
                              visualModel.textList.join("\n").split(modelData).length - 1)
                    automaticCheck: false
                    checked: visualModel.filters.projects.indexOf(modelData) !== -1
                    onClicked: {
                        var a = visualModel.filters.projects
                        if (a.indexOf(modelData) === -1) {
                            a.push(modelData)
                            a.sort()
                        } else {
                            a.splice(a.indexOf(modelData), 1)
                        }
                        filterSettings.projects.value = a
                    }
                }
            }

            SectionHeader {
                text: qsTr("Contexts")
            }

            Repeater {
                model: visualModel.filters.contextList
                delegate: TextSwitch {
                    x: Theme.horizontalPageMargin
                    text: modelData + " (%1/%2)".arg(
                              visualModel.visibleTextList.join("\n").split(modelData).length - 1).arg(
                              visualModel.textList.join("\n").split(modelData).length - 1)
                    automaticCheck: false
                    checked: visualModel.filters.contexts.indexOf(modelData) !== -1
                    onClicked: {
                        var a = visualModel.filters.contexts
                        if (a.indexOf(modelData) === -1) {
                            a.push(modelData)
                            a.sort()
                        } else {
                            a.splice(a.indexOf(modelData), 1)
                        }
                        filterSettings.contexts.value = a
                    }
                }
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

import QtQuick 2.0
import QtQuick.Controls 2.5

import "qrc:/tdt/tdt/todotxt.js" as JS


Page {
    id: page
    anchors.fill: app.window
    Flickable {
        Column {
            Component {
                id: filterItem
                ItemDelegate {
                    width: page.width
                    checkable: true
                    checked: taskListModel.filters.inAnd(modelData)
                    text: modelData + "(%1/%2)".arg(
                              taskListModel.visibleTextList.join("\n").split(modelData).length - 1).arg(
                              taskListModel.textList.join("\n").split(modelData).length - 1)
                    onClicked: taskListModel.filters.toggleFilterItem(modelData)
                    highlighted: checked
                }
            }

            Label { text: qsTr("Projects") }
            Repeater {
                model: JS.projects.getList(taskListModel.textList)
                delegate: filterItem
            }
            Label { text: qsTr("Contexts") }
            Repeater {
                model: JS.contexts.getList(taskListModel.textList)
                delegate: filterItem
            }
        }
    }
}

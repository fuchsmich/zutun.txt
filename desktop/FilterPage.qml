import QtQuick 2.0
import QtQuick.Controls 2.5

Page {
    id: page
    width: parent.width
    Flickable {
        Column {
            Label { text: qsTr("Projects") }
            Repeater {
                model: filters.projects.list
                ItemDelegate {
                    width:page.width
                    checkable: true
                    checked: filters.projects.itemActive(modelData)
                    text: modelData + "(%1/%2)".arg(
                              filters.projects.numTasksHavingItem(modelData, true)).arg(
                              filters.projects.numTasksHavingItem(modelData, false))
                    onClicked: filters.projects.toggleFilter(modelData)
                    highlighted: checked
                }
            }
            Label { text: qsTr("Contexts") }
            Repeater {
                model: filters.contexts.list
                ItemDelegate {
                    width:page.width
                    checkable: true
                    checked: filters.contexts.itemActive(modelData)
                    text: modelData + "(%1/%2)".arg(
                              filters.contexts.numTasksHavingItem(modelData, true)).arg(
                              filters.contexts.numTasksHavingItem(modelData, false))
                    onClicked: filters.contexts.toggleFilter(modelData)
                    highlighted: checked
                }
            }
        }
    }
}

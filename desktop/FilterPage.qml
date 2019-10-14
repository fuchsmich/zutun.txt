import QtQuick 2.0
import QtQuick.Controls 2.5

Page {
    id: page
    width: parent.width
    Flickable {
        Column {
            Label { text: qsTr("Projects") }
            Repeater {
                property var f: filters.projects
                model: f.list
                ItemDelegate {
                    width:page.width
                    checkable: true
                    //TODO doesnt work
                    checked: filters.projects.active.indexOf(modelData) !== -1
                    text: modelData + "(%1/%2)".arg(filters.numTasksWithItem(modelData)).arg(filters.numTasksWithItem(modelData))
                    onClicked: filters.projects.toggleFilter(modelData)
                }
            }
            Label { text: qsTr("Contexts") }
            Repeater {
                property var f: filters.contexts
                model: f.list
                ItemDelegate {
                    checkable: true
                    checked: f.active.indexOf(item) !== -1
                    text: modelData
                    onClicked: f.toggleFilter(modelData)
                }
            }
        }
    }
}

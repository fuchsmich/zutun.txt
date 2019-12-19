import QtQuick 2.0
import Sailfish.Silica 1.0

import "../tdt"

Page {
    id: page
    property bool skip: false
    state: "projects"

    SilicaListView {
        id: lv
        property string btnTxt: "Clear Project Filter"
        property string title: "Projects"

        anchors.fill: parent

        PullDownMenu {
            enabled: lv.count > 0
            MenuItem {
                text: lv.btnTxt
                onClicked: { pcf.clearFilter(page.state); }
            }
        }

        VerticalScrollDecorator {}

        header: PageHeader {
            title: lv.title
            description: qsTr("Active Filters: %1").arg(filters.text())
        }

        ViewPlaceholder {
            enabled: lv.count == 0
            text: qsTr("No entries")
        }

        ProjectContextFilter {
            id: pcf
        }

        model: pcf.list

        function numTasksHavingFilterItem(filterItem, countOnlyVisible) {
            var num = 0
            for (var i = 0; i < taskListModel.count; i++ ) {
                if (taskListModel.get(i).fullTxt.indexOf(filterItem) > -1) {
                    if (countOnlyVisible) {
                        if (filters.visibility(taskListModel.get(i))) num++ //--> binding loop
                    } else num++
                }
            }
            return num
        }

        delegate: ListItem {
            id: li
            property int visibleCount: lv.numTasksHavingFilterItem(modelData, true)
            property int totalCount: lv.numTasksHavingFilterItem(modelData, false)
            property bool active: pcf.itemActive(modelData)
            //enabled: visibleCount > 0
            highlighted: active
            onClicked: pcf.toggleFilter(modelData)
            Label {
                color: (li.enabled ? Theme.primaryColor : Theme.secondaryColor)
                anchors.verticalCenter: parent.verticalCenter
                x: Theme.horizontalPageMargin
                text: modelData + "(%1/%2)".arg(
                          li.visibleCount).arg(
                          li.totalCount)
            }
        }
    }
    onStatusChanged: {
        if (status === PageStatus.Active) {
            if ( pageStack.depth === 1) {
                if (settings.projectFilterLeft) {
                    pageStack.pushAttached(Qt.resolvedUrl("TaskListPage.qml"), {})
                    if (skip) {
                        pageStack.navigateForward(PageStackAction.Immediate)
                        skip = false
                    }
                } else {
                    pageStack.replace(Qt.resolvedUrl("TaskListPage.qml"), {}, PageStackAction.Immediate)
                }
            } else {
                if (state == "contexts") pageStack.pushAttached("OtherFilters.qml")
                if (state == "projects") pageStack.pushAttached("FiltersPage.qml", {state: "contexts"})
            }
        }
    }

    states: [
        State {
            name: "projects"
            PropertyChanges {
                target: lv
                title: qsTr("Filter Projects")
                btnTxt: qsTr("Clear Project Filters")
            }
            PropertyChanges {
                target: pcf
                list: taskListModel.projects
                active: filters.projects
                onActiveChanged: filterSettings.projects.value = pcf.active
            }
        }
        , State {
            name: "contexts"
            PropertyChanges {
                target: lv
                title: qsTr("Filter Contexts")
                btnTxt: qsTr("Clear Context Filters")
            }
            PropertyChanges {
                target: pcf
                list: taskListModel.contexts
                active: filters.contexts
                onActiveChanged: filterSettings.contexts.value = pcf.active
            }
        }

    ]
}

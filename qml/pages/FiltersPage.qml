import QtQuick 2.0
import Sailfish.Silica 1.0

import "../tdt"

Page {
    id: page
    property bool skip: false
    //property TaskDelegateModel visualModel: app.visualModel
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
                onClicked: { filterModel.clearFilter(page.state); }
            }
        }

        VerticalScrollDecorator {}

        header: PageHeader {
            title: lv.title
            description: qsTr("Active Filters: %1").arg(app.visualModel.filters.text())
        }

        ViewPlaceholder {
            enabled: lv.count == 0
            text: qsTr("No entries")
        }

        model: filterModel

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
            enabled: model.visibleCount > 0
            highlighted: model.active
            onClicked: filterModel.toggleFilter(model.name)
            Label {
                color: (li.enabled ? Theme.primaryColor : Theme.secondaryColor)
                anchors.verticalCenter: parent.verticalCenter
                x: Theme.horizontalPageMargin
                text: model.name + "(%1/%2)".arg(
                          model.visibleCount).arg(
                          model.totalCount)
            }
        }
    }

    FilterModel {
        id: filterModel
        visualModel: app.visualModel
    }

    Connections {
        target: app.visualModel
        onSortFinished: filterModel.parseLists()
    }

    onStatusChanged: {
        if (status === PageStatus.Active) {
            if (pageStack.depth === 1) {
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
                target: filterModel
                list: taskListModel.projects
                active: app.visualModel.filters.projects
                onActiveChanged: filterSettings.projects.value = filterModel.active
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
                target: filterModel
                list: taskListModel.contexts
                active: app.visualModel.filters.contexts
                onActiveChanged: filterSettings.contexts.value = filterModel.active
            }
        }

    ]
}

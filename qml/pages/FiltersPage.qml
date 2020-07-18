import QtQuick 2.0
import Sailfish.Silica 1.0

import "../tdt"
import "../tdt/todotxt.js" as JS

Page {
    id: page
    property bool skip: false
    property var visualModel1: visualModel
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
            //: PageHeader for currently set filters
            description: qsTr("Active Filters: %1").arg(visualModel.filters.text())
        }

        ViewPlaceholder {
            enabled: lv.count == 0
            //: Placeholder if empty
            text: qsTr("No entries")
        }

        model: filterModel

        function numTasksHavingFilterItem(filterItem, countOnlyVisible) {
            var num = 0
            visualModel.textList.forEach(function(task){
                if (task.indexOf(filterItem) > -1) {
                    if (countOnlyVisible && filters.visibility(task)) {
                        num++ //--> binding loop
                    } else num++
                }
            })
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
    }

    Connections {
        target: visualModel
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
                //: Title for project + filters
                title: qsTr("Filter projects")
                //: Button for clearing project + filters
                btnTxt: qsTr("Clear project filters")
            }
            PropertyChanges {
                target: filterModel
                list: visualModel.filters.projectList
                active: visualModel.filters.projects
                onActiveChanged: filterSettings.projects.value = filterModel.active
            }
        }
        , State {
            name: "contexts"
            PropertyChanges {
                target: lv
                //: Title for context @ filters
                title: qsTr("Filter contexts")
                //: Button for clearing context @ filters
                btnTxt: qsTr("Clear context filters")
            }
            PropertyChanges {
                target: filterModel
                list: visualModel.filters.contextList
                active: visualModel.filters.contexts
                onActiveChanged: filterSettings.contexts.value = filterModel.active
            }
        }

    ]
}

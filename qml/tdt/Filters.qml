import QtQuick 2.0
import "../tdt/todotxt.js" as JS

QtObject {
    id: filters
    signal filtersChanged()
    property ListModel taskList

    property bool hideDone: true//filterSettings.hideDone

    onHideDoneChanged: filtersChanged() //visualModel.resort()
    property var text: function () {
        var ftext = [(hideDone ? qsTr("Hide Complete"): undefined)].concat(
                    projects.active.concat(
                        contexts.active)).join(", ")
        if (ftext) return ftext
        else return qsTr("None")
    }

    property string searchString: ""
    onSearchStringChanged: filtersChanged()

    property ProjectContextFilter projects: ProjectContextFilter {
        name: "projects"
        list: taskListModel.projects
        //active: filterSettings.projects.value
        onActiveChanged: filtersChanged()
        numTasksHavingItem: filters.numTasksHavingItem
    }
    property ProjectContextFilter contexts: ProjectContextFilter {
        name: "contexts"
        list: taskListModel.contexts
        //active: filterSettings.contexts.value
        onActiveChanged: filtersChanged()
        numTasksHavingItem: filters.numTasksHavingItem
    }

    function clearFilter(filterName) {
        switch(filterName) {
        case "projects": filterSettings.projects.value = []; break;
        case "contexts": filterSettings.contexts.value = []; break;
        }
    }

    function visibility(item) {
        if ((hideDone && item.done)) return false

        if (item.fullTxt.indexOf(searchString) === -1) return false

        for (var p in projects.active) {
            if (item.subject.indexOf(projects.active[p]) === -1) return false
        }
        for (var c in contexts.active) {
            if (item.subject.indexOf(contexts.active[c]) === -1) return false
        }
        return true
    }

    function numTasksHavingItem(item, visible) {
        var num = 0
        for (var i = 0; i < taskList.count; i++ ) {
            if (taskList.get(i).fullTxt.indexOf(item) > -1) {
                if (visible && visibility(taskList.get(i))) {
                    num++
                } else if (!visible) num++
            }
        }
        return num
    }
}

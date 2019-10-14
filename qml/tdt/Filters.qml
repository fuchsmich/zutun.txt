import QtQuick 2.0
import "../tdt/todotxt.js" as JS

QtObject {
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

    property FilterModel projects: FilterModel {
        name: "projects"
        list: taskListModel.projects
        //active: filterSettings.projects.value
        onActiveChanged: filtersChanged()
    }
    property FilterModel contexts: FilterModel {
        name: "contexts"
        list: taskListModel.contexts
        //active: filterSettings.contexts.value
        onActiveChanged: filtersChanged()
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

    function numTasksWithItem(item, visible) {
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

//    /* set filter; name... filterstring; onOff... turn it on (true) or off (false)*/
//    function setByName(name, onOff) {
//        var list = [];
//        switch (name.charAt(0)) {
//        case "+": list = projects.active; break;
//        case "@": list = contexts.active; break;
//        default: return;
//        }
//        if (onOff) list.push(name);
//        else list.splice(list.indexOf(name), 1);
//        list.sort();
//        switch (name.charAt(0)) {
//        case "+": filterSettings.projects.value = list; break;
//        case "@": filterSettings.contexts.value = list; break;
//        default: return;
//        }
//    }

//    function parseList() {
//        var taskList = tasksModel
//        var filterList = []
//        projects.clear()
//        contexts.clear()
//        for (var i = 0; i < taskList.count; i++) {
//            var item = taskList.get(i)
//            projects.addFilterItems(JS.projects.listLine(item.fullTxt), filters.visibility(item))
//            contexts.addFilterItems(JS.contexts.listLine(item.fullTxt), filters.visibility(item))
//        }
//    }

}

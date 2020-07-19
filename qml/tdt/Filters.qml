import QtQuick 2.0
import "../tdt/todotxt.js" as JS

QtObject {
    id: filters
    signal filtersChanged()


    property bool hideDone: true
    onHideDoneChanged: filtersChanged()

    property var text: {
        var a = []
        //: text about active filters
        if (hideDone) a.push(qsTr("Hide complete"))
        var ftext = a.concat(projects.concat(contexts)).join(", ")
        if (ftext) return ftext
        //: text about active filters
        else return qsTr("None")
    }

    property var projectList: []
    property var projects: []
    onProjectsChanged: filtersChanged()
    property var contextList: []
    property var contexts: []
    onContextsChanged: filtersChanged()

    property string searchString: ""
    onSearchStringChanged: filtersChanged()

    //return the visibility of a task (object)
    function visibility(task) {
        if (!task) return false
        if ((hideDone && task.done)) return false

        if (task.fullTxt.indexOf(searchString) === -1) return false

        for (var p in projects) {
            if (task.fullTxt.indexOf(projects[p]) === -1) return false
        }
        for (var c in contexts) {
            if (task.fullTxt.indexOf(contexts[c]) === -1) return false
        }
        return true
    }
}

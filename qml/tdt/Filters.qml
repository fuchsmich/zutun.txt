import QtQuick 2.0
import "../tdt/todotxt.js" as JS


QtObject {
    id: filters

    signal filtersChanged()

    property bool hideDone: true
    onHideDoneChanged: filtersChanged()

    property var and: []
    property var inAnd: function(filterItem){
        return and.indexOf(filterItem) !== -1
    }

    property var or: []
    property var inOr: function(filterItem){
        return or.indexOf(filterItem) !== -1
    }
    function toggleOr(filterItem) {
        if (inOr(filterItem)) {
            or.splice(or.indexOf(filterItem), 1)
        } else {
            or.push(filterItem)
            or.sort()
        }
        orChanged()
        filtersChanged()
    }

    property var not: []
    property var inNot: function(filterItem){
        return not.indexOf(filterItem) !== -1
    }
    function toggleNot(filterItem) {
        if (inNot(filterItem)) {
            not.splice(not.indexOf(filterItem), 1)
        } else {
            not.push(filterItem)
            not.sort()
        }
        notChanged()
        filtersChanged()
    }

    function toggleFilterItem(filterItem) {
        if (inAnd(filterItem)) {
            and.splice(and.indexOf(filterItem), 1)
            andChanged()
            if (inOr(filterItem)) {
                or.splice(or.indexOf(filterItem), 1)
                orChanged()
            }
        }
        else {
            and.push(filterItem)
            and.sort()
            andChanged()
        }
        filtersChanged()
    }

    property string searchString: ""
    onSearchStringChanged: filtersChanged()

    //return the visibility of a task (object)
    property var visibility: function(task) {
        if (!task) return false
        if ((hideDone && task.done)) return false

        if (task.fullTxt.search(new RegExp(searchString, "i")) === -1) return false

        if (and.length == 0) return true

        var andResult = (and.length > 0)
        and.forEach(function(i){
            /**  inTask inNot result
                 0      0     0
                 1      0     1
                 0      1     1
                 1      1     0 */
            //console.log (andResult)
            if (!inOr(i)) andResult &= ((task.fullTxt.indexOf(i) !== -1) ^ inNot(i))
        })
        andResult = (andResult === 1)

        var orResult = or.length === 0
        or.forEach(function(i){
            orResult |= (task.fullTxt.indexOf(i) !== -1) ^ inNot(i)
        })
        orResult = (orResult === 1)

        //console.log(task.fullTxt, and, andResult, or, orResult, andResult | orResult)
        return andResult | orResult
    }

    function clearFilters() {
        and = []
        or = []
        not = []
        searchString = ""
    }

    property string text: parseText()

    function parseText(){
        var a = []
        //: text about active filters
        if (hideDone) a.push(qsTr("Hide complete"))
        and.forEach(function(i){
            if (!inOr(i)) a.push("&%2%1".arg(i).arg((inNot(i)?"!":"")))
        })
        or.forEach(function(i){
            a.push("|%2%1".arg(i).arg((inNot(i)?"!":"")))
        })
        var ftext = a.join(", ")
        if (ftext) return ftext
        //: text about active filters
        else return qsTr("None")
    }
}

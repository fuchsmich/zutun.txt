import QtQuick 2.0

QtObject {
    property string name: ""
    property var list: []
    //onListChanged: console.log("list", list)
    property var active: []
    onActiveChanged:{
        //console.log("active", active)
        numTasksHavingItemChanged()
        itemActiveChanged()
    }
    property var numTasksHavingItem: function (item, visible) {
        return 0
    }
    property var itemActive: function (item) {
        //console.log("itemActive", active.indexOf(item) !== -1)
        return active.indexOf(item) !== -1
    }
    //onItemActiveChanged: console.log("itemActive", itemActive(modelData))

    function toggleFilter(item) {
        if (active.indexOf(item) === -1) active.push(item)
        else active.splice(active.indexOf(item))
        active.sort()
        activeChanged()
        //listChanged()
    }
}

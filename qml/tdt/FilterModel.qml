import QtQuick 2.0

ListModel {
    property var list: []
    onListChanged: parseLists()
    property var active: []
    onActiveChanged: parseLists()

    function parseLists() {
        clear()
        for (var i = 0; i < list.length; i++) {
            var json = {}
            json["name"] = list[i]
            json["active"] = (active.indexOf(list[i]) !== -1)
            json["visibleCount"] = visibleCount(list[i])
            json["totalCount"] = totalCount(list[i])
            //console.debug(JSON.stringify(json))
            append(json)
        }
    }

    function visibleCount(filterItem) {
        var num = 0
        visualModel.visibleTextList.forEach(function(item){
            if (item.indexOf(filterItem) !== -1) num++
        })
        return num
    }

    function totalCount(filterItem) {
        var num = 0
        visualModel.textList.forEach(function(item){
            if (item.indexOf(filterItem) !== -1) num++
        })
        return num
    }

    function toggleFilter(item) {
        //console.log(item, active.indexOf(item))
        if (active.indexOf(item) === -1) active.push(item)
        else active.splice(active.indexOf(item), 1)
        active.sort()
        activeChanged()
    }

    function clearFilter() {
        active = []
        activeChanged()
    }
}

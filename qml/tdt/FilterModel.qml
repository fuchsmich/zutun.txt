import QtQuick 2.0

ListModel {
    property var list: []
    onListChanged: parseLists()
    property var active: []
    onActiveChanged: parseLists()
    property var visualModel
    onVisualModelChanged: parseLists()

    function parseLists() {
        clear()
        for (var i = 0; i < list.length; i++) {
            var json = {}
            json["name"] = list[i]
            json["active"] = (active.indexOf(list[i]) !== -1)
            json["visibleCount"] = visibleCount(list[i])
            json["totalCount"] = totalCount(list[i])
            //console.log(JSON.stringify(json))
            append(json)
        }
    }

    function visibleCount(filterItem) {
        var num = 0
        for (var i = 0; i < visualModel.items.count; i++) {
            if (visualModel.items.get(i).model.fullTxt.indexOf(filterItem) !== -1) num++
        }
        return num
    }

    function totalCount(filterItem) {
        var num = 0
        for (var i = 0; i < visualModel.model.count; i++) {
            if (visualModel.model.get(i).fullTxt.indexOf(filterItem) !== -1) num++
        }
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

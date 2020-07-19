import QtQuick 2.0

ListModel {
    property var list: []
    onListChanged: parseList()
    property var active: []
    onActiveChanged: parseList()

    function parseList() {
        clear()
        list.forEach(function(item){
            var json = {}
            json["name"] = item
            json["active"] = (active.indexOf(item) !== -1)
            json["totalCount"] = visualModel.textList.join("\n").split(item).length - 1
            json["visibleCount"] = visualModel.visibleTextList.join("\n").split(item).length - 1
            append(json)
        })
    }

    function parseActive() {
        for (var i = 0; i < count; i++){
            setProperty(i, "active", (active.indexOf(get(i).name) !== -1))
        }
    }

    function toggleFilter(index) {
        var item = get(index)
        var a = active
        console.log(item.name, a.indexOf(item.name))
        if (a.indexOf(item.name) === -1){
            a.push(item.name)
        }
        else {
            a.splice(a.indexOf(item.name), 1)
        }
        a.sort()
        active = a
    }

    function clearFilter() {
        active = []
    }
}

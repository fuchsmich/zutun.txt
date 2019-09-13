import QtQuick 2.0

ListModel {
    property string name: ""
    property var list: []
    property var active: []

    function addFilterItems(items, visibility) {
        for (var i = 0; i < items.length; i++) {
            var found = false
            for (var j = 0; j < count; j++) {
                var item = get(j)
                if (item.name === items[i]) {
                    found = true
                    setProperty(j, "itemCount", item.itemCount + 1)
                    setProperty(j, "visibleItemCount", item.visibleItemCount + (visibility ? 1: 0))
                }
            }
            if (!found) {
                append({"name": items[i],
                           "active": (active.indexOf(items[i]) !== -1),
                           "itemCount": 1,
                           "visibleItemCount": (visibility ? 1: 0)});
            }
        }
    }
}

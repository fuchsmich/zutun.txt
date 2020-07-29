import QtQuick 2.0
import Sailfish.Silica 1.0


Repeater {
    id: repeater
    property var files: []
    property bool pinned: false
    signal setFiles(var files)
    signal togglePinned(int index)
    model: files

    function remove(index) {
        var rf = files
        var item = rf.splice(index, 1)
        setFiles(rf)
        return item[0]
    }

    function add(item) {
        if (files.indexOf(item) === -1) {
            var rf = files
            if (pinned) {
                rf.push(item)
                rf.sort()
            } else {
                var l = rf.unshift(item)
                if (l > 3) rf.splice(3)
            }
            setFiles(rf)
        }
    }

    ListItem {
        id: recentItem
        width: parent.width

        function remove() {
            remorseAction(qsTr("Deleting"), function() {
                repeater.remove(model.index)
            }, 3000)
        }

        Label {
            text: files[model.index]
            anchors.centerIn: parent
            highlighted: pinned
        }
        menu: ContextMenu {
            MenuItem {
                text: pinned ? qsTr("unpin") : qsTr("pin")
                onClicked: togglePinned(model.index)
            }
            MenuItem {
                text: qsTr("remove")
                onClicked: recentItem.remove()
            }
        }
    }
}

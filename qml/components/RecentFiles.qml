import QtQuick 2.0
import Sailfish.Silica 1.0


Repeater {
    id: repeater
    property var files: []
    property bool pinned: false
    signal togglePinned(int index)
    model: files
    ListItem {
        id: recentItem
        width: page.width

        function remove() {
            remorseAction(qsTr("Deleting"), function() {
                var rf = files
                rf.splice(model.index, 1)
                files = rf
            }, 3000)
        }

        Label {
            text: files[model.index]
            anchors.centerIn: parent
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
    Component.onCompleted: console.log(settings.recentFiles.value)
}

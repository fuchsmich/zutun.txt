import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: root

    SilicaListView {
        id: lv
        anchors.fill: parent
        VerticalScrollDecorator {}
        header: PageHeader {
            title: qsTr("Projects")
        }

        property var plist: tdt.getProjectList();
        model: plist
        delegate: ListItem {
            Label {
                text: lv.plist[model.index]
            }
            onClicked: {
                console.log(model.index);
                tdt.pfilter.push(lv.plist[model.index]);
                pageStack.pop(undefined);
            }
        }
    }
}

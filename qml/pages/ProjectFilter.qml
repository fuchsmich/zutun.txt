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
                id: lbl
                x: Theme.horizontalPageMargin
                text: lv.plist[index]
            }
            onClicked: {
                if (index === 0) tdt.pfilter = "";
                else tdt.pfilter = lbl.text;
                pageStack.navigateBack();
            }
        }
    }
}

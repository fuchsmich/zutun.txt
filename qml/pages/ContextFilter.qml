import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    id: dialog
    acceptDestinationAction: PageStackAction.Pop

    SilicaListView {
        DialogHeader{}
    }

//    SilicaListView {
//        id: lv
//        anchors.fill: parent

//        DialogHeader { title: "Contexts" }
//        VerticalScrollDecorator {}

////        property var plist: tdt.getContextList();
//        model: plist



//        delegate:
//            TextSwitch {
//            id: lbl
//            x: Theme.horizontalPageMargin
//            text: lv.plist[index]
//        }
//    }
}

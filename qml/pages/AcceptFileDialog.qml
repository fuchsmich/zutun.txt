import QtQuick 2.2
import Sailfish.Silica 1.0

Dialog {
    id: d
    property alias filePath: lbl.text
    property alias title: dh.title

    Column {
        width: parent.width

        DialogHeader {
            id: dh
        }

        Label {
            id: lbl
            x: Theme.horizontalPageMargin
            width: d.width
            wrapMode: Text.Wrap
        }

    }
}

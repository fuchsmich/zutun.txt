import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page
    SilicaFlickable {
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: col.height + Theme.paddingLarge

        VerticalScrollDecorator {}


        Column {
            id: col
            spacing: Theme.paddingLarge
            width: parent.width
            PageHeader {
                title: qsTr("About Zutun.txt")
            }
            Label {
                anchors.horizontalCenter: col.horizontalCenter
                text: "Michael Fuchs" }
            Label {
                anchors.horizontalCenter: col.horizontalCenter
                text: 'michfu@gmx.at'
//                text: '<a href="mailto:michfu@gmx.at>michfu@gmx.at</a>'
//                textFormat: Text.RichText
            }
            Label { text: "https://github.com/fuchsmich/zutun.txt/" }
            Label { text: "https://openrepos.net/content/fooxl/zutuntxt" }
        }
    }
}

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
            SectionHeader {
                text: "Author" }
            Label {
                x: Theme.horizontalPageMargin
                text: 'Michael Fuchs <a href=\'mailto:michfu@gmx.at\'>michfu@gmx.at</a>'
                textFormat: Text.RichText
            }
            SectionHeader {
                text: qsTr("Source")
            }
            Label {
                x: Theme.horizontalPageMargin
                text: "<a href=\'https://github.com/fuchsmich/zutun.txt/\'>github.com</a>"
            }
            SectionHeader {
                text: qsTr("Packages")
            }
            Label {
                x: Theme.horizontalPageMargin
                text: "<a href=\'https://openrepos.net/content/fooxl/zutuntxt\'>openrepos.net</a>"
            }
        }
    }
}

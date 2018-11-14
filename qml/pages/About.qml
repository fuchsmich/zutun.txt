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
                title: qsTr("About %1").arg("ZuTun.txt")
            }

            Image {
                id: name
                source: "../harbour-zutun.svg"
                sourceSize.width: parent.width*2
                smooth: true
                anchors.horizontalCenter: parent.horizontalCenter
                width: (orientation === Orientation.Portrait ?
                            page.width - Theme.paddingLarge * 5:
                            page.height - Theme.paddingLarge * 10)
                height: width
                cache: false
            }

//            DetailItem {
//                label: qsTr("Author")
//                value: 'Michael Fuchs <michfu@gmx.at>'
//            }
//            DetailItem {
//                label: qsTr("Source")
//                value: '<a href=\'https://github.com/fuchsmich/zutun.txt/\'>github.com</a>'
//            }
//            DetailItem {
//                label: qsTr("Repository")
//                value: "<a href=\'https://openrepos.net/content/fooxl/zutuntxt\'>openrepos.net</a>"
//            }

            SectionHeader {
                text: qsTr("Author")
            }
            Label {
                x: Theme.horizontalPageMargin
                text: "Michael Fuchs <michfu@gmx.at>"
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

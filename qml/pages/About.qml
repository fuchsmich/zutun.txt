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
                property string version: "0.0-0"
                //: About Zutun.txt
                title: qsTr("About %1").arg("ZuTun.txt")
                description: qsTr("Version %1").arg(version)
                Component.onCompleted: {
                    var versionFile = Qt.resolvedUrl("../../version");
                    var doc = new XMLHttpRequest();
                    doc.onreadystatechange = function() {
                        if (doc.readyState === XMLHttpRequest.DONE) {
                            console.log(versionFile, doc.responseText)
                            if (doc.status === 200) version = doc.responseText;
                            else version = "not found";
                        }
                    }
                    doc.open("GET", Qt.resolvedUrl("../../version"));
                    doc.send();
                }
            }

            Image {
                id: name
                source: "../harbour-zutun.svg"
                sourceSize.width: Math.max(page.width, page.height)
                smooth: true
                anchors.horizontalCenter: parent.horizontalCenter
                width: Math.min(page.width/3, page.height/3)
                height: width
                cache: false
            }

            SectionHeader {
                //: Author of the app
                text: qsTr("Author")
            }
            Label {
                x: Theme.horizontalPageMargin
                text: "Michael Fuchs <michfu@gmx.at>"
            }

            SectionHeader {
                //: Location of Sourcecode, followed by the button to GitHub
                text: qsTr("Source")
            }
            Button {
                //x: Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                width: Theme.buttonWidthLarge
                text: "github.com"
                onClicked: Qt.openUrlExternally('https://github.com/fuchsmich/zutun.txt/')
            }
            SectionHeader {
                //: SectionHeader for the names of the translators - you ;-)
                text: qsTr("Translation")
            }
            Label {
                x: Theme.horizontalPageMargin
                text:'es: Carmen Fernández B.
nl, nl_BE: Nathan Follens
fr: my brother
sv: Åke Engelbrektson
ru: Алексей Дедун'
            }

            SectionHeader {
                //: Where to get this app, followed by the button to OpenRepos
                text: qsTr("Packages")
            }
            Button {
                //x: Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                width: Theme.buttonWidthLarge
                text: "openrepos.net"
                onClicked: Qt.openUrlExternally('https://openrepos.net/content/fooxl/zutuntxt')
            }
        }
    }
}

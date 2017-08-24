import QtQuick 2.0
import Sailfish.Silica 1.0

//TODO Setting for automatically add creation date
//TODO Sailfish.Filebrowser??

Page {
    id: page
    SilicaFlickable {
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: col.height + Theme.paddingLarge

        VerticalScrollDecorator {}

        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("About.qml"))
            }
        }

        Column {
            id: col
            spacing: Theme.paddingLarge
            width: parent.width
            PageHeader {
                title: qsTr("Settings")
            }
            SectionHeader {
                text: "Files"
            }
            TextField {
                id: todoTxtPath
                //x: Theme.horizontalPageMargin
                label: qsTr("Path to todo.txt")
                text: settings.todoTxtLocation
                width: parent.width - 2*Theme.horizontalPageMargin
            }
            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Choose File")
                onClicked: pageStack.push(Qt.resolvedUrl("../external/FileBrowser.qml")); //, {state: "projects"});
                width: Theme.buttonWidthLarge
            }

            SectionHeader {
                text: "Task List"
            }
            Label {
                id: fslbl
                height: Theme.itemSizeMedium
                width: page.width
                text: qsTr("Fontsize in Tasklist")
                font.pixelSize: fontSizeSlider.value
                horizontalAlignment: Text.AlignHCenter
            }
            Row {
                width: parent.width
                Slider {
                    id: fontSizeSlider
                    //x: Theme.horizontalPageMargin
                    width: parent.width - x - resetBtn.width
                    minimumValue: Theme.fontSizeTiny
                    maximumValue: Theme.fontSizeHuge
                    value: settings.fontSizeTaskList
                    valueText: value
                    stepSize: 1
//                    label: qsTr("Fontsize in Tasklist")
                }
                IconButton {
                    anchors.verticalCenter: fontSizeSlider.verticalCenter
                    id: resetBtn
                    icon.source: "image://theme/icon-m-reset"
                    onClicked: fontSizeSlider.value = Theme.fontSizeMedium
                }
            }
            TextSwitch {
                text: "Attach project filter to the left of tasklist."
                //description: "Restart the app to take effect."
                checked: settings.projectFilterLeft
                onClicked: settings.projectFilterLeft = checked
            }
        }
        Component.onDestruction: {
            // write back settings and save
            settings.fontSizeTaskList = fontSizeSlider.sliderValue;
            settings.sync();
        }
    }
}



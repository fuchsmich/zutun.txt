import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Pickers 1.0
//TODO Setting for automatically add creation date

Page {
    id: page
    property string name: "settings"

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
            spacing: Theme.paddingMedium
            width: parent.width
            PageHeader {
                title: qsTr("Settings")
            }
            SectionHeader {
                text: qsTr("Files")
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
                onClicked: pageStack.push(filePickerPage)
                width: Theme.buttonWidthLarge
            }

            Component {
                id: filePickerPage
                FilePickerPage {
                    nameFilters: [ '*.txt']
                    onSelectedContentPropertiesChanged: {
                        settings.todoTxtLocation = selectedContentProperties.filePath
                    }
                }
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



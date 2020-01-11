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
                //: Information on the app: version, author, source code etc.
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("About.qml"))
            }
        }

        Column {
            id: col
            spacing: Theme.paddingMedium
            width: parent.width
            PageHeader {
                //: Page Header for the Settings page
                title: qsTr("Settings")
            }
            SectionHeader {
                //: Section Header for the Files section in Settings page
                text: qsTr("Files")
            }
            TextField {
                id: todoTxtPath
                //x: Theme.horizontalPageMargin
                //: Where - in which folder - is the todo.txt file located?
                label: qsTr("Path to todo.txt")
                text: settings.todoTxtLocation
                width: parent.width - 2*Theme.horizontalPageMargin
            }
            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                //: Button for picking the file
                text: qsTr("Choose file")
                onClicked: pageStack.push(filePickerPage)
                width: Theme.buttonWidthLarge
            }

            Component {
                id: filePickerPage
                //TODO how to create new file?
                FilePickerPage {
                    //: Page Header for the FilePickerPage (called from Button: Choose File)
                    title: "todo.txt Location"
                    nameFilters: [ '*.txt']
                    onSelectedContentPropertiesChanged: {
                        //settings.todoTxtLocation = selectedContentProperties.filePath
                        todoTxtPath.text = selectedContentProperties.filePath
                    }
                }
            }

            SectionHeader {
                //: Section Header for the Task List section in Settings page
                text: "Task List"
            }
            Label {
                id: fslbl
                height: Theme.itemSizeMedium
                width: page.width
                //: Slide control for font size
                text: qsTr("Font size in tasklist")
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
                //: TextSwitch for project filter
                text: qsTr("Attach project filter to the left of tasklist.")
                //description: "Restart the app to take effect."
                checked: settings.projectFilterLeft
                onClicked: settings.projectFilterLeft = checked
            }
        }
        Component.onDestruction: {
            // write back settings and save
            settings.todoTxtLocation = todoTxtPath.text
            settings.fontSizeTaskList = fontSizeSlider.sliderValue;
            settings.sync();
        }
    }
}



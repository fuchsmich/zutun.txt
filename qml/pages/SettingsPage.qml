import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Pickers 1.0

import "../components"

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
                //TODO start in current folder
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
                //: Section Header for the Files section in Settings page
                text: qsTr("Recent files")
                color: palette.secondaryColor
            }
            Column {
                width: page.width
                RecentFiles {
                    id: pinnedRF
                    files: settings.pinnedRecentFiles.value
                    pinned: true
                    onSetFiles: {
                        settings.pinnedRecentFiles.value = files
                    }
                    onTogglePinned:  {
                        var item = this.remove(index)
                        recentFiles.add(item)
                    }
                    onFileClicked: todoTxtPath.text = path
                }
                RecentFiles {
                    id: recentFiles
                    pinned: false
                    files: settings.recentFiles.value
                    onSetFiles:{
                        settings.recentFiles.value = files
                    }
                    onTogglePinned:  {
                        var item = this.remove(index)
                        pinnedRF.add(item)
                    }
                    onFileClicked: todoTxtPath.text = path
                }
            }

            SectionHeader {
                //: Section Header for the Tasklist section in Settings page
                text: "Tasklist"
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
                    //: Slide control for font size
                    label: qsTr("Fontsize in Tasklist")
                }
                IconButton {
                    anchors.verticalCenter: fontSizeSlider.verticalCenter
                    id: resetBtn
                    icon.source: "image://theme/icon-m-reset"
                    onClicked: fontSizeSlider.value = Theme.fontSizeMedium
                }
            }
//            SectionHeader {
//                //: Section Header for the Filter section in Settings page
//                text: "Filter"
//            }
//            TextSwitch {
//                //: TextSwitch for project filter
//                text: qsTr("Attach project filter to the left of tasklist.")
//                //description: "Restart the app to take effect."
//                checked: settings.projectFilterLeft
//                onClicked: settings.projectFilterLeft = checked
//            }
            SectionHeader {
                //: Section Header for the Edit section in Settings page
                text: "Edit Task"
            }
            TextSwitch {
                //: TextSwitch for adding creation date
                text: qsTr("Auto add creation date.")
                description: "Automatically add creation date to newly added tasks."
                checked: settings.creationDateOnAddTask
                onClicked: settings.creationDateOnAddTask = checked
            }
        }
        Component.onDestruction: {
            // write back settings and save
            settings.todoTxtLocation = todoTxtPath.text
            if (settings.pinnedRecentFiles.value.indexOf(todoTxtPath.text) === -1)
                recentFiles.add(todoTxtPath.text)
            settings.fontSizeTaskList = fontSizeSlider.sliderValue;
            settings.sync();
        }
    }
}



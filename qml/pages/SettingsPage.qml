import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Pickers 1.0

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
                Repeater {
                    model: settings.recentFiles.value
                    ListItem {
                        id: recentItem
                        width: page.width

                        function remove() {
                            remorseAction(qsTr("Deleting"), function() {
                                var rf = settings.recentFiles.value
                                rf.splice(model.index, 1)
                                settings.recentFiles.value = rf
                            }, 3000)
                        }

                        Label {
                            text: settings.recentFiles.value[model.index]
                            anchors.centerIn: parent
                        }
                        menu: ContextMenu {
                            MenuItem {
                                property var pinned: settings.pinnedRecentFiles.value
                                text: pinned.indexOf(model.index) !== -1 ?
                                          qsTr("unpin") : qsTr("pin")
                                onClicked: {
                                    var p = pinned
                                    if (p.indexOf(model.index) !== -1)
                                        p.splice(p.indexOf(model.index), 1)
                                    else p.push(model.index)
                                    settings.pinnedRecentFiles.value = p
                                }
                            }
                            MenuItem {
                                text: qsTr("remove")
                                onClicked: recentItem.remove()
                            }
                        }
                    }
                    Component.onCompleted: console.log(settings.recentFiles.value)
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
            var rf = settings.recentFiles.value
            if (rf.indexOf(todoTxtPath.text) === -1) {
                rf.push(todoTxtPath.text)
                settings.recentFiles.value = rf
            }
            console.log(settings.recentFiles.value)
            settings.fontSizeTaskList = fontSizeSlider.sliderValue;
            settings.sync();
        }
    }
}



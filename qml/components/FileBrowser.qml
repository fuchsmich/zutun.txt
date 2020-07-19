/** by coderus
  https://raw.githubusercontent.com/CODeRUS/systemd-journal-viewer/master/gui/qml/pages/FileBrowser.qml
  */

import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.FileManager 1.0
import Sailfish.FileManager 1.0

Dialog {
    id: dialog
    allowedOrientations: Orientation.Portrait

    property alias path: fileModel.path
    property alias nameFilters: fileModel.nameFilters
    property string homePath: StandardPaths.home
    property string title

    property var callback

    onAccepted: {
        if (typeof callback == "function") {
            callback(path)
        }
    }

    backNavigation: !FileEngine.busy

    FileModel {
        id: fileModel

        path: homePath
        active: dialog.status === DialogStatus.Opened
        directorySort: FileModel.SortDirectoriesBeforeFiles
        //nameFilters: ['###NO#FILES#PLEASE###']  // yes, it's a hack
        caseSensitivity: Qt.CaseInsensitive
        onError: {
            console.log("###", fileName, error)
        }
    }
    SilicaListView {
        id: fileList

        opacity: FileEngine.busy ? 0.6 : 1.0
        Behavior on opacity { FadeAnimator {} }

        anchors.fill: parent
        model: fileModel

        header: DialogHeader {
            title: dialog.path.split("/").pop()
            acceptText: qsTr("Save here")
        }

        delegate: ListItem {
            id: fileItem

            width: ListView.view.width
            contentHeight: Theme.itemSizeMedium
            Row {
                anchors.fill: parent
                spacing: Theme.paddingLarge
                Rectangle {
                    width: height
                    height: parent.height
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: Theme.rgba(Theme.primaryColor, 0.1) }
                        GradientStop { position: 1.0; color: "transparent" }
                    }

                    Image {
                        anchors.centerIn: parent
                        source: {
                            var iconSource = "image://theme/icon-m-file-folder"
                            return iconSource + (highlighted ? "?" + Theme.highlightColor : "")
                        }
                    }
                }
                Column {
                    width: parent.width - parent.height - parent.spacing - Theme.horizontalPageMargin
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: -Theme.paddingSmall
                    Label {
                        text: model.fileName
                        width: parent.width
                        font.pixelSize: Theme.fontSizeLarge
                        truncationMode: TruncationMode.Fade
                        color: highlighted ? Theme.highlightColor : Theme.primaryColor
                    }
                    Label {
                        property string dateString: Format.formatDate(model.modified, Formatter.DateLong)
                        text: dateString
                        width: parent.width
                        truncationMode: TruncationMode.Fade
                        font.pixelSize: Theme.fontSizeSmall
                        color: highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                    }
                }
            }

            onClicked: {
                if (model.isDir) {
                    pageStack.push(Qt.resolvedUrl("FileBrowser.qml"),
                                   {
                                       path: fileModel.appendPath(model.fileName),
                                       homePath: dialog.homePath,
                                       callback: dialog.callback,
                                       acceptDestination: dialog.acceptDestination,
                                       acceptDestinationAction: dialog.acceptDestinationAction
                                   })
                }
            }
        }
        ViewPlaceholder {
            enabled: fileModel.count === 0
            text: qsTr("No subdirectories")
        }
        VerticalScrollDecorator {}
    }
}

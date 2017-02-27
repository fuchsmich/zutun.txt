/*!
 *
 * Copyright (C) 2013 Mohammed Sameer <msameer@foolab.org>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this library; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 */

import QtQuick 2.1
import Sailfish.Silica 1.0
import Qt.labs.folderlistmodel 2.0

Page {
    id: page
    property alias rootFolder: fileModel.rootFolder

    FolderListModel {
        id: fileModel
//        folder: page.rootFolder
        showDotAndDotDot: false
        showDirsFirst: true
//        rootFolder: page.rootFolder
        sortField: FolderListModel.Name
        nameFilters: [ "*.txt" ]
    }

    SilicaListView {
        anchors.fill: parent
        id: mainView
        property Item contextMenu

        PullDownMenu {
/*
            MenuItem {
                text: qsTr("About")
            }

            MenuItem {
                text: qsTr("Settings")
            }
*/
            MenuItem {
                text: qsTr("Home")
                onClicked: fileModel.folder = rootFolder
            }
        }

        Component {
            id: contextMenuComponent

            ContextMenu {
                id: menu

                MenuItem {
                    text: qsTr("Remove")
                    onClicked: menu.parent.remove()
                }
            }
        }

        header: Column {
            width: mainView.width

            PageHeader {
                title: fileModel.folder.toString().substr(7)
                description: qsTr("Press and hold for choosing a folder.")
            }

            FolderDelegate {
                visible: fileModel.folder != "file:///"
                onClicked: fileModel.folder = fileModel.parentFolder
                text: qsTr("Parent directory");
                iconSource: "image://theme/icon-m-up"
            }
        }

        model: fileModel

        delegate: FolderDelegate {
            id: delegate
            iconSource: fileIsDir ? "image://theme/icon-m-folder" : "image://theme/icon-m-document"
            text: fileName
            height: menuOpen ? Theme.itemSizeSmall + mainView.contextMenu.height : Theme.itemSizeSmall
            property bool menuOpen: mainView.contextMenu != null && mainView.contextMenu.parent === delegate

            function remove() {
                remorse.execute(delegate, qsTr("Remove"), function() { helper.remove(filePath) } )
            }

            function openConfirmDialog(fp) {
                var dialog = pageStack.push(Qt.resolvedUrl("../pages/AcceptFileDialog.qml"),
                                            {filePath: fp, title: qsTr("File Location")})
                
                dialog.accepted.connect(function() {
                    settings.todoTxtLocation = fp
                })
            }
            
            onClicked: {
                if (fileIsDir) {
                    fileModel.folder = "file://" + filePath
                } else {
                    openConfirmDialog(filePath)
                    pageStack.navigateBack()
                }
            }

            onPressAndHold: {
                if (fileIsDir) {
                    openConfirmDialog(filePath + "/todo.txt")
                    pageStack.navigateBack()
                }

//                if (!mainView.contextMenu) {
//                    mainView.contextMenu = contextMenuComponent.createObject(mainView)
//                }

//                mainView.contextMenu.show(delegate)
            }

            RemorseItem { id: remorse }
        }
    }
}

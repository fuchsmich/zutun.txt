import QtQuick 2.0
import Sailfish.Silica 1.0

//TODO set/choose path, filebrowser??

Page {
    id: page
    Column {
        width: parent.width
        PageHeader {
            title: qsTr("Settings")
        }
        SectionHeader {
            text: "Files"
        }

        Label {
            x: Theme.horizontalPageMargin
            text: "Location todo.txt"
        }
        TextField {
            id: todoTxtPath
            x: Theme.horizontalPageMargin
            text: settings.todoTxtLocation
        }
        Label {
            x: Theme.horizontalPageMargin
            text: "Location done.txt"
        }
        TextField {
            id: doneTxtPath
            x: Theme.horizontalPageMargin
            text: settings.doneTxtLocation
        }
//        Button {
//            text: "Select File"
//        }


        TextSwitch {
            id: autoSaveSwitch
            x: Theme.horizontalPageMargin
            text: qsTr("Autosave")
            checked: settings.autoSave
        }
    }
    Component.onDestruction: {
        // write back settings and save
        settings.todoTxtLocation = todoTxtPath.text;
        settings.doneTxtLocation = doneTxtPath.text;
        settings.autoSave = autoSaveSwitch.checked;
        settings.sync();
    }
}






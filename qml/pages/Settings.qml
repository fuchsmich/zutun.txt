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

        TextField {
            x: Theme.paddingLarge
            text: settings.todoTxtLocation
        }

        TextSwitch {
            x: Theme.paddingLarge
            text: qsTr("Autosave")
        }
    }
}






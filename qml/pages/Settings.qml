
import QtQuick 2.0
import Sailfish.Silica 1.0


Page {
    id: page
    Column {
        width: parent.width
        PageHeader {
            title: qsTr("Settings")
        }

        TextSwitch {
            x: Theme.paddingLarge
            text: qsTr("Autosave")
        }
    }
}






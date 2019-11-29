import QtQuick 2.2
import Sailfish.Silica 1.0

EditItem {
    id: eip
    property alias model: horLV.model
    signal listItemSelected(string text)

    onClicked: openMenu()

    menu: EditContextMenu {
        SilicaListView {
            id: horLV
            width: parent.width
            height: Theme.itemSizeMedium
            orientation: ListView.Horizontal
            spacing: Theme.paddingMedium

            delegate: MouseArea {
                width: Math.max(Theme.itemSizeMedium, lbl.width)
                height: parent.height
                //anchors.fill: parent
                onClicked: {
                    //console.log(modelData)
                    eip.closeMenu()
                    //setText("projects", model.name)
                    listItemSelected(modelData)
                }
                Label {
                    id: lbl
                    anchors.centerIn: parent
                    text: modelData
                }
            }
            HorizontalScrollDecorator { }
        }
    }

}

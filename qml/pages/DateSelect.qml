import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    id: dialog
    property alias date: dp.date
    SilicaFlickable {
        anchors.fill: parent
        contentHeight: col.height
        VerticalScrollDecorator{}
        Column {
            id: col
            width: parent.width
            DialogHeader {
                //: Calendar is shown below text to pick a date
                title: qsTr("Select due date")
            }
            Label {
                text: dp.dateText
                anchors.horizontalCenter: dp.horizontalCenter
                color: Theme.highlightColor
            }
            DatePicker {
                id: dp
                onViewMovingChanged: {
                    if (viewMoving) {
                        dialog.forwardNavigation = false
                    } else dialog.forwardNavigation = true
                }
            }
        }
    }

}

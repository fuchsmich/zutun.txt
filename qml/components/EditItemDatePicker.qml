import QtQuick 2.2
import Sailfish.Silica 1.0

EditItem {
    id: editItem
    signal dateClicked(var date)
    signal datePressed(var date)
    property alias date: datePicker.date

    menu: EditContextMenu {
        Column {
            width: parent.width
            Label {
                height: Theme.itemSizeSmall
                anchors.horizontalCenter: parent.horizontalCenter
                text: datePicker.dateText
                color: Theme.primaryColor
            }
            DatePicker {
                id: datePicker
                daysVisible: true
                //onDateChanged: console.log(dateText)

                delegate: Component {
                    MouseArea {
                        width: datePicker.cellWidth
                        height: datePicker.cellHeight

                        Label {
                            anchors.centerIn: parent
                            text: model.day.toLocaleString()
                            font.bold: model.day === datePicker._today.getDate()
                                       && model.month === datePicker._today.getMonth()+1
                                       && model.year === datePicker._today.getFullYear()
                            color: {
                                if (pressed && containsMouse || model.day === datePicker.day
                                        && model.month === datePicker.month
                                        && model.year === datePicker.year) {
                                    return Theme.highlightColor
                                } else if (model.month === model.primaryMonth) {
                                    return Theme.primaryColor
                                }
                                return Theme.secondaryColor
                            }
                        }

                        function updateHighlight() {
                            datePicker._highlightedDate = pressed && containsMouse
                                    ? new Date(model.year, model.month-1, model.day,12,0,0)
                                    : undefined
                        }

                        onPressedChanged: {
                            updateHighlight()
                            editItem.datePressed(datePicker.date)
                        }
                        onContainsMouseChanged: updateHighlight()
                        onClicked: {
                            datePicker.date = new Date(model.year, model.month-1, model.day,12,0,0)
                            editItem.dateClicked(datePicker.date)
                        }
                    }
                }
            }
        }
    }
}

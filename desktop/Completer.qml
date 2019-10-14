//see also https://github.com/dant3/qmlcompletionbox/blob/master/SuggestionBox.qml

import QtQuick 2.5
import QtQuick.Controls 2.2
import Qt.labs.calendar 1.0
import QtQuick.Layouts 1.3

Rectangle {
    id: completer

    property TextInput textInput
    property var model: ["asddasd", "asdasd", "asdsadas", "adasd"]
    readonly property var completionModel: { model.filter(function(currentValue){
        //console.log(currentValue, completionPrefix)
        //if (completionPrefix.length >=  minCompletionPrefixLength)
        return currentValue.startsWith(completionPrefix)
        //else return false
    }) }
    readonly property int completionCount: completionModel.length
    property int minCompletionPrefixLength: 1
    readonly property var completionPrefix: {
        var match = textInput.text.substring(0, textInput.cursorPosition).match(/(^.*\s|^)(\S+)$/)
        if (match) {
            return  match[2]
        }
        else return ""
    }
    onCompletionPrefixChanged: console.debug(completionPrefix)
    onCompletionModelChanged: console.debug(completionModel)
    property var calendarKeywords: ["due:"]

    signal activated(int index, string text)
    onActivated: console.log("selected", index, text)

    z: 10 //parent.z + 100000
    visible: loader.status === Loader.Ready//(completionPrefix.length >= Math.max(1, minCompletionPrefixLength) && completionCount > 0)
    width: loader.width + 2*anchors.leftMargin
    height: loader.height //Math.min(200, lv.contentHeight)
    anchors.leftMargin: 5 //TODO what here?
    anchors.rightMargin: anchors.leftMargin
    border.color: "black"
    readonly property point positionInParent: textInput.mapToItem(parent, textInput.x + textInput.cursorRectangle.x - prefixItem.width - anchors.leftMargin,
                                                                  textInput.y + textInput.cursorRectangle.y + textInput.cursorRectangle.height)

    x: positionInParent.x
    y: positionInParent.y
    Text {
        //this is just for the calculation of position due to prefix length
        id: prefixItem
        text: completionPrefix
        visible: false
    }

    Component {
        id: calendarComponent
        GridLayout {
            width:200
            height: 150
            columns: 2

            DayOfWeekRow {
                locale: grid.locale

                Layout.column: 1
                Layout.fillWidth: true
            }

            WeekNumberColumn {
                month: grid.month
                year: grid.year
                locale: grid.locale

                Layout.fillHeight: true
            }

            MonthGrid {
                id: grid
                //month: Calendar.December
                //year: 2015
                locale: Qt.locale()

                Layout.fillWidth: true
                Layout.fillHeight: true
                onClicked: console.log(date)
            }
        }
    }

    Component {
        id: listComp
        ListView {
            width: contentItem.childrenRect.width
            height: Math.min(contentItem.childrenRect.height, 50)
            model: completionModel
            delegate: Text {
                text: modelData
                MouseArea {
                    anchors.fill: parent
                    onClicked: activated(model.index, modelData)
                }
            }
            ScrollIndicator.vertical: ScrollIndicator { }
            clip: true
        }
    }

    Loader {
        id: loader
        anchors.centerIn: parent
    }

    state: "initial"
    states: [
        State {
            name: "calendar"
            when: calendarKeywords.indexOf(completionPrefix) !== -1
            extend: "initial"
            PropertyChanges {
                target: loader
                sourceComponent: calendarComponent
            }
        },
        State {
            name: "list"
            when: (completionPrefix.length >= Math.max(1, minCompletionPrefixLength) && completionCount > 0)
            extend: "initial"
            PropertyChanges {
                target: loader
                sourceComponent: listComp
            }
        },
        State {
            name: "initial"
            when: textInput
            ParentChange {
                target: completer
                parent: completer.ApplicationWindow.overlay
            }
        }
    ]
    Component.onCompleted: textInput = parent
    onParentChanged: console.log(parent)
    onStateChanged: console.log(state)
}

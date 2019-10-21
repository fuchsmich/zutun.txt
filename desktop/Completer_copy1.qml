//see also https://github.com/dant3/qmlcompletionbox/blob/master/SuggestionBox.qml

import QtQuick 2.5
import QtQuick.Controls 2.2
import Qt.labs.calendar 1.0
import QtQuick.Layouts 1.3

Item {
    id: completer
    property var model: []
    property var calendarKeywords: []
    property int minCompletionPrefixLength: 1

    signal activated(int index, string text)
    onActivated: console.log("selected", index, text)

    property TextInput textInput: parent

    readonly property var _completionModel: { model.filter(function(currentValue){
        //console.log(currentValue, completionPrefix)
        //if (completionPrefix.length >=  minCompletionPrefixLength)
        return currentValue.startsWith(completionPrefix)
        //else return false
    }) }
    readonly property int _completionCount: _completionModel.length
    readonly property var _completionPrefix: {
        var match = textInput.text.substring(0, textInput.cursorPosition).match(/(^.*\s|^)(\S+)$/)
        if (match) {
            return  match[2]
        }
        else return ""
    }
    //onCompletionPrefixChanged: console.debug(completionPrefix)
    //onCompletionModelChanged: console.debug(completionModel)
    //    Component.onCompleted: {
    //        textInput = parent
    //        textInput.Keys.forwardTo = [completer]
    //    }

    Keys.onPressed: { console.log("key pressed", event.key) }

    states: [
        State {
            name: "showPopup"
            extend: "active"
            ParentChange {
                target: popupLoader
                parent: completer.ApplicationWindow.overlay
            }
            PropertyChanges {
                target: popupLoader
                sourceComponent: popupComp
            }
        },
        State {
            name: "active"
            when: textInput.activeFocus
            PropertyChanges {
                target: parent
                Keys.forwardTo: [completer]
            }
        }
    ]
    onStateChanged: console.log (state)

    Loader {
        id: popupLoader

    }

    Component {
        id: popupComp
        Rectangle {
            id: popup

            //visible: loader.status === Loader.Ready//(completionPrefix.length >= Math.max(1, minCompletionPrefixLength) && completionCount > 0)
            //width: loader.width + 2*anchors.leftMargin
            //height: loader.height //Math.min(200, lv.contentHeight)
            //anchors.leftMargin: 5 //TODO what here?
            //anchors.rightMargin: anchors.leftMargin
            //border.color: "black"
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
                id: keyHandlerComp
                Item {
                    Keys.onSpacePressed: {
                        if (event.modifiers === Qt.ControlModifier) {
                            console.log("Ctrl+space")
                            completionModel.triggered(true)
                            event.accepted = true
                        }
                        else event.accepted = false
                    }
                }
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
                    //Keys.onDownPressed: incrementCurrentIndex()
                    //Keys.onUpPressed: decrementCurrentIndex()
                    highlight: Rectangle {
                        color: "lightsteelblue"
                        opacity: 0.5
                    }
                    focus: true
                }
            }

            Loader {
                id: loader
                anchors.centerIn: parent
            }

            focus: true
            Keys.onSpacePressed: console.log("key", event.key)
            Connections {
                target: textInput
                //Keys.onPressed: console.log(event.key)
                onActiveFocusChanged: {
                    console.log(textInput.activeFocus)
                    textInput.Keys.forwardTo = [completer]
                }
            }

            //state: "initial"
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
                    PropertyChanges {
                        target: loader
                        sourceComponent: keyHandlerComp
                    }
                    //            PropertyChanges {
                    //                target: textInput
                    //                Keys.forwardTo: [completer]
                    //            }
                }
            ]
            onParentChanged: console.log("parent", parent, "state", state)
            onStateChanged: console.log("state", state, "parent", parent)
        }
    }
}

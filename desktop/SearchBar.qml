import QtQuick 2.0
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.1

ToolBar {
    width: page.width
    //height: (visible ? row.height : 0)
    //visible: showSearchBarAction.checked
    RowLayout {
        id: row
        width: parent.width
        TextField {
            id: searchField
            property bool keepFocus: false
            Layout.fillWidth: true
            placeholderText: qsTr("Search")
            focus: true
            onTextChanged: {
                keepFocus = true
                filters.searchString = text
            }
            onVisibleChanged: {
                if (!visible) text = ""
                else forceActiveFocus()
            }
            Keys.onEscapePressed: showSearchBarAction.checked = false
            Connections {
                target: filterActivateSearch
                function onTriggered() {
                    searchField.forceActiveFocus()
                    searchField.selectAll()
                }
            }
            onActiveFocusChanged: {
                //console.log("activefocus", activeFocus)
                if (keepFocus) forceActiveFocus()
                keepFocus = false
            }

            //Keys.onPressed: { console.log("key pressed", event.key) }

            Completer {
                model: app.completerKeywords
                calendarKeywords: app.completerCalendardKeywords
            }
            ToolButton {
                anchors {
                    top: parent.top;
                    right: parent.right
                }
                id: clearText
                //fillMode: Image.PreserveAspectFit
                background: Item {}
                smooth: true
                visible: searchField.text
                icon.name: "edit-clear"
                height: parent.height
                width: height
                onClicked: {
                    searchField.text = ""
                    searchField.forceActiveFocus()
                }
            }
        }
//        ToolButton {
//            icon.name: "edit-clear"
//            onClicked: searchField.clear()
//        }
    }
}

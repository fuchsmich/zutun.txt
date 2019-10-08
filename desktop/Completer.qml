//see also https://github.com/dant3/qmlcompletionbox/blob/master/SuggestionBox.qml

import QtQuick 2.5

Rectangle {
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
        var match = parent.text.substring(0, parent.cursorPosition).match(/(^.*\s|^)(\S+)$/)
        if (match) {
            return  match[2]
        }
        else return ""
    }
    onCompletionPrefixChanged: console.debug(completionPrefix)
    onCompletionModelChanged: console.debug(completionModel)

    signal activated(int index, string text)

    z: parent.z + 100000
    visible: (completionPrefix.length >= Math.max(1, minCompletionPrefixLength) && completionCount > 0)
    width: 200 //lv.implicitWidth
    height: 200 //Math.min(200, lv.contentHeight)
    border.color: "black"
    x: parent.x + parent.cursorRectangle.x - prefixItem.width
    y: parent.y + parent.cursorRectangle.y + parent.cursorRectangle.height

    Text {
        //this is just for the calculation of position due to prefix length
        id: prefixItem
        text: completionPrefix
        visible: false
    }

    ListView {
        id: lv
        anchors.fill: parent
        model: completionModel
        delegate: Text { text: modelData }
    }
}

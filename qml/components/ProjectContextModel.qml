import QtQuick 2.0

ListModel {

    property var lessThan: function (left, right) {

    }

    property var add: function (item) {
        var index = instertPosition(item)
        insert(index, item)
    }


}

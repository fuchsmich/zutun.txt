import QtQuick 2.2
import Sailfish.Silica 1.0

ListItem {
    width: parent.itemWidth
    height: width
    contentHeight: height
    Rectangle {
        width: parent.width
        height: width
        color: Theme.highlightBackgroundColor
        opacity: Theme.highlightBackgroundOpacity
    }
}

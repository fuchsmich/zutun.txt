import QtQuick 2.2
import Sailfish.Silica 1.0

ContextMenu {
    onHeightChanged: {
        parent.height = parent.width + height
    }
}

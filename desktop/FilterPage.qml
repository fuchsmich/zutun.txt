import QtQuick 2.0
import QtQuick.Controls 2.5

Page {
    Flickable {
        Column {
            Repeater {
                model: filters.projects
            }
        }
    }
}

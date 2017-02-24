import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.configuration 1.0
import "pages"
import "tdt"

//TODO nur verfügbare filter anziegen
//TODO archive to done.txt
//TODO fehler über notifiactions ausgeben


ApplicationWindow
{
    id: app
    initialPage: Component { TaskList{} }

    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: Orientation.All
    _defaultPageOrientations: Orientation.All


    ConfigurationGroup {
        id: settings
        path: "/apps/harbour-zutun/settings"
        property string todoTxtLocation: StandardPaths.documents + '/todo.txt'
        property string doneTxtLocation: StandardPaths.documents + '/done.txt'
        property bool autoSave: true
        property int fontSizeTaskList: Theme.fontSizeMedium
        ConfigurationGroup {
            id: filterSettings
            path: "filters"
            property bool hideDone: true
            property var projects: []
            property var contexts: []
        }
    }


    TodoTxt {
        id: ttm1
    }
}




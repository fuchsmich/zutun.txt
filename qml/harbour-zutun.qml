import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.configuration 1.0
import "pages"
import "tdt"

//TODO archive to done.txt
//TODO fehler über notifiactions ausgeben
//TODO Translation (Transifex??)
//TODO Search field??

ApplicationWindow
{
    id: app
    initialPage: //Component { FiltersPage { state: "projects"; skip: true} }
        Component { TaskList{} }

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
        property bool projectFilterLeft: false
        ConfigurationGroup {
            id: filterSettings
            path: "filters"
            property bool hideDone: true
            property var projects: []
            property var contexts: []
        }
        ConfigurationGroup {
            id: sortSettings
            path: "sorting"
            property bool asc: true
            property int order: 0
        }
    }


    TodoTxt {
        id: ttm1
    }
}




import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.configuration 1.0
import "pages"
//import "js"
import "tdt"

//TODO archive to done.txt
//TODO fehler über notifiactions ausgeben
//TODO reload file from time to time. when? app is activated, im cover mode auch sonst
//TODO parser in ei


ApplicationWindow
{
    id: app
    initialPage: Component { TaskList{} }

    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: Orientation.All
    _defaultPageOrientations: Orientation.All


    ConfigurationGroup {
        //TODO font size for tasklist
        id: settings
        path: "/apps/harbour-zutun/settings"
        property string todoTxtLocation: StandardPaths.documents + '/todo.txt'
        property string doneTxtLocation: StandardPaths.documents + '/done.txt'
        property bool autoSave: true
        //        Component.onCompleted: {
        //            console.log("settings", path, todoTxtLocation, doneTxtLocation, autoSave)
        //        }
        ConfigurationGroup {
            id: filterSettings
            path: "filters"
            property bool hideCompletedTasks: false
            property var projectFilter: []
            property var contextFilter: []
        }
    }


    TodoTxt {
        id: tdt
        todoTxtLocation: settings.todoTxtLocation
    }


    Component.onDestruction: {
        //save filters in settings
        filterSettings.hideCompletedTasks = tdt.filters.hideCompletedTasks
        filterSettings.projectFilter = tdt.filters.pfilter
        filterSettings.contextFilter = tdt.filters.cfilter
    }
}




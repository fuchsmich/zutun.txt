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


//    TodoTxt {
//        id: tdt
//        todoTxtLocation: settings.todoTxtLocation
//    }

//    TodoTxtModel {
//        id: ttm

//    }

    TodoTxtModel1 {
        id: ttm1

    }



    Component.onCompleted: {
//        console.log("filters: ", filterSettings.projectFilter, filterSettings.contextFilter );
//        tdt.contextModel.setFilterArray(filterSettings.contextFilter);
//        tdt.projectModel.setFilterArray(filterSettings.projectFilter);
    }


    Component.onDestruction: {
        //save filters in settings
//        filterSettings.hideCompletedTasks = tdt.filters.hideCompletedTasks
//        filterSettings.projectFilter = tdt.filters.projectModel.filter
//        filterSettings.contextFilter = tdt.filters.contextModel.filter
    }

}




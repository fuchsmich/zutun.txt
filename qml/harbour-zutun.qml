import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0
import Nemo.DBus 2.0

import "components"
import "pages"
import "tdt"

import "tdt/todotxt.js" as JS

//TODO archive to done.txt
//TODO fehler über notifiactions ausgeben
//TODO Search field??
//TODO more verbose placeholder in tasklist

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
        //property alias autoSave: file.autoSave
        property int fontSizeTaskList: Theme.fontSizeMedium
        property bool projectFilterLeft: false
        ConfigurationGroup {
            id: filterSettings
            path: "filters"
            property alias hideDone: filters.hideDone
            //TODO filters are not stored (anymore?)
            property ConfigurationValue projects: ConfigurationValue {
                key: "/apps/harbour-zutun/settings/filters/projects"
                defaultValue: []
            }
            property ConfigurationValue contexts: ConfigurationValue {
                key: "/apps/harbour-zutun/settings/filters/contexts"
                defaultValue: []
            }

            //            property var contexts: []
            //onProjectsChanged: console.log(projects.toString())
        }

        ConfigurationGroup {
            id: sortSettings
            path: "sorting"
            property bool asc: true
            property int order: 0
            property int grouping: 0
        }
    }

    DBusAdaptor {
        id: dbusAdaptor

        service: 'info.fuxl.zutuntxt'
        iface: 'info.fuxl.zutuntxt'
        path: '/info/fuxl/zutuntxt'

        function addTask() {
            app.addTask("")
        }

        function showApp() {
            app.activate()
            ttm1.readArray()
        }
    }

    DBusInterface {
        //just for testing DBusAdaptor
        id: dbi

        service: 'info.fuxl.zutuntxt'
        iface: 'info.fuxl.zutuntxt'
        path: '/info/fuxl/zutuntxt'

        function addTask() {
            call('addTask', undefined)
        }

    }

    function addTask(text) {
        //safety check text
        if (typeof text !== "String") text = "";
        pageStack.pop(pageStack.find(function(p){ return (p.name === "TaskList") }), PageStackAction.Immediate);
        pageStack.push(Qt.resolvedUrl("./pages/TaskEdit.qml"), {itemIndex: -1, text: text});
        app.activate();
    }

    FileIO {
        id: file
        property string hintText: ""
        path: settings.todoTxtLocation

        onReadSuccess:
            if (content) taskListModel.setTextList(content)

        onIoError: {
            //TODO needs some rework for translation
            hintText = msg;
        }
    }

//    Filters {
//        id: filters
//        onFiltersChanged: taskDelegateModel.resort()
//        tasksModel: taskListModel
//    }

//    Sorting {
//        id: sorting
//        onSortingChanged: taskDelegateModel.resort()
//    }

//    TaskListModel {
//        id: taskListModel
//        section: sorting.grouping
//        onListChanged: taskDelegateModel.resort()
//        projectColor: Theme.highlightColor
//        contextColor: Theme.secondaryHighlightColor
//    }

//    TaskDelegateModel {
//        id: taskDelegateModel
//        model: taskListModel
//    }

    TaskListModel {
        id: taskListModel
        //section: sorting.grouping
        projectColor: "red"
        contextColor: "blue"
        onListChanged: taskDelegateModel.resort()
        //onItemChanged: taskDelegateModel.resortItem(index)
    }

    Filters {
        id: filters
        taskList: taskListModel
        projects.active: filterSettings.projects.value
        contexts.active: filterSettings.contexts.value
        onFiltersChanged: taskDelegateModel.resort()
    }

    Sorting {
        id: sorting
        onSortingChanged: {
            taskDelegateModel.resort()
        }
    }

    TaskDelegateModel {
        id: taskDelegateModel
        model: taskListModel
        lessThanFunc: sorting.lessThanFunc //changed too late in sorting ??
        getSectionFunc: sorting.getGroup //changed too late in sorting ??
        visibility: filters.visibility
        delegate: TaskListItem {
            id: item
            width: app.width
//            onAddTask: taskListModel.addTask(text)
//            defaultPriority: taskDelegateModel.defaultPriority
        }
    }
}




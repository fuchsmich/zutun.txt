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

ApplicationWindow {
    id: app

    initialPage: Component { TaskListPage{} }

    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: Orientation.All
    _defaultPageOrientations: Orientation.All

    Component.onCompleted: {
        JS.tools.projectColor = Theme.highlightColor
        JS.tools.contextColor = Theme.secondaryHighlightColor
        JS.taskList.save = todoTxtFile.save
    }

    ConfigurationGroup {
        id: settings
        path: "/apps/harbour-zutun/settings"
        property string todoTxtLocation: StandardPaths.documents + '/todo.txt'
        property string doneTxtLocation: StandardPaths.documents + '/done.txt'
        //property alias autoSave: file.autoSave
        property int fontSizeTaskList: Theme.fontSizeMedium
        property bool projectFilterLeft: false
        property bool creationDateOnAddTask: false
        ConfigurationGroup {
            id: filterSettings
            path: "/filters"
            property bool hideDone: true
            //TODO filters are not stored (anymore?)
            property ConfigurationValue projects: ConfigurationValue {
                key: filterSettings.path + "/projects"
                defaultValue: []
            }
            property ConfigurationValue contexts: ConfigurationValue {
                key: filterSettings.path + "/contexts"
                defaultValue: []
            }

            //store as strings??
            property string projectsActive: ""
            property string contextsActive: ""
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
        }
    }

    function addTask(text) {
        //safety check text
        if (typeof text !== "String") text = ""
        pageStack.pop(pageStack.find(function(p){ return (p.name === "TaskList") }), PageStackAction.Immediate)
        pageStack.push(Qt.resolvedUrl("./pages/TaskEditPage.qml"), {itemIndex: -1, text: text})
        app.activate()
    }

    FileIO {
        id: todoTxtFile
        property string hintText: ""
        path: settings.todoTxtLocation

        onReadSuccess:
            if (content) {
                JS.taskList.setTextList(content)
                //taskListModel.clear()
                //JS.taskList.itemList.forEach(function(t){taskListModel.append(t)})
                visualModel.sourceModel = JS.taskList.itemList
                visualModel.filters.projectList = JS.projects.getList()
                visualModel.filters.contextList = JS.contexts.getList()
                visualModel.resort("read file")
                notificationList.publishNotifications()
                //console.log(JS.taskList.list[0].fullTxt)
            }

        onIoError: {
            //TODO needs some rework for translation
            hintText = msg
        }
    }

    NotificationList {
        id: notificationList
    }

//    ListModel {
//        id: taskListModel
//    }

    TaskListModel {
        id: visualModel

        filters {
            hideDone: filterSettings.hideDone
            projectList: JS.projects.getList()
            projects: filterSettings.projects.value
            contextList: JS.contexts.getList()
            contexts: filterSettings.contexts.value
        }

        sorting {
            asc: sortSettings.asc
            order: sortSettings.order
            groupBy: sortSettings.grouping
        }
    }
}




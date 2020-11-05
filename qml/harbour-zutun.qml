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

ApplicationWindow {
    id: app

    initialPage: Component { TaskListPage{} }

    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: Orientation.All
    _defaultPageOrientations: Orientation.All

    ConfigurationGroup {
        id: settings
        path: "/apps/harbour-zutun/settings"
        property string todoTxtLocation: StandardPaths.documents + '/todo.txt'
        property ConfigurationValue recentFiles: ConfigurationValue {
            key: settings.path + "/recentFiles"
            defaultValue: []
        }
        property ConfigurationValue pinnedRecentFiles: ConfigurationValue {
            key: settings.path + "/pinnedRecentFiles"
            defaultValue: []
        }
        property string doneTxtLocation: StandardPaths.documents + '/done.txt'
        property int fontSizeTaskList: Theme.fontSizeMedium
        property bool projectFilterLeft: false
        property bool creationDateOnAddTask: false
        property bool showSearch: false
        property ConfigurationValue notificationIDs: ConfigurationValue {
            key: settings.path + "/notificationIDs"
            defaultValue: []
        }
        ConfigurationGroup {
            id: filterSettings
            path: "/filters"
            property bool hideDone: true
            property ConfigurationValue and: ConfigurationValue {
                key: filterSettings.path + "/and"
                defaultValue: []
            }
            property ConfigurationValue or: ConfigurationValue {
                key: filterSettings.path + "/or"
                defaultValue: []
            }
            property ConfigurationValue not: ConfigurationValue {
                key: filterSettings.path + "/not"
                defaultValue: []
            }
        }

        ConfigurationGroup {
            id: sortSettings
            path: "sorting"
            property bool asc: false
            property int order: 0
            property int grouping: 0
        }

        ConfigurationGroup {
            id: notificationSettings
            path: "notifications"
            property bool showNotifications: true
            //maxCount... 0 unlimited
            property int maxCount: 0
            //dueLimit... 0 none, 1 one week, 2 one month
            property int dueLimit: 0
            property ConfigurationValue notificationIDs: ConfigurationValue {
                key: settings.path + "/notificationIDs"
                defaultValue: []
            }
            onValueChanged: notificationList.publishNotifications() //console.log("onValueChanged", showNotifications, notificationIDs.value, dueLimit, key)
        }
    }

    DBusAdaptor {
        id: dbusAdaptor

        service: 'info.fuxl.zutuntxt'
        iface: 'info.fuxl.zutuntxt'
        path: '/info/fuxl/zutuntxt'

        function addTask() {
            app.addTask()
        }

        function notificationClosed() {
            app.activate()
            notificationList.publishNotifications()
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

    property bool busy: todoTxtFile.busy //|| taskListModel.busy
    property string placeholderText: {
        if (todoTxtFile.error !== "") return qsTr("File reading error")
        if (todoTxtFile.pathExists && !todoTxtFile.exists) return qsTr("File doesn't exist.\n Pull down to create it.")
        if (todoTxtFile.content === "") return qsTr("File seems to be empty.\n Pull down to create one.")
        if (taskListModel.textList.length === 0) return qsTr("No tasks found in file.\n Pull down to create one.")
        if (taskListModel.visibleTextList.length === 0) return qsTr("All tasks are hidden by filters.\n Pull down to clear filters.")
        return ""
    }

    FileIO {
        id: todoTxtFile
        path: settings.todoTxtLocation
        onPathChanged: {
            taskListModel.setFileContent("")
            read("path changed")
        }

        onReadSuccess:{
            //console.debug(content)
            taskListModel.setFileContent(content)
        }

        onPythonReadyChanged: if (pythonReady) read("python ready")
    }

    NotificationList {
        id: notificationList
        taskList: taskListModel
    }

    SortFilterModel {
        id: visualModel
        model: taskListModel
        visibilityFunc: taskListModel.filters.visibility
        lessThanFunc: taskListModel.sorting.lessThanFunc
        delegate: Delegate {}
    }

    TaskListModel {
        id: taskListModel

        onSaveTodoTxtFile: todoTxtFile.save(content)
        onTaskListDataChanged: notificationList.publishNotifications()

        Component.onCompleted: {
            JS.tools.projectColor = Theme.highlightColor
            JS.tools.contextColor = Theme.secondaryHighlightColor
        }

        filters {
            hideDone: filterSettings.hideDone
            and: filterSettings.and.value
            or: filterSettings.or.value
            not: filterSettings.not.value
            onFiltersChanged: {
                filterSettings.and.value = taskListModel.filters.and
                filterSettings.or.value = taskListModel.filters.or
                filterSettings.not.value = taskListModel.filters.not
                visualModel.update()
            }
        }

        sorting {
            asc: sortSettings.asc
            order: sortSettings.order
            groupBy: sortSettings.grouping
            onSortingChanged: visualModel.update()
        }
    }

    Connections {
        target: Qt.application
        onStateChanged: {
            //console.log("app state", Qt.application.state)
            if (Qt.application.state === Qt.ApplicationActive) {
                todoTxtFile.read("app active")
            }
        }
    }
}




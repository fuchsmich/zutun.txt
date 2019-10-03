import QtQuick 2.12
import QtQuick.Controls 2.5

Page {
    id: page
    anchors.fill: parent
    title: "Tasklist"

    ListView {
        id: taskListView
        anchors.fill: parent
        model: taskDelegateModel
        //model: taskListModel
        //        model: app.taskListJSObjects //app.taskListArray //taskListModel
        //        delegate: TaskListItem {
        //            width: taskListView.width
        //            done: model.done
        //            priority: model.priority
        //            creationDate: model.creationDate
        //            subject: model.formattedSubject
        //            due: model.due


        //            onToggleDone: model.done = !model.done
        //            onPrioUp: setTaskProperty(model.index, "priority", "up")
        //            onPrioDown: setTaskProperty(model.index, "priority", "down")
        //            onEditItem: visualModel.editItem(model.index)
        //            onRemoveItem: removeItem(model.intex)
        //        }

    }

    Column {
        id: column
        anchors.centerIn: parent
        //        visible: !(todoTxtFile.pathExists
        //                   && todoTxtFile.exists
        //                   && todoTxtFile.readable
        //                   && todoTxtFile.writeable)
        visible: taskListView.count == 0
        Button {
            text: "Load File"
            onClicked: todoTxtFile.read()
        }

        Label {
            text: "Path: %1".arg(todoTxtFile.path)
        }
        Label {
            text: "Path exists: %1".arg(todoTxtFile.pathExists ? "Yes" : "No")
        }
        Label {
            text: "File exists: %1".arg(todoTxtFile.exists ? "Yes" : "No")
        }
        Label {
            text: "File readable: %1".arg(todoTxtFile.readable ? "Yes" : "No")
        }
        Label {
            text: "File writeable: %1".arg(todoTxtFile.writeable ? "Yes" : "No")
        }
    }
}

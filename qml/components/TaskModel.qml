import QtQuick 2.0
import QtQml.Models 2.1

DelegateModel {

    model: ttm1.tasks
    delegate: TaskListItem {
        subject: model.formattedSubject
        done: model.done
        creationDate: model.creationDate
        due: model.due

        onToggleDone: ttm1.tasks.setProperty(model.index, "done", !model.done)
        onEditItem: pageStack.push(Qt.resolvedUrl("TaskEdit.qml"), {itemIndex: model.index, text: model.fullTxt})
        onRemoveItem: ttm1.tasks.removeItem(model.index)
        onPrioUp: ttm1.tasks.alterPriority(model.index, true)
        onPrioDown: ttm1.tasks.alterPriority(model.index, false)
    }
}

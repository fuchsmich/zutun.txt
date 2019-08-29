import QtQuick 2.0
import QtQml.Models 2.1

DelegateModel {
    id: visualModel
    //https://doc.qt.io/qt-5/qtquick-tutorials-dynamicview-dynamicview4-example.html
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
    items.includeByDefault: false

    function insertPosition(lessThanFunc, item) {
        var lower = 0;
        var upper = items.count;
        while (lower < upper) {
            var middle = Math.floor(lower + (upper - lower) / 2);
            var result =
                    lessThanFunc(item, items.get(middle)); //JS.baseFeatures.parseLine(tasksArray[get(middle).lineNum]));
            if (result) {
                upper = middle;
            } else {
                lower = middle + 1;
            }
        }
        return lower;
    }

    function sort(lessThan) {
        while (invisibleItems.count > 0) {
            var item = invisibleItems.get(0)
            var index = insertPosition(lessThan, item)

            item.groups = "items"
            items.move(item.itemsIndex, index)
        }
    }

    groups: [
        DelegateModelGroup {
            id: invisibleItems
            name: "invisible"
            includeByDefault: true
            onChanged: {
                visualModel.sort(ttm1.sorting.lessThanFunc())
            }
        }
    ]
}

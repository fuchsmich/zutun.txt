import QtQuick 2.0
import Sailfish.Silica 1.0

Label {
    //width: ListView.view.width - Theme.paddingMedium
    text: model.formattedSubject
    truncationMode: TruncationMode.Elide
    font.strikeout: model.done
    visible: taskListModel.filters.visibility(model)
}

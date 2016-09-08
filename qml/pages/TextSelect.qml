import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page

    SilicaListView {
        id: lv
        anchors.fill: parent

        VerticalScrollDecorator {}
        header: PageHeader {
            title: "Priorities"
        }

        property var arrayModel: prioritiesModel()
        model: arrayModel

        delegate: ListItem {
            Label { id: lbl; text: prioritiesModel()[index] }
            onClicked: setString(page.state)
        }
    }

    function prioritiesModel() {
        var l = [];
        for (var a = "A"; a <= "Z";
             a = String.fromCharCode(a.charCodeAt(0) + 1)) {
            l.push("("+a+") ");
        }
        return l;
    }

    function setString(state) {
        pageStack.previousPage().selectedPriority = lbl.text;
        pageStack.pop();
    }

    states: [
        State {
            name: "priorities"
            PropertyChanges {
                target: lv;
                arrayModel: prioritiesModel();
            }
        }
    ]
}


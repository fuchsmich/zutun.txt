import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page
    state: "priorities"

    SilicaListView {
        id: lv
        anchors.fill: parent

        VerticalScrollDecorator {}
        header: PageHeader {
            title: "State: " + state
        }

        property var arrayModel: prioritiesModel()
        model: arrayModel

        delegate: ListItem {
            Label {
                id: lbl;
                x: Theme.horizontalPageMargin
                text: lv.arrayModel[index]
            }
            onClicked: setString(lv.arrayModel[index])
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

    function setString(txt) {
        if (state === "priorities") pageStack.previousPage().selectedPriority = txt;
        if (state === "projects") pageStack.previousPage().appendText = txt;
        if (state === "contexts") pageStack.previousPage().appendText = txt;
        pageStack.pop();
    }

    states: [
        State {
            name: "priorities"
            PropertyChanges {
                target: lv;
                arrayModel: prioritiesModel();
            }
        },
        State {
            name: "projects"
            PropertyChanges {
                target: lv;
                arrayModel: tdt.getProjectList();
            }
        },
        State {
            name: "contexts"
            PropertyChanges {
                target: lv;
                arrayModel: tdt.getContextList();
            }
        }
    ]
}


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

//        property var arrayModel: prioritiesModel()
        model: prioritiesModel

        delegate: ListItem {
            Label {
                id: lbl;
                x: Theme.horizontalPageMargin
                text: model.item
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

    ListModel {
        id: prioritiesModel
        Component.onCompleted: {
            for (var a in tdt.alphabet) {
                append({"item": "("+tdt.alphabet[a]+") "});
            }
        }
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
                model: prioritiesModel;
            }
        },
        State {
            name: "projects"
            PropertyChanges {
                target: lv;
                model: projectModel;
            }
        },
        State {
            name: "contexts"
            PropertyChanges {
                target: lv;
                model: contextModel;
            }
        }
    ]
}


import QtQuick 2.0
import Sailfish.Silica 1.0

import "../tdt/todotxt.js" as JS


Page {
    id: page
    state: "priorities"

    SilicaListView {
        id: lv
        anchors.fill: parent

        VerticalScrollDecorator {}
        header: PageHeader {
            title: state
        }

        //        property var arrayModel: prioritiesModel()
//        model: prioritiesModel

        delegate: ListItem {
            Label {
                id: lbl;
                x: Theme.horizontalPageMargin
                text: model.name
            }
            onClicked: setString(lbl.text)
        }
    }

//    function prioritiesModel() {
//        var l = [];
//        for (var a = "A"; a <= "Z";
//             a = String.fromCharCode(a.charCodeAt(0) + 1)) {
//            l.push("(" + a + ") ");
//        }
//        return l;
//    }

    ListModel {
        id: prioritiesModel
        Component.onCompleted: {
            for (var a in JS.alphabet) {
                append({"name": "(" + JS.alphabet[a] + ") "});
            }
        }
    }

    function setString(txt) {
        switch (state) {
        case "priorities": pageStack.previousPage().selectedPriority = txt.charAt(1); break
        case "projects": pageStack.previousPage().appendText = txt; break
        case "contexts": pageStack.previousPage().appendText = txt; break
        }
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
                model: ttm1.filters.projectsModel
            }
        },
        State {
            name: "contexts"
            PropertyChanges {
                target: lv;
                model: ttm1.filters.contextsModel
            }
        }
    ]
}


import QtQuick 2.0
import Sailfish.Silica 1.0

//TODO Spacing überprüfen

Page {
    id: page
    state: "projects"

    SilicaListView {
        id: lv
        property string btnTxt: "Clear Project Filter"
//        spacing: Theme.paddingLarge

        anchors.fill: parent
        VerticalScrollDecorator {}
        PullDownMenu {
//            MenuItem {
//                text: qsTr("Other Filters")
//                onClicked: //pageStack.push(Qt.resolvedUrl("ProjectFilter.qml"));
//                           page.state = "others"
//            }
            MenuItem {
                visible: (page.state !== "contexts")
                text: qsTr("Context Filters")
                onClicked: pageStack.push(Qt.resolvedUrl("FiltersPage.qml"), {state: "contexts"});
            }
            MenuItem {
                visible: (page.state !== "projects")
                text: qsTr("Project Filters")
                onClicked: pageStack.push(Qt.resolvedUrl("FiltersPage.qml"), {state: "projects"});
            }
            MenuItem {
                text: qsTr("Back To Tasklist")
                onClicked: pageStack.pop(pageStack.find(function(p){ return (p._depth === 0)}));
            }
        }

        property string title: ""
        header: Item {
            width: page.width
            height: pgh.height + cbtn.height

            PageHeader {
                id: pgh
                title: lv.title
                //            description: ttm1.filters.string()
            }
            Button {
                id: cbtn
                width: Theme.buttonWidthLarge
                anchors {
                    top: pgh.bottom
                    topMargin: -Theme.paddingMedium
                    horizontalCenter: parent.horizontalCenter
                }
                text: lv.btnTxt
                onClicked: {
                    ttm1.filters.clearFilter(page.state);
                    //                        pageStack.navigateBack();
                }
            }
        }

        delegate: ListItem {
            enabled: model.visibleItemCount > 0
            highlighted: model.active
            onClicked: ttm1.filters.setByName(model.name, !model.active);
            Label {
                //                        id: lbl
                color: (model.visibleItemCount > 0? Theme.primaryColor : Theme.secondaryColor)
                anchors.verticalCenter: parent.verticalCenter
                x: Theme.horizontalPageMargin
                text: model.name + " (" + model.visibleItemCount + "/" + model.itemCount + ")"
            }
        }
    }
    onStatusChanged: {
        if (state == "projects" && status === PageStatus.Active) {
            pageStack.pushAttached("FiltersPage.qml", {state: "contexts"});
        }
        if (state == "contexts" && status === PageStatus.Active) {
            pageStack.pushAttached("OtherFilters.qml");
        }
    }

    states: [
        State {
            name: "projects"
            PropertyChanges {
                target: lv;
                //                delegate: projectDelegate
                title: qsTr("Filter Projects")
                model: ttm1.filters.projectsModel
                btnTxt: qsTr("Clear Project Filters")
            }
        }
        , State {
            name: "contexts"
            PropertyChanges {
                target: lv;
                //                delegate: contextDelegate
                //                list: ["All"].concat(tdt.getContextList());
                title: qsTr("Filter Contexts")
                model: ttm1.filters.contextsModel
                btnTxt: qsTr("Clear Context Filters")
            }
        }

    ]
}

import QtQuick 2.0
import Sailfish.Silica 1.0


Page {
    id: page
    state: "projects"

    SilicaListView {
        id: lv
        property string btnTxt: "Clear Project Filter"

        anchors.fill: parent
        VerticalScrollDecorator {}
        PullDownMenu {
            MenuItem {
                text: qsTr("Other Filters")
                onClicked: //pageStack.push(Qt.resolvedUrl("ProjectFilter.qml"));
                           page.state = "others"
            }
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
        header: PageHeader {
            id: ph
            title: lv.title
            //            description: ttm1.filters.string()
        }

        //        property var list: tdt.projects
        //        model: ttm1.projectModel

        delegate: projectDelegate

        Component {
            id: projectDelegate
            Column {
                width: page.width
                Button {
                    id: btn
                    visible: model.index === 0
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: lv.btnTxt
                    onClicked: {
                        ttm1.filters.clearFilter(page.state);
//                        pageStack.navigateBack();
                    }
                }
                ListItem {
                    enabled: model.visibleItemCount > 0
                    highlighted: model.active
                    onClicked: ttm1.filters.setByName(model.name, !model.active);
                    Label {
                        id: lbl
                        anchors.verticalCenter: parent.verticalCenter
                        x: Theme.horizontalPageMargin
                        text: model.name + " (" + model.visibleItemCount + "/" + model.itemCount + ")"
                    }
                }
            }
        }

        Component {
            id: contextDelegate
            Column {
                width: page.width
                //                height: Math.max(cbtn.height, sw.height) + Theme.paddingLarge
                Button {
                    id: cbtn
                    visible: index === 0
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Clear Context Filter"
                    onClicked: if (index === 0) tdt.contextModel.resetFilter();
                }
                TextSwitch {
                    id: sw
                    x: Theme.horizontalPageMargin
                    text: model.name + " (" + model.noOfVisibleTasks + "/" + model.noOfTasks + ")"
                    checked: model.filterActive
                    //                    visible: model.filterAvailable
                    onClicked: {
                        if (checked) tdt.contextModel.setFilter(index, true);
                        else tdt.contextModel.setFilter(index, false);

                    }
                    //                    Component.onCompleted: checked  = (tdt.cfilter.indexOf(text) !== -1)
                }
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
                title: "Filter Projects"
                model: ttm1.filters.projectsModel
                btnTxt: "Clear Project Filters"
            }
        }
        , State {
            name: "contexts"
            PropertyChanges {
                target: lv;
//                delegate: contextDelegate
                //                list: ["All"].concat(tdt.getContextList());
                title: "Filter Contexts"
                model: ttm1.filters.contextsModel
                btnTxt: "Clear Context Filters"
            }
        }

    ]
}

import QtQuick 2.0
import Sailfish.Silica 1.0


Page {
    id: page
    state: "projects"

    SilicaListView {
        id: lv
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
//            description: pageStack.depth
        }

//        property var list: tdt.projects
        model: projectModel

        delegate: projectDelegate

        Component {
            id: projectDelegate
            Item {
                width: page.width
                height: Math.max(btn.height, lbl.height) + Theme.paddingLarge
                Button {
                    id: btn
                    visible: index === 0
                    anchors.centerIn: parent
                    text: "Clear Project Filter"
                    onClicked: {
                        if (index === 0) projectModel.resetFilter();
                        pageStack.navigateBack();
                    }
                }
                ListItem {
                    visible: index !== 0
                    Label {
                        id: lbl
                        x: Theme.horizontalPageMargin
                        text: model.item + " (" + model.noOfTasks + ")"  //lv.list[index]
                    }
                    onClicked: {
//                        tdt.pfilter = [model.item];
                        projectModel.setProperty(index, "filter", true);
                        pageStack.navigateBack();
                    }
                }
            }
        }

        Component {
            id: contextDelegate
            Item {
                width: page.width
                height: Math.max(cbtn.height, sw.height) + Theme.paddingLarge
                Button {
                    id: cbtn
                    visible: index === 0
                    anchors.centerIn: parent
                    text: "Clear Context Filter"
                    onClicked: if (index === 0) contextModel.resetFilter();
                }
                TextSwitch {
                id: sw
                    visible: index !== 0
                    x: Theme.horizontalPageMargin
                    text: model.item + " (" + model.noOfTasks + ")"
                    checked: model.filter
                    onClicked: {
                        if (checked) contextModel.setProperty(index, "filter", true);
                        else contextModel.setProperty(index, "filter", false);

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
                delegate: projectDelegate
                title: "Projects"
                model: projectModel
            }
        }
        , State {
            name: "contexts"
            PropertyChanges {
                target: lv;
                delegate: contextDelegate
//                list: ["All"].concat(tdt.getContextList());
                title: "Contexts"
                model: contextModel
            }
        }

    ]
}

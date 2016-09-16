import QtQuick 2.0
import Sailfish.Silica 1.0


//TODO Anzahl der Items
Page {
    id: page
    state: "projects"

    SilicaListView {
        id: lv
        anchors.fill: parent
        VerticalScrollDecorator {}
        PullDownMenu {
            MenuItem {
                visible: (page.state !== "others")
                text: qsTr("Other Filters")
                onClicked: //pageStack.push(Qt.resolvedUrl("ProjectFilter.qml"));
                           page.state = "others"
            }
            MenuItem {
                visible: (page.state !== "contexts")
                text: qsTr("Context Filters")
                onClicked: //pageStack.push(Qt.resolvedUrl("ContextFilter.qml"));
                           page.state = "contexts"
            }
            MenuItem {
                visible: (page.state !== "projects")
                text: qsTr("Project Filters")
                onClicked: // pageStack.push(Qt.resolvedUrl("ProjectFilter.qml"));
                           page.state = "projects"
            }
            MenuItem {
                text: qsTr("Back To Tasklist")
                onClicked:{
                    //pageStack.replaceAbove(null, app.initialPage);
                    pageStack.pop(taskListPage);
                }
            }
        }

        property string title: ""
        header: PageHeader {
            id: ph
            title: lv.title
//            description: pageStack.depth
        }

//        property var list: tdt.projects
        model: projectList

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
                    onClicked: if (index === 0) projectList.resetFilter();//tdt.pfilter = "";
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
                        projectList.setProperty(index, "filter", true);
                        pageStack.navigateBack();
                    }
                }
            }
        }

        Component {
            id: contextDelegate
            Item {
                width: page.width
                height: Math.max(btn.height, sw.height) + Theme.paddingLarge
                Button {
                    id: btn
                    visible: index === 0
                    anchors.centerIn: parent
                    text: "Clear Context Filter"
                    onClicked: if (index === 0) contextList.resetFilter();
                }
                TextSwitch {
                id: sw
                    visible: index !== 0
                    x: Theme.horizontalPageMargin
                    text: model.item + " (" + model.noOfTasks + ")"
                    checked: model.filter
                    onClicked: {
                        if (checked) contextList.setProperty(index, "filter", true);
                        else contextList.setProperty(index, "filter", false);

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
                //list: tdt.projects //["All"].concat(tdt.getProjectList());
                title: "Projects"
                model: projectList
            }
        }
        , State {
            name: "contexts"
            PropertyChanges {
                target: lv;
                delegate: contextDelegate
//                list: ["All"].concat(tdt.getContextList());
                title: "Contexts"
                model: contextList
            }
        }

    ]
}

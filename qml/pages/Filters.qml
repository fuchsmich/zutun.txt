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

        property string title: "Projects"
        header: PageHeader {
            id: ph
            title: lv.title
//            description: pageStack.depth
        }

        property var list: ["All"].concat(tdt.getProjectList());
        model: list

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
                    text: "clear filter"
                    onClicked: if (index === 0) tdt.pfilter = "";
                }
                ListItem {
                    visible: index !== 0
                    Label {
                        id: lbl
                        x: Theme.horizontalPageMargin
                        text: txt + " (" + tasksCount + ")"
                    }
                    onClicked: {
                        filterActive = true;
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
                    text: "clear filter"
                    onClicked: {
                        if (index === 0) tdt.cfilter = [];
                        tdt.cfilterChanged();
                    }
                }
                TextSwitch {
                id: sw
                    visible: index !== 0
                    x: Theme.horizontalPageMargin
                    text: lv.list[index]
//                    function getChecked() { return tdt.cfilter.indexOf(text) !== -1 }
                    checked: tdt.cfilter.indexOf(text) !== -1
                    onClicked: {
                        if (checked) {
                            tdt.cfilter.push(text);
                            tdt.cfilter.sort();
//                            tdt.cfilterChanged();
                        }
                        else  {
                            var cf = [];
                            for (var c in tdt.cfilter) {
                                if (tdt.cfilter[c] !== text) cf.push(tdt.cfilter[c]);
                            }
                            tdt.cfilter = cf;
                        }
                    }
                    Connections {
                        target: cbtn
                        onClicked: parent.checked = false;
                    }
//                    Component.onCompleted: checked  = (tdt.cfilter.indexOf(text) !== -1)
                }
            }
        }
    }
    onStatusChanged: {
        if (state == "projects" && status === PageStatus.Active) {
            pageStack.pushAttached("Filters.qml", {state: "contexts"});
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
                model: tdt.projectModel
                title: "Projects"
            }
        }
        , State {
            name: "contexts"
            PropertyChanges {
                target: lv;
                delegate: contextDelegate
                list: ["All"].concat(tdt.getContextList());
                title: "Contexts"
            }
        }

    ]
}

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

        header: PageHeader {
            id: ph
            title: qsTr("Projects")
            description: pageStack.depth
        }

        property var list: tdt.getProjectList();
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
                        text: lv.list[index]
                    }
                    onClicked: {
                        if (index === 0) tdt.pfilter = "";
                        else tdt.pfilter = lbl.text;
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
                    text: "clear filter"
                    onClicked: if (index === 0) tdt.pfilter = "";
                }
                TextSwitch {
                    id: sw
                    visible: index !== 0
                    x: Theme.horizontalPageMargin
                    text: lv.list[index]
                    onCheckedChanged: {
                        if (checked) tdt.cfilters.push(text);
                        else  {
                            var cf = [];
                            for (var c in tdt.cfilters) {
                                if (tdt.cfilters[c] !== text) cf.push(text);
                            }
                            tdt.cfilters = cf;
                        }

                    }
                }
            }
        }


    }
    onStatusChanged: {
        if (status === PageStatus.Active /*&& pageStack.depth === 1 */) {
            pageStack.pushAttached("Filters.qml", {state: "contexts"});
        }
    }

    states: [
        State {
            name: "projects"
            PropertyChanges {
                target: lv;
                delegate: projectDelegate
            }
            PropertyChanges {
                target: ph;
                title: "Projects"
            }
        }
        , State {
            name: "contexts"
            PropertyChanges {
                target: lv;
                delegate: contextDelegate
            }
            PropertyChanges {
                target: ph;
                title: "Contexts"
            }
        }

    ]
}

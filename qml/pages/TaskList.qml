import QtQuick 2.0
import Sailfish.Silica 1.0

import "../components"
//import "../tdt/todotxt.js" as JS

Page {
    id: page
    property string name: "TaskList"

    SilicaListView {
        id: lv
        anchors.fill: parent
        //spacing: Theme.paddingMedium

        VerticalScrollDecorator {}
        PullDownMenu {
            MenuItem {
                text: qsTr("Settings")
                onClicked: pageStack.push(Qt.resolvedUrl("Settings.qml"))
            }
            MenuItem {
                text: qsTr("Sorting & Grouping")
                onClicked: pageStack.push(Qt.resolvedUrl("SortPage.qml"))
            }
            MenuItem {
                visible: ttm1.file.writeable
                text: qsTr("Add New Task")
                onClicked: app.addTask()
            }
            MenuItem {
                visible: ttm1.file.pathExists && !ttm1.file.exists
                text: qsTr("Create file")
                onClicked: {
                    ttm1.file.create()
                }
            }
        }


        PushUpMenu {
            MenuItem {
                text: (filterSettings.hideDone ? qsTr("Show") : qsTr("Hide")) + qsTr(" Completed Tasks")
                onClicked: filterSettings.hideDone = !filterSettings.hideDone
            }
        }

        header: Item {
            width: page.width
            height: pgh.height + flbl.height
            PageHeader {
                id: pgh
                title: qsTr("Tasklist")
                description: taskModel.sorting.groupText + taskModel.sorting.sortText
            }
            Label { /*from PageHeaderDescription.qml */
                id: flbl
                width: pgh.width - pgh.leftMargin - pgh.rightMargin
                anchors {
                    top: pgh.bottom
                    topMargin: -Theme.paddingMedium
                    right: pgh.right
                    rightMargin: pgh.rightMargin
                }
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.highlightColor
                opacity: 0.6
                horizontalAlignment: Text.AlignRight
                truncationMode: TruncationMode.Fade
                text: qsTr("Filter") + ": " + taskModel.filters.text
            }
        }

        footer: Item {
            width: page.width
            height: lv.spacing*2
        }

        section {
            property: "section"
            criteria: ViewSection.FullString
            delegate: SectionHeader {
                text: section
            }
        }

        ViewPlaceholder {
            enabled: lv.count === 0
            text: qsTr("No Tasks")
            hintText: (ttm1.file.hintText === ""? qsTr("Pull down to add task.")
                                                : ttm1.file.hintText)
        }

        model: taskModel
        Connections {
            target: taskModel
            onEditItem: pageStack.push(Qt.resolvedUrl("TaskEdit.qml"),
                                       {
                                           taskIndex: index,
                                           text: ttm1.tasks.get(index).fullTxt
                                       })
        }

//        add: Transition {
//            //            NumberAnimation { properties: "x,y"; duration: 150 }
////                NumberAnimation {
////                    properties: "fadeFactor, opacity";
////                    to: 1;
////                    duration: 150;
////                    easing.type: Easing.InOutQuad
////                }
//        }

//        displaced: Transition {
//            NumberAnimation { properties: "x,y"; duration: 400; easing.type: Easing.OutBounce }
////            NumberAnimation {
////                properties: "fadeFactor, opacity";
////                to: 1;
////            }
//        }

//        move: Transition {
//            NumberAnimation { properties: "x,y"; duration: 150 }
//            ScriptAction {
//                script: console.log("moving")
//            }
//        }

//        remove: Transition {
////            NumberAnimation {
////                properties: "fadeFactor, opacity";
////                to: 0;
////                duration: 150;
////                easing.type: Easing.InOutQuad
////            }
//        }
    }

    onStatusChanged: {
        if (status === PageStatus.Active) {
            ttm1.readFile()
            /* attach filter page: */
            if ( pageStack.depth === 1) {
                if (settings.projectFilterLeft) {
                    //                    console.log("replacing tl")
                    pageStack.replace(Qt.resolvedUrl("FiltersPage.qml"),
                                      {state: "projects", skip: true}, PageStackAction.Immediate);
                } else {
                    pageStack.pushAttached(Qt.resolvedUrl("FiltersPage.qml"), {state: "projects"})
                }
            } else {
                if (!settings.projectFilterLeft){
                    pageStack.replaceAbove(null, Qt.resolvedUrl("TaskList.qml"),
                                           {}, PageStackAction.Immediate);
                } else {
                    pageStack.pushAttached(Qt.resolvedUrl("FiltersPage.qml"), {state: "contexts"})
                }
            }
        }
    }
}



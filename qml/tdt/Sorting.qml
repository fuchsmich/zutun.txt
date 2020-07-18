import QtQuick 2.0
import "todotxt.js" as JS


QtObject {
    signal sortingChanged()

    property bool asc: true
    onAscChanged: sortingChanged()

    //sort according to: 0..fullTxt, 1..creation date, 2..due date, 3..subject
    property int order: 0
    onOrderChanged: sortingChanged()

    //group by: 0..none, 1..projects, 2..contexts
    property int groupBy: 0
    onGroupByChanged: {
        console.log(groupBy)
        sortingChanged()
    }

    readonly property var sectionProperty: {
        return ["none", "projects", "contexts"][groupBy]
    }

    property string sortText: qsTr("Sorted by %1").arg(functionList[order][0] + ", " + (asc ? qsTr("asc") : qsTr("desc")))
    property string groupText: (groupBy > 0 ? qsTr("Grouped by %1, ").arg(groupFunctionList[groupBy][0]) : "")

    //returns a function, which compares two items
    property var lessThanFunc: groupFunctionList[groupBy][1]

    //list of functions for sorting; *left* and *right* are the items to compare
    property var functionList: [
        //: SortPage, sorting by: Natural
        [qsTr("Natural"), function(left, right) {
            //TODO ä wird nach x gereiht! locale?
            return (left.fullTxt === right.fullTxt ?
                        0 :
                        ((left.fullTxt < right.fullTxt) ^ asc) * -1
                    )
        }],
        //: SortPage, sorting by: Creation date
        [qsTr("Creation Date"), function(left, right) {
            return (left.creationDate === right.creationDate ?
                        functionList[0][1](left, right) :
                        ((left.creationDate < right.creationDate) ^ asc) * -1
                    )
        }],
        //: SortPage, sorting by: Due date
        [qsTr("Due date"), function(left, right) {
            return (left.due === right.due ?
                        functionList[0][1](left, right) :
                        ((left.due < right.due) ^ asc) * -1
                    )
        }],
        //: SortPage, sorting by: Subject
        [qsTr("Subject"), function(left, right) {
            return (left.subject === right.subject ?
                        functionList[0][1](left, right) :
                        ((left.subject < right.subject) ^ asc) *  -1
                    )
        }]
    ]

    //0..Name, 1..lessThanFunc, 2..return list of groups
    property var groupFunctionList: [
        //: SortPage, group by: None
        [qsTr("None"),
         function(left, right) {
             return functionList[order][1](left, right)
         },
         function(line) {
             return []
         }
        ]
        //: SortPage, group by: Projects
        ,[qsTr("Projects"),
          function(left, right) {
              return (left.projects === right.projects ?
                          functionList[order][1](left, right) :
                          (left.projects < right.projects) ^ !asc
                      )
          }]
        //: SortPage, group by: Contexts
        ,[qsTr("Contexts"),
          function(left, right) {
              return (left.contexts === right.contexts ?
                          functionList[order][1](left, right) :
                          (left.contexts < right.contexts) ^ !asc
                      )
          }]
    ]
}

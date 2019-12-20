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

    property string sortText: qsTr("Sorted by %1").arg(functionList[order][0] + ", " + (asc ? qsTr("asc") : qsTr("desc")))
    property string groupText: (groupBy > 0 ? qsTr("Grouped by %1, ").arg(groupFunctionList[groupBy][0]) : "")

    //returns a function, which compares two items
    property var lessThanFunc: groupFunctionList[groupBy][1]

    //returns a function, which returns a list of groups (=sections)
    //property var getGroups: groupFunctionList[groupBy][2]
    function getGroups(task) {
        return groupFunctionList[groupBy][2](task)
    }

    //list of functions for sorting; *left* and *right* are the items to compare
    property var functionList: [
        [qsTr("natural"), function(left, right) {
            return (left.fullTxt === right.fullTxt ?
                        false :
                        (left.fullTxt < right.fullTxt) ^ !asc
                    )
        }],
        [qsTr("Creation Date"), function(left, right) {
            return (left.creationDate === right.creationDate ?
                        functionList[0][1](left, right) :
                        (left.creationDate < right.creationDate) ^ !asc
                    )
        }],
        [qsTr("Due Date"), function(left, right) {
            return (left.due === right.due ?
                        functionList[0][1](left, right) :
                        (left.due < right.due) ^ !asc
                    )
        }],
        [qsTr("Subject"), function(left, right) {
            return (left.subject === right.subject ?
                        functionList[0][1](left, right) :
                        (left.subject < right.subject)^ !asc
                    )
        }]
    ]


    //0..Name, 1..lessThanFunc, 2..return list of groups
    property var groupFunctionList: [
        [qsTr("None"),
         function(left, right) {
             return functionList[order][1](left, right)
         },
         function(line) {
             return []
         }
        ]
        ,[qsTr("Projects"),
          function(left, right) {
              //console.log(typeof left.section, right.section)
              return (left.section === right.section ?
                          functionList[order][1](left, right) :
                          (left.section < right.section) ^ !asc
                      )
          },
          function(task) {
              return JS.projects.getList(task)
          }]
        ,[qsTr("Contexts"),
          function(left, right) {
              return groupFunctionList[1][1](left,right)
          },
          function(task) {
              return JS.contexts.getList(task)
          }]
    ]
}

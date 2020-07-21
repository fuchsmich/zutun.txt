import QtQuick 2.0
import QtQml.Models 2.2

Package {
    id: pkg
    TaskListItem {
        Package.name: "list"
        onResortItem: pkg.DelegateModel.groups = ["unsorted"]
    }
    CoverListItem { Package.name: "cover" }
}

.pragma library

var tools = {
    alphabet: "ABCDEFGHIJKLMNOPQRSTUVWXYZ",
    urlPattern: /(\b(https?|ftp|file):\/\/[-A-Z0-9+&@#\/%?=~_|!:,.;]*[-A-Z0-9+&@#\/%=~_|])/ig,
    mailPattern: /([\w\.\-]+)@([\w\-]+)((\.(\w){2,3})+)/ig,
    // colors for priorities: aus ColorPicker.qml:
    prioColors: ["#e60003", "#e6007c", "#e700cc", "#9d00e7",
        "#7b00e6", "#5d00e5", "#0077e7", "#01a9e7",
        "#00cce7", "#00e696", "#00e600", "#99e600",
        "#e3e601", "#e5bc00", "#e78601"],
    //return color for given priority A,B,C...
    prioColor: function(prio) {
        return tools.prioColors[tools.alphabet.search(prio) % tools.prioColors.length]
    },
    projectColor: "red",
    contextColor: "blue",
    //return text with html tags around email addresses
    linkify: function(text) {
        text = text.replace(tools.mailPattern, function(url) {
            return '<a href="mailto:' + url + '">' + url + '</a>'
        });
        return text.replace(tools.urlPattern, function(url) {
            return '<a href="' + url + '">' + url + '</a>'
        });
    },
    today: function() {
        return Qt.formatDate(new Date(),"yyyy-MM-dd")
    },
    //return JSON item for textline
    lineToJSON: function(line, lineNumber) {
        var item = baseFeatures.parseLine(line)

        var displayText = tools.linkify(item.subject)
        displayText = displayText.replace(
                    projects.pattern,
                    function(x) { return ' <font color="' + tools.projectColor + '">' + x + ' </font>'})
        displayText = displayText.replace(
                    contexts.pattern,
                    function(x) { return ' <font color="' + tools.contextColor + '">' + x + ' </font>'})
        displayText = (item.priority !== "" ?
                           '<font color="' + tools.prioColor(item.priority) + '">(' + item.priority + ') </font>' : "")
                + displayText //item.subject //+ '<br/>' +item.creationDate

        item["formattedSubject"] = displayText

        //item["section"] = ""
        item["projects"] = projects.listLine(line).sort().join(", ")
        item["contexts"] = contexts.listLine(line).sort().join(", ")

        if (lineNumber !== undefined) item["lineNumber"] = lineNumber

        return item
    },
    //return array of tasks
    splitLines: function(fileContent) {
        var tasks = []
        var lines = fileContent.split("\n")
        var txt = ""
        lines.forEach(function(line){
            txt = line.trim()
            if (txt.length !== 0) tasks.push(txt)
        })
        return tasks
    }
}

var taskList = {
    busy: false,
    textList: [],
    itemList: [],
    //set new text list and parse it
    setTextList: function (newList) {
        this.busy = true
        this.textList = tools.splitLines(newList)
        this.textList.sort()
        this.populateItemList()
        this.textListChanged(true)
        this.busy = false
    },
    //return add task string to tasklist
    populateItemList: function(){
        this.itemList = []
        this.textList.forEach(function(item, i){
            //console.debug(item, i)
            taskList.itemList.push(tools.lineToJSON(item, i))
        })
    },
    addTask: function(text){
        this.busy = true
        this.textList.push(text)
        this.textList.sort()
        this.populateItemList()
        this.textListChanged()
        this.busy = false
    },
    removeTask: function(index){
        this.busy = true
        this.textList.splice(index, 1)
        this.populateItemList()
        this.textListChanged()
        this.busy = false
    },
    modifyTask: function(index, feature, value) {
        this.busy = true
        //console.debug(index, feature, value)
        this.textList[index] = baseFeatures.modifyLine(this.textList[index], feature, value)
        this.textList.sort()
        this.populateItemList()
        this.textListChanged()
        this.busy = false
    },
    textListChanged: function(save){
        console.log("replace with actual save function", txt.toString())
    }
}


var baseFeatures = {
    //see https://github.com/todotxt/todo.txt

    // fullTxt, complete, priority, (completionDate or creationDate), creationDate, subject
    pattern: /^(x\s)?(\([A-Z]\)\s)?(\d{4}-\d{2}-\d{2}\s)?(\d{4}-\d{2}-\d{2}\s)?(.*)/ ,
    datePattern: /^\d{4}-\d{2}-\d{2}$/,

    //indices of matches in pattern
    fullTxt: 0,
    done: 1,
    priority: 2,
    completionDate: 3,
    creationDate: 4,
    subject: 5,

    //returns array of matches
    getMatches: function(line) {
        var matches = line.match(this.pattern)
        if (matches[this.done] === undefined && matches[this.creationDate] === undefined)
            //swap creationDate, completionDate
            matches[this.creationDate] = matches.splice(this.completionDate, 1, matches[this.creationDate])[0]
        return matches
    },

    //returns JSON object of a task
    parseLine: function(line) {
        //baseFeatures
        var fields = this.getMatches(line)
        var values = {
            fullTxt: fields[this.fullTxt],
            done: fields[this.done] !== undefined,
            priority: (fields[this.priority] !== undefined ?
                           fields[this.priority].charAt(1) : ""),
            //wenn creationDate auch gesetzt, im Feld completionDate
            completionDate: (fields[this.completionDate] !== undefined ? fields[this.completionDate] : "").trim(),
            //wenn creationDate leer, im Feld completionDate enthalten
            creationDate: (fields[this.creationDate] !== undefined ? fields[this.creationDate]: "").trim(),
            subject: fields[this.subject].trim()
        }

        //projects
//        values['projects'] = projects.listLine(line)
//        console.log(line, projects.listLine(line))

        //contexts
        //values['contexts'] = contexts.list([line])

        //due
        var dueFields = due.get(values.subject)
        values.subject = dueFields[due.subject]
        values['due'] = dueFields[due.date]

        return values
    },

    modifyLine: function(line, feature, value) {
        //TODO validierung von value???
        console.debug(line, feature, value)
        var fields = this.getMatches(line)
        //        console.log(fields)
        switch (feature) {
        case this.fullTxt :
            return value
        case this.done :
            if (value === false) {
                fields[feature] = undefined
                fields[this.completionDate] = undefined
            } else {
                fields[feature] = "x "
                fields[this.completionDate] = tools.today() + " "
            }
            break
        case this.priority:
            if (value === false || value === "") { fields[feature] = undefined; break }
            else if (tools.alphabet.indexOf(value) > -1) { fields[feature] = "(" + value + ") "; break }
            break
        case this.creationDate:
            if (value === false) fields[feature] = undefined
            else if (this.datePattern.test(value)) fields[feature] = value + " "
            else if (value instanceof Date) fields[feature] = Qt.formatDate(value, 'yyyy-MM-dd') + " "
            break
        }
        fields[this.fullTxt] = undefined
        //        console.log(fields)
        return fields.join("")
    }
}

/* get list of matches*/
function getMatchesList(tasks, pattern) {
    var task = ""
    var list = []

    for (var t = 0; t < tasks.length; t++) {
        task = tasks[t];
        var matches = task.match(pattern);

        var match = "";
        for (var i in matches) {
            match = matches[i].trim();
            if (typeof list[match] === 'undefined') list[match] = [];
            if (list[match].indexOf(t) === -1) list[match].push(t);
        }
    }
    list.sort();
    return list;
}

function getMatchesList2(text, pattern) {
    //console.log("isarray", Array.isArray(text))
    //console.log("typeof", typeof text)
    //console.log("matches", text.match(pattern))
    //var taskList = []
    var matchesList = []

    if (Array.isArray(text)) text = text.join("\n")

    var matches = text.match(pattern)

    var match = "";
    for (var i in matches) {
        match = matches[i].trim()
        if (matchesList.indexOf(match) === -1) matchesList.push(match)
    }
    matchesList.sort()
    //console.log("matcheslist", matchesList)
    return matchesList;
}

function getMatchesLine(task, pattern) {
    var matches, trimmedMatches
    matches = task.match(pattern)
    if (matches)
        trimmedMatches = matches.map(function (item, index, array) {
            return item.trim()
        })

    return (trimmedMatches ? trimmedMatches : [])
}



var projects = {
    pattern: /(^|\s)(\+\S+)/g ,
    /* get list of projects for tasklist*/
    listAll: function(tasks) {
        return getMatchesList(tasks, this.pattern)
    },
    /* get list of contexts for task*/
    listLine: function(task) {
        //console.log(getMatchesLine(task, projects.pattern))
        return getMatchesLine(task, this.pattern)
    },
    /* get list of contexts for text*/
    getList: function() {
        return getMatchesList2(taskList.textList, this.pattern)
    }
}

var contexts = {
    pattern: /(^|\s)\@\S+/g ,
    /* get list of contexts for tasklist*/
    listAll: function(tasks) {
        return getMatchesList(tasks, this.pattern);
    },
    /* get list of contexts for task*/
    listLine: function(task) {
        return getMatchesLine(task, this.pattern)
    },
    /* get list of contexts for text*/
    getList: function() {
        return getMatchesList2(taskList.textList, this.pattern)
    }
}

var due = {
    datePattern: /^\d{4}-\d{2}-\d{2}$/,
    pattern: /(^|\s)due:\d{4}-\d{2}-\d{2}(\s|$)/,
    subjectPattern: /(^|.*\s)due:(\d{4}-\d{2}-\d{2})(\s.*|$)/,

    //indices
    date: 0,
    subject: 1,

    set: function(task, date) {
        var dueStr = "due:";
        if (typeof date === "string" && due.datePattern.test(date)) {
            dueStr += date.trim()
        } else if (date instanceof Date) {
            dueStr += Qt.formatDate(date, 'yyyy-MM-dd')
        }
        if (due.pattern.test(dueStr))  {
            if (due.pattern.test(task))
                return task.replace(due.pattern, " " + dueStr + " ");
            else
                return task + " " + dueStr.trim()
        } else if (date === "") {
            return task.replace(due.pattern, "");
        }
    },
    get: function(subject) {
        var dueDate = "";
        if (due.subjectPattern.test(subject)) {
            var matches = subject.match(due.subjectPattern)
            dueDate = matches[2];
            subject = matches[1].trim() + " " + matches[3].trim()
        }
        return [dueDate, subject]
    }
}

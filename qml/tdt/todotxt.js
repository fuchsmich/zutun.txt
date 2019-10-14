.pragma library

var alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
var urlPattern =/(\b(https?|ftp|file):\/\/[-A-Z0-9+&@#\/%?=~_|!:,.;]*[-A-Z0-9+&@#\/%=~_|])/ig
var mailPattern= /([\w\.\-]+)@([\w\-]+)((\.(\w){2,3})+)/ig

// fullTxt, complete, priority, (completionDate or creationDate), creationDate, subject
var baseFeatures = {
    pattern: /^(x\s)?(\([A-Z]\)\s)?(\d{4}-\d{2}-\d{2}\s)?(\d{4}-\d{2}-\d{2}\s)?(.*)/ ,
    datePattern: /^\d{4}-\d{2}-\d{2}$/,


    //indices
    fullTxt: 0,
    done: 1,
    priority: 2,
    completionDate: 3,
    creationDate: 4,
    subject: 5,

    getMatches: function(line) {
        var matches = line.match(this.pattern)
        if (matches[this.creationDate] === undefined)
            //swap creationDate, completionDate
            matches[this.creationDate] = matches.splice(this.completionDate, 1, matches[this.creationDate])[0]
        return matches
    },

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
                //nur setzen, wenn creationDate auch gesetzt
                fields[this.completionDate] = (fields[this.creationDate] !== undefined ? today() + " " : undefined)
            }
            break
        case this.priority:
            if (value === false || value === "") { fields[feature] = undefined; break }
            else if (alphabet.indexOf(value) > -1) { fields[feature] = "(" + value + ") "; break }
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

function getMatchesLine(task, pattern) {
    var matches, trimmedMatches
    if (matches = task.match(pattern))
        trimmedMatches = matches.map(function (item, index, array) {
            return item.trim()
        })

    return (trimmedMatches ? trimmedMatches : [])
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
    getList: function(text) {
        return getMatchesList2(text, this.pattern)
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
    getList: function(text) {
        return getMatchesList2(text, this.pattern)
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

function splitLines(fileContent) {
    var tasks = []
    var lines = fileContent.split("\n")
    var txt = ""
    for (var t = 0; t < lines.length; t++) {
        txt = lines[t].trim();
        if (txt.length !== 0) tasks.push(txt)
    }
    return tasks
}

function today() {
    return Qt.formatDate(new Date(),"yyyy-MM-dd");
}


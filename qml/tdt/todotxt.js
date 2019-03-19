.pragma library

var alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
// fullTxt, complete, priority, (completionDate or creationDate), creationDate, subject
var baseFeatures = {
    pattern: /^(x\s)?(\([A-Z]\)\s)?(\d{4}-\d{2}-\d{2}\s)?(\d{4}-\d{2}-\d{2}\s)?(.*)/ ,

    //indices
    fullTxt: 0,
    done: 1,
    priority: 2,
    completionDate: 3,
    creationDate: 4,
    subject: 5,

    getMatches: function(line) {
        var matches = line.match(baseFeatures.pattern)
        if (matches[baseFeatures.creationDate] === undefined)
            //swap creationDate, completionDate
            matches[baseFeatures.creationDate] = matches.splice(baseFeatures.completionDate, 1, matches[baseFeatures.creationDate])[0]
        return matches
    },

    parseLine: function(line) {
        //baseFeatures
        var fields = baseFeatures.getMatches(line)
        var values = {
            fullTxt: fields[baseFeatures.fullTxt],
            done: fields[baseFeatures.done] !== undefined,
            priority: (fields[baseFeatures.priority] !== undefined ?
                           fields[baseFeatures.priority].charAt(1) : ""),
            //wenn creationDate auch gesetzt, im Feld completionDate
            completionDate: (fields[baseFeatures.completionDate] !== undefined ? fields[baseFeatures.completionDate] : "").trim(),
            //wenn creationDate leer, im Feld completionDate enthalten
            creationDate: (fields[baseFeatures.creationDate] !== undefined ? fields[baseFeatures.creationDate]: "").trim(),
            subject: fields[baseFeatures.subject].trim()
        }

        //due
        var dueFields = due.get(values.subject)
        values.subject = dueFields[due.subject]
        values['due'] = dueFields[due.date]

        return values
    },

    modifyLine: function(line, feature, value) {
        //TODO validierung von value???
        var fields = baseFeatures.getMatches(line)
        //        console.log(fields)
        switch (feature) {
        case baseFeatures.done :
            if (value === false) {
                fields[feature] = undefined
                fields[baseFeatures.completionDate] = undefined
            } else {
                fields[feature] = "x "
                //nur setzen, wenn creationDate auch gesetzt
                fields[baseFeatures.completionDate] = (fields[baseFeatures.creationDate] !== undefined ? today() + " " : undefined)
            }
            break
        case baseFeatures.priority :
            if (value === false) fields[feature] = undefined
            else fields[feature] = "(" + value + ") "
            break
        case baseFeatures.creationDate:
            if (value === false) fields[feature] = undefined
            else fields[feature] = value + " "
            break
        }
        fields[baseFeatures.fullTxt] = undefined
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
        //        console.log(matches)

        var match = "";
        for (var i in matches) {
            match = matches[i].trim();
            //            console.log(match)
            if (typeof list[match] === 'undefined') list[match] = [];
            if (list[match].indexOf(t) === -1) list[match].push(t);
        }
    }
    //   console.log(list, list.length)
    list.sort();
    return list;
}

var projects = {
    pattern: /(^|\s)\+\S+/g ,
    list: function(tasks) {
        return getMatchesList(tasks, projects.pattern)
    }
}

var contexts = {
    pattern: /(^|\s)\@\S+/g ,
    list: function(tasks) {
        return getMatchesList(tasks, contexts.pattern);
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
        //console.log(typeof date, date);
        var dueStr = "due:";
        if (typeof date === "string" && due.datePattern.test(date)) {
            dueStr += date.trim();
        } else if (date instanceof Date) {
            dueStr += Qt.formatDate(date, 'yyyy-MM-dd');
        }
        //console.log(dueStr);
        if (due.pattern.test(dueStr))  {
            if (due.pattern.test(task))
                return task.replace(due.pattern, " " + dueStr + " ");
            else
                return task + " " + dueStr.trim();
        }
    },
    get: function(subject) {
        var dueDate = "";
        if (due.subjectPattern.test(subject)) {
            var matches = subject.match(due.subjectPattern);
            dueDate = matches[2];
            subject = matches[1].trim() + " " + matches[3].trim();
        }
        return [dueDate, subject];
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


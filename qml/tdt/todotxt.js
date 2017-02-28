.pragma library

var alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
// fullTxt, complete, priority, (completionDate or creationDate), creationDate, subject
var baseFeatures = {
    pattern: /^(x\s)?(\([A-Z]\)\s)?(\d{4}-\d{2}-\d{2}\s)?(\d{4}-\d{2}-\d{2}\s)?(.*)/ ,
    fullTxt: 0,
    done: 1,
    priority: 2,
    completionDate: 3,
    creationDate: 4,
    subject: 5,

    getMatches: function(line) {
        var matches = line.match(baseFeatures.pattern)
        if (matches[baseFeatures.creationDate] === undefined)
            //swap creationDate, baseFeatures
            matches[baseFeatures.creationDate] = matches.splice(baseFeatures.completionDate, 1, matches[baseFeatures.creationDate])[0]
        return matches
    },

    parseLine: function(line) {
        var fields = baseFeatures.getMatches(line)
//        console.log(fields)
        return {
            fullTxt: fields[baseFeatures.fullTxt],
            done: fields[baseFeatures.done] !== undefined,
            priority: (fields[baseFeatures.priority] !== undefined ?
                           fields[baseFeatures.priority].charAt(1) : ""),
            //wenn creationDate auch gesetzt, im Feld completionDate
            completionDate: (fields[baseFeatures.completionDate] !== undefined ? fields[baseFeatures.completionDate] : "").trim(),
//                (fields[baseFeatures.creationDate] !== undefined ?
//                (fields[baseFeatures.completionDate] !== undefined ? fields[baseFeatures.completionDate] : "") :
//                                 "").trim(),
            //wenn creationDate leer, im Feld completionDate enthalten
            creationDate: (fields[baseFeatures.creationDate] !== undefined ? fields[baseFeatures.creationDate]: "").trim(),
//                (fields[baseFeatures.creationDate] === undefined ?
//                               (fields[baseFeatures.completionDate] !== undefined ? fields[baseFeatures.completionDate]: "") :
//                               fields[baseFeatures.creationDate]).trim(),
            subject: fields[baseFeatures.subject].trim()
        }
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

var projects = {
    pattern: /\s\+\S+/g ,
    list: function(tasks) {
        return getPrjCtxtList(tasks, projects.pattern)
    }
}

var contexts = {
    pattern: /\s\@\S+/g ,
    list: function(tasks) {
        return getPrjCtxtList(tasks, contexts.pattern)
    }
}

function getPrjCtxtList(tasks, pattern) {
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
    return list
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


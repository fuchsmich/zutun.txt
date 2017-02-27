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
        console.log(fields)
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
        console.log(fields)
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

/* parse plain Text*/
function parseTodoTxt(todoTxt) {
    var tlist = [];
    var plist = [];
    var clist = [];
    var proConArray = [];
    var tasks = todoTxt.split("\n");
    tasks.sort();


    //clean lines, remove empty lines
    var txt = "";
    for (var t = 0; t < tasks.length; t++) {
        txt = tasks[t].trim();
        if (txt.length !== 0) tlist.push(txt);
    }
    tasks = tlist;
    tlist = [];

    //parse lines
    for (t = 0; t < tasks.length; t++) {
        //                console.log(t, tasks[t]);
        txt = tasks[t];

        //alles auf einmal fullTxt, done, completionDate, priority, creationDate, subject
        var matches = txt.match(/^(x\s)?(\d{4}-\d{2}-\d{2}\s)?(\([A-Z]\)\s)?(\d{4}-\d{2}-\d{2}\s)?(.*)/);
        tlist.push(matches);



        /* collect projects (+) and contexts (@)*/
        matches = txt.match(/\s(\+|@)\S+/g);
        for (var i in matches) {
            matches[i] = matches[i].toUpperCase().trim();
        }
//        console.log(t, matches);
        var m = "";
        for (var i in matches) {
            m = matches[i];
            if (typeof proConArray[m] === 'undefined') proConArray[m] = [];
            proConArray[m].push(t);
            proConArray[m] = proConArray[m].concat(matches);
//            console.log(m, proConArray[m])
            if (m.charAt(0) === "+") {
                if (typeof plist[m] === 'undefined') plist[m] = [];
                plist[m].push(t);
            }
            if (m.charAt(0) === "@") {
                if (typeof clist[m] === 'undefined') clist[m] = [];
                clist[m].push(t);
            }
        }
//        console.log(proConArray)
    }

    //results
    return {
        projects: plist,
        contexts: clist,
        taskList: tlist,
        tasks: tasks,
        proConArray: proConArray
    }
}

function today() {
    return Qt.formatDate(new Date(),"yyyy-MM-dd");
}


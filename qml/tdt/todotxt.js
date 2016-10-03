.pragma library

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

        //alles auf einmal fullTxt, done, doneDate, priority, creationDate, subject
        var matches = txt.match(/^(x\s)?(\d{4}-\d{2}-\d{2}\s)?(\([A-Z]\)\s)?(\d{4}-\d{2}-\d{2}\s)?(.*)/);
        tlist.push(matches);



        /* collect projects (+) and contexts (@)*/
        matches = txt.match(/\s(\+|@)\S+/g);
        for (var i in matches) {
            matches[i] = matches[i].toUpperCase().trim();
        }
        console.log(t, matches);
        var m = "";
        for (var i in matches) {
            m = matches[i];
            if (typeof proConArray[m] === 'undefined') proConArray[m] = [];
            proConArray[m].push(t);
            proConArray[m] = proConArray[m].concat(matches);
            console.log(m, proConArray[m])
            if (m.charAt(0) === "+") {
                if (typeof plist[m] === 'undefined') plist[m] = [];
                plist[m].push(t);
            }
            if (m.charAt(0) === "@") {
                if (typeof clist[m] === 'undefined') clist[m] = [];
                clist[m].push(t);
            }
        }
    }

    //results
    return {
        projects: plist,
        contexts: clist,
        taskList: tlist,
        proConArray: proConArray
    }
}


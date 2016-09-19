.pragma library

/* parse plain Text*/
function parseTodoTxt(todoTxt) {
    var tlist = [];
    var plist = [];
    var clist = [];
    var tasks = todoTxt.split("\n");
    tasks.sort();


    //clean lines, remove empty lines
    var txt = "";
    for (var t in tasks) {
        txt = tasks[t].trim();
        if (txt.length !== 0) tlist.push(txt);
    }
    tasks = tlist;
    tlist = [];

    //parse lines
    for (t in tasks) {
        //                console.log(t, tasks[t]);
        txt = tasks[t];

        //alles auf einmal fullTxt, done, doneDate, priority, creationDate, subject
        var matches = txt.match(/^(x\s)?(\d{4}-\d{2}-\d{2}\s)?(\([A-Z]\)\s)?(\d{4}-\d{2}-\d{2}\s)?(.*)/);
        tlist.push(matches);


//        /* find lowest prio*/
//        lowestPrio = (matches[priority] > lowestPrio ? matches[priority] : lowestPrio);


        /* collect projects (+) and contexts (@)*/
        var m;
        var pmatches = txt.match(/\s\+\w+(\s|$)/g);
        for (var p in pmatches) {
            m = pmatches[p].toUpperCase().trim();
            if (typeof plist[m] === 'undefined') plist[m] = [];
            plist[m].push(t);
//                    console.log(m, plist[m]);
        }

        var cmatches = txt.match(/\s@\w+(\s|$)/g);
        for (var c in cmatches) {
            m = cmatches[c].toUpperCase().trim();
            if (typeof clist[m] === 'undefined') clist[m] = [];
            clist[m].push(t);
//                    console.log(m, clist[m]);
        }



    }

    //results
    return {
        projects: plist,
        contexts: clist,
        taskList: tlist
    }
}


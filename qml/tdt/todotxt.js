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



        var proConArray = [];
        matches = txt.match(/\s(\+|@)\S+/g);
        for (var m in matches) {
            if (typeof plist[m] === 'undefined') plist[m] = [];
            proConArray.push(t, matches);
        }

        /* collect projects (+) and contexts (@)*/
//        var m;

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
        taskList: tlist,
        proConArray: proConArray
    }
}


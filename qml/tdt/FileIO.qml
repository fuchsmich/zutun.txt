import QtQuick 2.0
import io.thp.pyotherside 1.4

//TODO check if file is changed on disk
Python {
    id: py

    property string path
    onPathChanged: if (pythonReady) status = 1
    property string folder: path.substring(0, path.lastIndexOf("/")+1)
    property string content: ""

    signal ioError(string msg)
    signal readSuccess(string content)

    property bool pathExists: false
    property bool exists: false
    property bool readable: false
    property bool writeable: false

    property var lastChange

    /* 0..init
    1..ready
    2..reading
    3..writing
    10..error
    */
    property int status: 0
    property bool busy: status === 0 ||status === 2 || status === 3
    property bool pythonReady: false
    onPythonReadyChanged: if (path) status = 1

    function read() {
        //console.debug("reading", "ready:", pythonReady, "path:", path)
        if (status === 1) {
            status = 2
            var pyPath = (path.substring(0,7) == "file://" ? path.substring(7) : path)
            py.call('fileio.read', [pyPath], function(result){
                var _mtime = new Date(result[1]*1000)
                if (lastChange === undefined || lastChange < _mtime) {
                    lastChange = _mtime
                    content = result[0]
                    py.readSuccess(content)
                    console.log("read", "path:", path, "file mdate", lastChange)
                } else console.log("nothing new", path, _mtime)
                status = 1
            })
        }
    }

    function save(content) {
        //console.log("saving", "ready:", pythonReady, "path:", path)
        if (status === 1) {
            status = 3
            var pyPath = (path.substring(0,7) == "file://" ? path.substring(7) : path)
            py.call('fileio.write', [pyPath, content], function(result){
                lastChange = new Date(result*1000)
                console.log("saved", "path:", path, "file mdate", lastChange)
                status = 1
            })
        }
    }

    function create() {
        if (status === 1) {
            var pyPath = (path.substring(0,7) == "file://" ? path.substring(7) : path)
            py.call('fileio.create', [pyPath], function(){ })
            console.log("created", "path:", path)
        }
    }

    Component.onCompleted: {
        addImportPath(Qt.resolvedUrl('../python'))
        importModule('fileio', function() {})
        setHandler('ioerror', ioError)
        setHandler('pathExists', function(value) {
            pathExists = value
            if (!value) {
                exists = false
            }
        })
        setHandler('fileExists', function(value) {
            exists = value
            if (!value) {
                readable = false
            }
        })
        setHandler('readable', function(value) {
            readable = value
            if (!value) {
                writeable = false
            }
        })
        setHandler('writeable', function(value) {
            writeable = value
        })
        pythonReady = true
    }

    onReceived: {
        console.log("Event: " + data)
    }

    onError: console.log('Python error: ' + traceback)
}

import QtQuick 2.0
import io.thp.pyotherside 1.4

Python {
    id: py

    property string path
    onPathChanged: {
        reset()
        if (pythonReady) status = 1
    }

    function reset() {
        lastChange = undefined
        error = ""
        pathExists = false
        exists = false
        readable = false
        writeable = false
    }

    property string error: ""
    signal ioError(string msg)
    onIoError: error = msg
    signal readSuccess(string content)
    onReadSuccess: {
        error = ""
    }

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

    function pyPath() {
        return (path.substring(0,7) == "file://" ? path.substring(7) : path)
    }

    function read(reason) {
        console.debug(reason)
        if (status === 1) {
            status = 2
            var _pyPath = py.pyPath()
            py.call('fileio.read', [_pyPath], function(result){
                if (_pyPath !== py.pyPath()) {
                    console.log("path changed, trying to read again")
                    status = 1
                    read("path changed")
                    return
                }
                if (!result) {
                    console.log("no reading result")
                }
                var _mtime = new Date(result[1]*1000)
                if (lastChange instanceof Date && !isNaN(lastChange.valueOf()) && lastChange < _mtime) {
                    console.log("nothing new", path, _mtime, lastChange)
                    status = 1
                    return
                }
                if (_mtime instanceof Date && !isNaN(_mtime.valueOf())) lastChange = _mtime
                py.readSuccess(result[0])
                console.log("read", "path:", path, "file mdate", lastChange)
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
        console.debug("Event: " + data)
    }

    onError: console.log('Python error: ' + traceback)
}

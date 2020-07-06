import QtQuick 2.0
import io.thp.pyotherside 1.4

//TODO check if file is changed on disk
Python {
    id: py

    property bool pythonReady: false
    //onPythonReadyChanged: read()
    property string path
    onPathChanged: read()
    property string folder: path.substring(0, path.lastIndexOf("/")+1)
    property string content: ""

    signal ioError(string msg)
    signal readSuccess(string content)

    property bool pathExists: false
    property bool exists: false
    property bool readable: false
    property bool writeable: false

    function read() {
        console.log("reading", "ready:", pythonReady, "path:", path)
        if (pythonReady && path) {
            var pyPath = (path.substring(0,7) == "file://" ? path.substring(7) : path)
            py.call('fileio.read', [pyPath], function(result){
                //console.log("read result:", result);
                content = result
                py.readSuccess(result)
            });
        }
    }

    function save(content) {
        console.log("saving", "ready:", pythonReady, "path:", path)
        if (pythonReady && path) {
            var pyPath = (path.substring(0,7) == "file://" ? path.substring(7) : path)
            py.call('fileio.write', [pyPath, content], function(){ })
        }
        read()
    }

    function create() {
        if (pythonReady && path) {
            var pyPath = (path.substring(0,7) == "file://" ? path.substring(7) : path)
            py.call('fileio.create', [pyPath], function(){ })
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

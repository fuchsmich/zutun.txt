import QtQuick 2.0
import io.thp.pyotherside 1.4

Python {
    id: py

    property bool pythonReady: false
    //onPythonReadyChanged: read()
    property string path
    //onPathChanged: read()
    property string folder: path.substring(0, path.lastIndexOf("/")+1)
    //property string content: ""

    signal ioError(string msg)
    signal readSuccess(string content)

    property bool pathExists: false
    property bool exists: false
    property bool readable: false
    property bool writeable: false

    function read() {
        console.log("reading", pythonReady, path)
        var content
        if (pythonReady && path) {
            py.call('fileio.read', [path], function(result){
                //console.log("read result:", result);
                py.readSuccess(result)
            });
        }
    }

    function save(content) {
        console.log("saving", pythonReady, path)
        if (pythonReady && path) {
            py.call('fileio.write', [path, content], function(){ })
        }
    }

    function create() {
        if (pythonReady && path) {
            py.call('fileio.create', [path], function(){ })
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
            readablereadable = value
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

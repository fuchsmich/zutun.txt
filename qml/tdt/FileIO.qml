import QtQuick 2.0
import io.thp.pyotherside 1.4

Python {
    id: py

    property bool pythonReady: false
    onPythonReadyChanged: read();
    property string path
    onPathChanged: read();
    property string folder: path.substring(0,path.lastIndexOf("/")+1)
    property string content: ""

    function read() {
        console.log("reading", pythonReady, path)
        if (pythonReady && path) {
            py.call('fileio.read', [path], function(result){
                //console.log(result);
                content = result;
            });
        }
    }

    function save(content) {
        if (pythonReady && path) {
            py.call('fileio.write', [path, content], function(){ });
        }
        read();
    }

    function create() {
        if (pythonReady && path) {
            py.call('fileio.create', [path], function(){ });
        }
    }

    Component.onCompleted: {
        addImportPath(Qt.resolvedUrl('../python'));
        importModule('fileio', function() {});
        //console.log("ready")
        pythonReady = true;
    }

    onReceived: {
        console.log("Event: " + data);
//        log = data.toString();
    }

    onError: console.log('Python error: ' + traceback)
}

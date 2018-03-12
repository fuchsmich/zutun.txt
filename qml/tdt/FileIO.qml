import QtQuick 2.0
import io.thp.pyotherside 1.4

Python {
    id: py

    property string path: ""
    onPathChanged: {
        //console.log(path);
        if (py.ready) {
            py.call('fileio.setPath', [path], function(){});
        }
        read();
    }

    property string content: ""
    property bool _write: false
    onContentChanged: {
        //console.log(content)
        if (ready && _write) py.call('fileio.write', [content], function(){});
    }


    function read() {
        if (ready) {
            py.call('fileio.read', [], function(content){
                _write = false;
                py.content = content;
                _write = true;
            });
        }
    }

    property bool ready: false
    Component.onCompleted: {
        addImportPath(Qt.resolvedUrl('../python'));
        importModule('fileio', function() {});
        py.call('fileio.setPath', [path], function(){});
        py.call('fileio.read', [], function(content){
            _write = false;
            py.content = content;
            _write = true;
        });
        ready = true;
    }

    onReceived: {
        console.log("Event: " + data);
//        log = data.toString();
    }

    onError: console.log('Python error: ' + traceback)
}

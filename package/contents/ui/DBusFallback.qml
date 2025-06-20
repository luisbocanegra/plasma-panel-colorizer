pragma ComponentBehavior: Bound
pragma ValueTypeBehavior: Addressable

import QtQuick
import "code/utils.js" as Utils

Item {
    id: root
    property string busType
    property string service: ""
    property string objectPath: ""
    property string iface: service
    property string method: ""
    property var arguments: []
    property var signature: null
    property var inSignature: null
    signal callFinished(reply: var)
    property var callbackRef: null

    function builCmd() {
        let cmd = "gdbus call --session --dest " + service + " --object-path " + objectPath + " --method " + iface + "." + method;
        root.arguments.forEach(argument => {
            cmd += ` '${argument}'`;
        });
        return cmd;
    }

    RunCommand {
        id: runCommand
        onExited: (cmd, exitCode, exitStatus, stdout, stderr) => {
            if (exitCode !== 0) {
                stderr = Utils.parseGVariant(stderr);
                root.callFinished({
                    isError: true,
                    isValid: false,
                    error: {
                        isValid: false,
                        message: stderr
                    },
                    value: stderr
                });
            } else {
                root.callFinished({
                    isError: false,
                    isValid: true,
                    error: {
                        isValid: false,
                        message: ""
                    },
                    value: Utils.parseGVariant(stdout)
                });
            }
        }
    }

    function call(callback) {
        if (callbackRef) {
            callFinished.disconnect(callbackRef);
        }
        if (callback) {
            callbackRef = callback;
            callFinished.connect(callback);
        }
        runCommand.run(builCmd());
    }
}

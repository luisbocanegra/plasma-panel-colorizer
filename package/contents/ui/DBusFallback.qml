pragma ComponentBehavior: Bound
pragma ValueTypeBehavior: Addressable

import QtQuick

Item {
    id: root
    property string busType
    property string service: ""
    property string objectPath: ""
    property string iface: ""
    property string method: ""
    property var arguments: []
    property var signature: null
    property var inSignature: null
    signal callFinished(reply: var)

    function builCmd() {
        let cmd = "gdbus call --session --dest " + service + " --object-path " + objectPath + " --method " + iface + "." + method;
        if (root.arguments.length !== 0) {
            cmd += ` '${root.arguments.join(" ")}'`;
        }
        return cmd;
    }

    RunCommand {
        id: runCommand
        onExited: (cmd, exitCode, exitStatus, stdout, stderr) => {
            if (exitCode !== 0) {
                console.error(cmd, exitCode, exitStatus, stdout, stderr);
                return;
            }
            stdout = stdout.trim().replace(/^\([']?/, "") // starting ( or ('
            .replace(/[']?,\)$/, ""); // ending ,) or ',)
            const reply = {
                value: stdout
            };
            root.callFinished(reply);
        }
    }

    function call(callback) {
        runCommand.run(builCmd());
        if (callback)
            callFinished.connect(callback);
    }
}

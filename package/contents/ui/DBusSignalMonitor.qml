pragma ComponentBehavior: Bound
pragma ValueTypeBehavior: Addressable

import QtQuick
import "code/utils.js" as Utils

Item {
    id: root
    property bool enabled: false
    property string busType: "session"
    property string service: ""
    property string path: ""
    property string iface: service
    property string method: ""

    readonly property string toolsDir: Qt.resolvedUrl("./tools").toString().substring(7) + "/"
    readonly property string dbusMessageTool: "'" + toolsDir + "gdbus_get_signal.sh'"
    readonly property string monitorCmd: `${dbusMessageTool} ${busType} ${service} ${iface} ${path} ${method}`

    signal signalReceived(message: string)

    function getMessage(rawOutput) {
        let [path, interfaceAndMember, ...message] = rawOutput.split(" ");

        return message.join(" ").replace(/^\([']?/, "") // starting ( or ('
        .replace(/[']?,\)$/, ""); // ending ,) or ',)
    }

    RunCommand {
        id: runCommand
        onExited: (cmd, exitCode, exitStatus, stdout, stderr) => {
            if (exitCode !== 130) {
                console.error(cmd, exitCode, exitStatus, stdout, stderr);
                return;
            }
            root.signalReceived(root.getMessage(stdout.trim()));
            // for some reason it won't restart without a delay???
            Utils.delay(50, () => {
                runCommand.run(root.monitorCmd);
            }, root);
        }
    }

    function toggleMontitor() {
        if (enabled) {
            runCommand.run(monitorCmd);
        } else {
            runCommand.terminate(monitorCmd);
        }
    }

    onEnabledChanged: toggleMontitor()
    Component.onCompleted: toggleMontitor()
}

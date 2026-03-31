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
    property string instanceId

    readonly property string toolsDir: Qt.resolvedUrl("./tools").toString().substring(7) + "/"
    readonly property string dbusMessageTool: toolsDir + "gdbus_get_signal.sh"
    readonly property string monitorCmd: `"${dbusMessageTool}" ${busType} ${service} ${iface} ${path} ${method} id=${instanceId}`

    signal signalReceived(message: string)
    signal disabled

    function getMessage(rawOutput) {
        let [path, interfaceAndMember, ...message] = rawOutput.split(" ");

        return message.join(" ").replace(/^\([']?/, "") // starting ( or ('
        .replace(/[']?,\)$/, ""); // ending ,) or ',)
    }

    RunCommand {
        id: runCommand
    }

    function cleanup() {
        if (instanceId) {
            runCommand.exec(`ps -axo pid,cmd | grep '${root.monitorCmd.replace(/"/g, '')}$' | grep -v grep | awk '{print $1}' | xargs kill`, () => {
                root.disabled();
            });
        }
    }

    function toggleMonitor() {
        if (enabled) {
            start();
        } else {
            cleanup();
        }
    }

    function start() {
        runCommand.exec(root.monitorCmd, o => {
            // exit code 130 indicates received signal from the script
            if (o.exitCode === 130) {
                root.signalReceived(root.getMessage(o.stdout.trim()));
                // restart for the next signal
                // for some reason it won't restart without a delay???
                Utils.delay(50, () => {
                    root.start();
                }, root);
            }
        });
    }

    Component.onCompleted: {
        if (enabled) {
            start();
        }
        root.enabledChanged.connect(() => {
            root.toggleMonitor();
        });
    }

    Component.onDestruction: cleanup()
    Connections {
        target: Qt.application
        function onAboutToQuit() {
            root.cleanup();
        }
    }
}

import QtQuick
import org.kde.plasma.plasmoid


Item {

    id: root
    property bool enabled: false
    property string preset: ""
    property string propertyToApply: ""
    property bool switchIsPending: false
    property int poolingRate: 250

    property string toolsDir: Qt.resolvedUrl("./tools").toString().substring(7) + "/"
    property string serviceUtil: toolsDir+"service.py"
    property string pythonExecutable: plasmoid.configuration.pythonExecutable
    property string serviceCmd: pythonExecutable + " '" + serviceUtil + "' " + Plasmoid.containment.id + " " + Plasmoid.id
    property string quitServiceCmd: gdbusPartial +".quit"

    readonly property string service: Plasmoid.metaData.pluginId + ".c" + Plasmoid.containment.id + ".w" + Plasmoid.id
    readonly property string path: "/preset"

    function setPreset(reply) {
        if (reply?.value) {
            // console.log("preset", reply.value)
            preset = reply.value
        }
    }

    function setProperty(reply) {
        if (reply?.value) {
            // console.log("property", reply.value)
            propertyToApply = reply.value
        }
    }

    DBusMethodCall {
        id: dbusGetPreset
        service: root.service
        objectPath: "/preset"
        iface: root.service
        method: "preset"
        arguments: []
        signature: "s"
    }

    DBusMethodCall {
        id: dbusGetProperty
        service: root.service
        objectPath: "/preset"
        iface: root.service
        method: "property"
        arguments: []
        signature: "s"
    }

    DBusMethodCall {
        id: dbusQuit
        service: root.service
        objectPath: "/preset"
        iface: root.service
        method: "quit"
        arguments: []
    }

    RunCommand {
        id: runCommand
        onExited: (cmd, exitCode, exitStatus, stdout, stderr) => {
            if (exitCode !== 0) {
                console.error(cmd, exitCode, exitStatus, stdout, stderr)
            }
        }
    }

    Component.onCompleted: {
        toggleService()
    }

    function toggleService() {
        if (enabled) {
            runCommand.run(serviceCmd)
        } else (
            dbusQuit.call()
        )
    }

    onEnabledChanged: toggleService()

    Timer {
        id: updateTimer
        interval: root.poolingRate
        running: root.enabled
        repeat: true
        onTriggered: {
            dbusGetPreset.call(root.setPreset)
            dbusGetProperty.call(root.setProperty)
        }
    }
}


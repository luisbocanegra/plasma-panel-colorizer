import QtQuick
import org.kde.plasma.plasmoid


Item {

    id: root
    property bool enabled: false
    property string preset: ""
    property bool switchIsPending: false
    property int poolingRate: 250

    property string toolsDir: Qt.resolvedUrl("./tools").toString().substring(7) + "/"
    property string serviceUtil: toolsDir+"service.py"
    property string pythonExecutable: plasmoid.configuration.pythonExecutable
    property string serviceCmd: pythonExecutable + " '" + serviceUtil + "' " + Plasmoid.containment.id + " " + Plasmoid.id
    property string dbusName: Plasmoid.metaData.pluginId + ".c" + Plasmoid.containment.id + ".w" + Plasmoid.id
    property string gdbusPartial: "gdbus call --session --dest "+dbusName+" --object-path /preset --method "+dbusName
    property string pendingSwitchCmd: gdbusPartial +".pending_switch"
    property string switchDoneCmd: gdbusPartial +".switch_done"
    property string getPresetCmd: gdbusPartial +".preset"
    property string quitServiceCmd: gdbusPartial +".quit"

    RunCommand {
        id: runCommand
        onExited: (cmd, exitCode, exitStatus, stdout, stderr) => {
            // console.error(cmd, exitCode, exitStatus, stdout, stderr)
            if (exitCode!==0) return
            stdout = stdout.trim().replace(/[()',]/g, "")
            // console.log("stdout parsed:", stdout)
            if(cmd === pendingSwitchCmd) {
                switchIsPending = stdout === "true"
            }
            if (cmd === getPresetCmd) {
                preset = stdout
                switchIsPending = false
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
            runCommand.run(quitServiceCmd)
        )
    }

    onEnabledChanged: toggleService()

    onSwitchIsPendingChanged: {
        if (switchIsPending) {
            runCommand.run(switchDoneCmd)
            runCommand.run(getPresetCmd)
        }
    }

    Timer {
        id: updateTimer
        interval: poolingRate
        running: enabled
        repeat: true
        onTriggered: {
            if (switchIsPending) return
            runCommand.run(pendingSwitchCmd)
        }
    }
}


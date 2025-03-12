import QtQuick
import org.kde.plasma.plasmoid

Item {
    id: root

    property bool enabled: false
    property string toolsDir: Qt.resolvedUrl("./tools").toString().substring(7) + "/"
    property string serviceUtil: toolsDir + "service.py"
    property string pythonExecutable: plasmoid.configuration.pythonExecutable
    property string serviceCmd: pythonExecutable + " '" + serviceUtil + "' " + Plasmoid.containment.id + " " + Plasmoid.id
    readonly property string service: Plasmoid.metaData.pluginId + ".c" + Plasmoid.containment.id + ".w" + Plasmoid.id
    readonly property string path: "/preset"

    function toggleService() {
        if (enabled)
            runCommand.run(serviceCmd);
        else
            (dbusQuit.call());
    }

    onEnabledChanged: toggleService()
    Component.onCompleted: toggleService()

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
            if (exitCode !== 0)
                console.error(cmd, exitCode, exitStatus, stdout, stderr);
        }
    }
}

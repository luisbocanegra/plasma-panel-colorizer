import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import org.kde.plasma.plasma5support as P5Support

KCM.SimpleKCM {
    id:root
    property int slotCount: 0
    property string presetsDir: StandardPaths.writableLocation(
                    StandardPaths.HomeLocation).toString().substring(7) + "/.config/panel-colorizer/"
    property string cratePresetsDirCmd: "mkdir -p " + presetsDir
    property string listPresetsCmd: "find "+presetsDir+" -type f -print0 | while IFS= read -r -d '' file; do basename \"$file\"; done | sort"
    property var presets: []
    property var presetContent: ""
    property string lastPreset
    property string editingPreset

    property alias cfg_normalPreset: normalPreset.currentIndex
    property alias cfg_floatingPreset: floatingPreset.currentIndex
    property alias cfg_maximizedPreset: maximizedPreset.currentIndex

    property var ignoredConfigs: [
        "panelWidgetsWithTray",
        "panelWidgets",
        "objectName",
        "lastPreset",
        "floatingPreset",
        "normalPreset",
        "maximizedPreset"
    ]

    ListModel {
        id: presetsModel
    }

    P5Support.DataSource {
        id: runCommand
        engine: "executable"
        connectedSources: []

        onNewData: function (source, data) {
            var exitCode = data["exit code"]
            var exitStatus = data["exit status"]
            var stdout = data["stdout"]
            var stderr = data["stderr"]
            exited(source, exitCode, exitStatus, stdout, stderr)
            disconnectSource(source) // cmd finished
        }

        function exec(cmd) {
            runCommand.connectSource(cmd)
        }

        signal exited(string cmd, int exitCode, int exitStatus, string stdout, string stderr)
    }

    Connections {
        target: runCommand
        function onExited(cmd, exitCode, exitStatus, stdout, stderr) {
            // console.log(cmd);
            if (exitCode!==0) return
            // console.log(stdout);
            if(cmd === listPresetsCmd) {
                if (stdout.length > 0) {
                    presetsModel.append(
                        {
                            "name": i18n("Do nothing"),
                        }
                    )
                    presets = stdout.trim().split("\n")
                    for (let i = 0; i < presets.length; i++) {
                        presets[i]
                        presetsModel.append(
                            {
                                "name": presets[i],
                            }
                        )
                    }
                } else {
                    presets = []
                }
            }
            if (cmd.startsWith("cat")) {
                presetContent = stdout.trim().split("\n")
            }
        }
    }

    function parseValues(value) {
        if (typeof value === 'boolean') {
            return value;
        }

        if (value === 'true' || value === 'false') {
            return value === 'true';
        }

        const numericValue = parseFloat(value);
        if (!isNaN(numericValue)) {
            return numericValue;
        }

        return value;
    }

    Kirigami.PromptDialog {
        id: deletePresetDialog
        title: "Delete preset '"+editingPreset+"?"
        subtitle: i18n("This will permanently delete the file from your system!")
        standardButtons: Kirigami.Dialog.Ok | Kirigami.Dialog.Cancel
        onAccepted: {
            deletePreset(editingPreset)
            runCommand.exec(listPresetsCmd)
        }
    }

    Kirigami.PromptDialog {
        id: updatePresetDialog
        title: "Update preset '"+editingPreset+"'?"
        subtitle: i18n("Preset configuration will be overwritten!")
        standardButtons: Kirigami.Dialog.Ok | Kirigami.Dialog.Cancel
        onAccepted: {
            savePreset(editingPreset)
            runCommand.exec(listPresetsCmd)
        }
    }

    Kirigami.PromptDialog {
        id: newPresetDialog
        title: "Create preset '"+editingPreset+"'?"
        subtitle: i18n("Any existing preset with the same name will be overwritten!")
        standardButtons: Kirigami.Dialog.Ok | Kirigami.Dialog.Cancel
        onAccepted: {
            savePreset(editingPreset)
            runCommand.exec(listPresetsCmd)
            saveNameField.text = ""
        }
    }

    function applyPreset(filename) {
        console.log("Reading preset:", filename);
        runCommand.exec("cat '" + presetsDir + filename+"'")
        loadPresetTimer.start()
    }

    Timer {
        id: loadPresetTimer
        interval: 500
        onTriggered: {
            loadPreset(presetContent)
        }
    }

    function loadPreset() {
        console.log("Loading preset contents...");
        for (let i in presetContent) {
            const line = presetContent[i]
            if (line.includes("=")) {
                const parts = line.split("=")
                const key = parts[0]
                const val = parts[1]
                const cfgKey = "cfg_" + key;
                if (ignoredConfigs.some(function (k) { return key.includes(k)})) continue
                // console.log(key, val);
                root[cfgKey] = parseValues(val)
            }
        }
    }

    function restoreSettings() {
        console.log("Restoring default configuration");
        var config = plasmoid.configuration
        for (var key of Object.keys(config)) {
            if (typeof config[key] === "function") continue
            if (key.endsWith("Default")) {
                let newName = key.slice(0, -7)
                const cfgKey = "cfg_" + newName;
                if (ignoredConfigs.some(function (k) { return key.includes(k)})) continue
                root[cfgKey] = config[key]
            }
        }
        lastPreset = ""
    }

    function savePreset(filename) {
        console.log("Saving preset ", filename);
        var config = plasmoid.configuration
        var output = ""
        for (var k of Object.keys(config)) {
            if (typeof config[k] === "function") continue
            if (k.endsWith("Default")) {
                let name = k.slice(0, -7)
                output += name+"="+config[name] + "\n"
                // output += k+"="+config[k] + "\n"
            }
        }
        runCommand.exec("echo '" + output + "' > '" + presetsDir + filename + "'")
    }

    function deletePreset(filename) {
        console.error("rm '" + presetsDir + filename + "'" );
        runCommand.exec("rm '" + presetsDir + filename + "'" )
    }

    function dumpProps(obj) {
        console.error("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
        for (var k of Object.keys(obj)) {
            print(k + "=" + obj[k]+"\n")
        }
    }

    Component.onCompleted: {
        runCommand.exec(cratePresetsDirCmd)
        runCommand.exec(listPresetsCmd)
    }

    header: RowLayout {
        RowLayout {
            Layout.leftMargin: Kirigami.Units.mediumSpacing
            Layout.rightMargin: Kirigami.Units.smallSpacing
            Item {
                Layout.fillWidth: true
            }
            RowLayout {
                Layout.alignment: Qt.AlignRight
                Label {
                    text: i18n("Last preset loaded:")
                }
                Label {
                    text: plasmoid.configuration.lastPreset || "None"
                    font.weight: Font.DemiBold
                }
            }
        }
    }

    ColumnLayout {
        Kirigami.FormLayout {
            ComboBox {
                id: normalPreset
                Kirigami.FormData.label: i18n("Normal:")
                model: presetsModel
                textRole: "name"
            }
            ComboBox {
                id: floatingPreset
                Kirigami.FormData.label: i18n("Floating panel:")
                model: presetsModel
                textRole: "name"
                enabled: cfg_maximizedPreset === 0
            }
            ComboBox {
                id: maximizedPreset
                Kirigami.FormData.label: i18n("Maximized window is shown:")
                model: presetsModel
                textRole: "name"
                enabled: cfg_floatingPreset === 0
            }
        }
    }
}

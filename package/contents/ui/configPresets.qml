import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import org.kde.plasma.plasma5support as P5Support

import "components" as Components
import "code/utils.js" as Utils
import "code/globals.js" as Globals

KCM.SimpleKCM {
    id:root
    property string presetsDir: StandardPaths.writableLocation(
                    StandardPaths.HomeLocation).toString().substring(7) + "/.config/panel-colorizer/presets/"
    property string cratePresetsDirCmd: "mkdir -p '" + presetsDir + "'"
    property string presetsBuiltinDir: Qt.resolvedUrl("./presets").toString().substring(7) + "/"
    property string toolsDir: Qt.resolvedUrl("./tools").toString().substring(7) + "/"
    property string listUserPresetsCmd: "'" + toolsDir + "list_presets.sh' '" + presetsDir + "'"
    property string listBuiltinPresetsCmd: "'" + toolsDir + "list_presets.sh' '" + presetsBuiltinDir + "'"
    property string listPresetsCmd: listBuiltinPresetsCmd+";"+listUserPresetsCmd
    property string spectaclePreviewCmd: "spectacle -bn -r -o "
    property var presets: ({})
    property var presetContent: ""

    property string editingPreset
    property string cfg_globalSettings
    property string cfg_lastPreset
    property string lastPreset
    property alias cfg_isEnabled: headerComponent.isEnabled

    Connections {
        target: plasmoid.configuration
        onValueChanged: {
            plasmoid.configuration.lastPreset = lastPreset
            plasmoid.configuration.writeConfig();
        }
    }

    RunCommand {
        id: runCommand
    }

    signal refreshImage(editingPreset: string)

    signal reloadPresetList()

    onReloadPresetList: {
        runCommand.run(listPresetsCmd)
    }

    Connections {
        target: runCommand
        function onExited(cmd, exitCode, exitStatus, stdout, stderr) {
            if (exitCode!==0) return
            if(cmd === listPresetsCmd) {
                presets = ({})
                if (stdout.length === 0) return
                const out = stdout.trim().split("\n")
                var tmp = {}
                for (const line of out) {
                    let builtin = false
                    const parts = line.split(":")
                    const path = parts[parts.length -1]
                    let name = path.split("/")
                    name = name[name.length-1]
                    if (line.startsWith("b:")) {
                        builtin = true
                    }
                    console.error(parts[1])
                    tmp[name] = {"dir": parts[1], "builtin": builtin}
                }
                presets = tmp
            }
            if (cmd.startsWith("cat")) {
                presetContent = JSON.parse(stdout.trim())
                Utils.loadPreset(presetContent, root, Globals.ignoredConfigs, Globals.defaultConfig, false)
            }
            if (cmd.startsWith("echo")) {
                reloadPresetList()
            }
        }
    }

    Kirigami.PromptDialog {
        id: deletePresetDialog
        title: "Delete preset '"+editingPreset+"?"
        subtitle: i18n("This will permanently delete the file from your system!")
        standardButtons: Kirigami.Dialog.Ok | Kirigami.Dialog.Cancel
        onAccepted: {
            deletePreset(editingPreset)
            runCommand.run(listPresetsCmd)
        }
    }

    Kirigami.PromptDialog {
        id: updatePresetDialog
        title: "Update preset '"+editingPreset+"'?"
        subtitle: i18n("Preset configuration will be overwritten!")
        standardButtons: Kirigami.Dialog.Ok | Kirigami.Dialog.Cancel
        onAccepted: {
            savePreset(editingPreset)
        }
    }

    Kirigami.PromptDialog {
        id: newPresetDialog
        title: "Create preset '"+editingPreset+"'?"
        standardButtons: Kirigami.Dialog.Ok | Kirigami.Dialog.Cancel
        onAccepted: {
            savePreset(editingPreset)
            runCommand.run(listPresetsCmd)
            saveNameField.text = ""
        }
    }

    function applyPreset(presetDir) {
        console.log("Reading preset:", presetDir);
        runCommand.run("cat '" + presetDir + "/settings.json'")
    }

    function restoreSettings() {
        console.log("Restoring default configuration");
        cfg_globalSettings = JSON.stringify(Globals.defaultConfig, null, null)
    }

    function savePreset(presetDir) {
        console.log("Saving preset ", presetDir);
        var config = plasmoid.configuration
        var output = {}
        for (var key of Object.keys(config)) {
            if (typeof config[key] === "function") continue
            if (key.endsWith("Default")) {
                if (Globals.ignoredConfigs.some(
                    function (k) {return key.includes(k) }
                )) continue
                let name = key.slice(0, -7)
                let val = config[name]
                let parsed = JSON.parse(val)
                if (name === "globalSettings") {
                    val = Utils.mergeConfigs(Globals.defaultConfig, parsed)
                } else {
                    parsed
                }
                output[name] = parsed
            }
        }
        runCommand.run("mkdir -p '"+presetDir+"'")
        runCommand.run("echo '" + JSON.stringify(output) + "' > '" + presetDir + "/settings.json' && " +
            spectaclePreviewCmd+"'" + presetDir + "/preview.png'"
        )
    }

    function deletePreset(path) {
        if (!path.includes("panel-colorizer/presets/")
        || path.includes("/ ") || path.includes(" /") || path.endsWith(" ")
        || path.includes("..")
        ) {
            console.error(`Detected unsafe deletion of '${path}' aborting.`)
            return
        }
        console.error("rm -r '" + path + "'" )
        runCommand.run("rm -r '" + path + "'" )
    }

    Component.onCompleted: {
        runCommand.run(cratePresetsDirCmd)
        runCommand.run(listPresetsCmd)
    }

    header: ColumnLayout {
        Components.Header {
            id: headerComponent
            Layout.leftMargin: Kirigami.Units.mediumSpacing
            Layout.rightMargin: Kirigami.Units.mediumSpacing
        }
    }

    ColumnLayout {
        Kirigami.FormLayout {
            enabled: cfg_isEnabled
            RowLayout {
                Layout.preferredWidth: presetCards.width
                Layout.minimumWidth: 300
                Button {
                    text: i18n("Restore default panel appearance")
                    icon.name: "kt-restore-defaults-symbolic"
                    onClicked: {
                        restoreSettings()
                    }
                    Layout.fillWidth: true
                }
            }

            RowLayout {
                Layout.preferredWidth: presetCards.width
                Layout.minimumWidth: 300
                TextField {
                    id: saveNameField
                    Layout.fillWidth: true
                    placeholderText: i18n("New from current settings")
                    validator: RegularExpressionValidator {
                        regularExpression: /^(?![\s\.])([a-zA-Z0-9. _\-]+)(?<![\.|\s])$/
                    }
                }
                Button {
                    icon.name: "document-save-symbolic"
                    text: i18n("Save")
                    enabled: saveNameField.acceptableInput && !(Object.keys(presets).includes(saveNameField.text))
                    onClicked: {
                        editingPreset = presetsDir+saveNameField.text
                        newPresetDialog.open()
                    }
                }
            }

            ColumnLayout {
                id: presetCards
                Layout.minimumWidth: 500
                RowLayout {
                    Layout.preferredWidth: presetCards.width
                    Button {
                        Layout.fillWidth: true
                        text: i18n("Refresh presets")
                        icon.name: "view-refresh-symbolic"
                        onClicked: {
                            runCommand.run(listPresetsCmd)
                        }
                    }
                }
                Repeater {
                    model: Object.keys(presets)
                    delegate: Kirigami.AbstractCard {
                        contentItem: ColumnLayout {
                            RowLayout {
                                Label {
                                    text: (parseInt(index)+1).toString()+"."
                                    font.bold: true
                                }
                                Label {
                                    text: modelData
                                    elide: Text.ElideRight
                                }

                                Rectangle {
                                    visible: presets[modelData].builtin
                                    color: Kirigami.Theme.highlightColor
                                    Kirigami.Theme.colorSet: root.Kirigami.Theme["Selection"]
                                    radius: parent.height / 2
                                    width: label.width + 12
                                    height: label.height + 2
                                    Kirigami.Theme.inherit: false
                                    Label {
                                        anchors.centerIn: parent
                                        id: label
                                        text: i18n("Built-in")
                                        color: Kirigami.Theme.textColor
                                        Kirigami.Theme.colorSet: root.Kirigami.Theme["Selection"]
                                        Kirigami.Theme.inherit: false
                                    }
                                }

                                Item {
                                    Layout.fillWidth: true
                                }

                                Button {
                                    id: loadBtn
                                    text: i18n("Load")
                                    Layout.preferredHeight: saveBtn.height
                                    onClicked: {
                                        lastPreset = presets[modelData].dir
                                        applyPreset(lastPreset)
                                    }
                                }
                                Button {
                                    id: saveBtn
                                    icon.name: "document-save-symbolic"
                                    text: i18n("Update")
                                    onClicked: {
                                        editingPreset = presets[modelData].dir
                                        updatePresetDialog.open()
                                    }
                                    visible: !presets[modelData].builtin
                                }
                                Button {
                                    text: i18n("Delete")
                                    icon.name: "edit-delete-remove-symbolic"
                                    onClicked: {
                                        editingPreset = presets[modelData].dir
                                        onClicked: deletePresetDialog.open()
                                    }
                                    visible: !presets[modelData].builtin
                                }
                            }

                            ScrollView {
                                Layout.preferredWidth: 500
                                Layout.maximumHeight: 100
                                id: scrollView
                                visible: false
                                Image {
                                    id: image
                                    onStatusChanged: if (image.status == Image.Ready) {
                                        scrollView.visible = true
                                        scrollView.height = sourceSize.height
                                    } else {
                                        scrollView.visible = false
                                    }
                                    source: presets[modelData].dir+"/preview.png"
                                    fillMode: Image.PreserveAspectCrop
                                    horizontalAlignment: Image.AlignLeft
                                    cache: false
                                    asynchronous: true
                                    function refresh(presetName) {
                                        // only refresh preview of the changed preset
                                        if (presetName !== presets[modelData].dir) return
                                        source = ""
                                        source = presets[modelData].dir+"/preview.png"
                                    }
                                    Component.onCompleted: {
                                        root.refreshImage.connect(refresh)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}


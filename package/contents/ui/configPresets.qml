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
    property string cratePresetsDirCmd: "mkdir -p " + presetsDir
    property string listPresetsCmd: "find "+presetsDir+" -mindepth 1 -prune -type d -print0 | while IFS= read -r -d '' preset; do basename \"$preset\"; done | sort"
    property string spectaclePreviewCmd: "spectacle -bn -r -o "
    property var presets: []
    property var presetContent: ""

    property string editingPreset
    property string cfg_globalSettings
    property string cfg_lastPreset
    property string lastPreset
    property alias cfg_isEnabled: headerComponent.isEnabled

    Connections {
        target: plasmoid.configuration
        onValueChanged: {
            cfg_lastPreset = lastPreset
        }
    }

    RunCommand {
        id: runCommand
    }

    signal refreshImage(editingPreset: string)

    Connections {
        target: runCommand
        function onExited(cmd, exitCode, exitStatus, stdout, stderr) {
            if (exitCode!==0) return
            if(cmd === listPresetsCmd) {
                if (stdout.length > 0) {
                    presets = stdout.trim().split("\n")
                } else {
                    presets = []
                }
            }
            if (cmd.startsWith("cat")) {
                presetContent = JSON.parse(stdout.trim())
                Utils.loadPreset(presetContent, root, Globals.ignoredConfigs, Globals.defaultConfig, false)
            }
            if (cmd.startsWith("spectacle")) {
                refreshImage(editingPreset)
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
            runCommand.run(listPresetsCmd)
        }
    }

    Kirigami.PromptDialog {
        id: newPresetDialog
        title: "Create preset '"+editingPreset+"'?"
        subtitle: i18n("Any existing preset with the same name will be overwritten!")
        standardButtons: Kirigami.Dialog.Ok | Kirigami.Dialog.Cancel
        onAccepted: {
            savePreset(editingPreset)
            runCommand.run(listPresetsCmd)
            saveNameField.text = ""
        }
    }

    function applyPreset(presetName) {
        console.log("Reading preset:", presetName, presetsDir + presetName);
        runCommand.run("cat '" + presetsDir + presetName+"/settings.json'")
    }

    function restoreSettings() {
        console.log("Restoring default configuration");
        cfg_globalSettings = JSON.stringify(Globals.defaultConfig, null, null)
    }

    function savePreset(presetName) {
        console.log("Saving preset ", presetName);
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
        runCommand.run(cratePresetsDirCmd+presetName)
        runCommand.run("echo '" + JSON.stringify(output) + "' > '" + presetsDir + presetName + "/settings.json'")
        runCommand.run(spectaclePreviewCmd+"'" + presetsDir + presetName + "/preview.png'")
    }

    function deletePreset(presetName) {
        if (!presetsDir.includes("panel-colorizer/presets/")) {
            console.error("Unsafe deletion, aborting.")
        }
        console.error("rm -r '" + presetsDir + presetName + "'" )
        runCommand.run("rm -r '" + presetsDir + presetName + "'" )
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
                    enabled: saveNameField.acceptableInput
                    onClicked: {
                        editingPreset = saveNameField.text
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
                    model: presets
                    delegate: Kirigami.AbstractCard {
                        contentItem: ColumnLayout {
                            RowLayout {
                                Label {
                                    text: (parseInt(index)+1).toString()+"."
                                    font.bold: true
                                }
                                ColumnLayout {
                                    Label {
                                        text: modelData
                                        elide: Text.ElideRight
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
                                        lastPreset = modelData
                                        applyPreset(lastPreset)
                                    }
                                }
                                Button {
                                    id: saveBtn
                                    icon.name: "document-save-symbolic"
                                    text: i18n("Update")
                                    onClicked: {
                                        editingPreset = modelData
                                        updatePresetDialog.open()
                                    }
                                }
                                Button {
                                    text: i18n("Delete")
                                    icon.name: "edit-delete-remove-symbolic"
                                    onClicked: {
                                        editingPreset = modelData
                                        onClicked: deletePresetDialog.open()
                                    }
                                }
                            }
                            RowLayout {
                                Rectangle {
                                    color: "transparent"
                                    // width: scrollView.width
                                    // height: scrollView.height
                                    border {
                                        width: 1
                                        color: Qt.rgba(0.5,0.5,0.5, 0.3)
                                    }
                                    Layout.preferredWidth: 500
                                    Layout.preferredHeight: 100
                                    ScrollView {
                                        id: scrollView
                                        width: parent.width-2
                                        height: parent.height-2
                                        anchors.centerIn: parent
                                        Image {
                                            source: presetsDir+modelData+"/preview.png"
                                            fillMode: Image.PreserveAspectCrop
                                            horizontalAlignment: Image.AlignLeft
                                            cache: false
                                            asynchronous: true
                                            function refresh(presetName) {
                                                // only refresh preview of the changed preset
                                                if (presetName !== modelData) return
                                                source = ""
                                                source = presetsDir+modelData+"/preview.png"
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
    }
}

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
    property bool cfg_isEnabled: isEnabled.checked
    property bool cfg_hideWidget: hideWidget.checked
    property int slotCount: 0
    property string presetsDir: StandardPaths.writableLocation(
                    StandardPaths.HomeLocation).toString().substring(7) + "/.config/panel-colorizer/"
    property string cratePresetsDirCmd: "mkdir -p " + presetsDir
    property string listPresetsCmd: "find "+presetsDir+" -type f -print0 | while IFS= read -r -d '' file; do basename \"$file\"; done | sort"
    property var presets: []
    property var presetContent: ""

    property bool cfg_widgetBgEnabled
    property int cfg_mode
    property int cfg_colorMode
    property string cfg_singleColor
    property string cfg_customColors
    property real cfg_opacity
    property int cfg_radius
    property bool cfg_bgContrastFixEnabled
    property bool cfg_bgSaturationEnabled
    property real cfg_bgSaturation
    property real cfg_bgLightness
    property int cfg_rainbowInterval
    property int cfg_rainbowTransition
    property string cfg_widgetOutlineColor
    property int cfg_widgetOutlineWidth
    property string cfg_widgetShadowColor
    property int cfg_widgetShadowSize
    property int cfg_widgetShadowX
    property int cfg_widgetShadowY
    property string cfg_blacklist
    property int cfg_widgetBgVMargin
    property int cfg_widgetBgHMargin
    property string cfg_marginRules
    property bool cfg_fgColorEnabled
    property int cfg_fgMode
    property int cfg_fgColorMode
    property string cfg_fgSingleColor
    property string cfg_fgCustomColors
    property string cfg_blacklistedFgColor
    property int cfg_fgRainbowInterval
    property int cfg_fgRainbowTransition
    property bool cfg_fgBlacklistedColorEnabled
    property real cfg_fgOpacity
    property bool cfg_fgContrastFixEnabled
    property bool cfg_fgSaturationEnabled
    property real cfg_fgSaturation
    property real cfg_fgLightness
    property bool cfg_enableCustomPadding
    property int cfg_panelPadding
    property bool cfg_panelBgEnabled
    property string cfg_panelBgColor
    property bool cfg_hideRealPanelBg
    property real cfg_panelBgOpacity
    property int cfg_panelBgRadius
    property string cfg_forceRecolor
    property real cfg_panelRealBgOpacity
    property string cfg_panelOutlineColor
    property int cfg_panelOutlineWidth
    property string cfg_panelShadowColor
    property int cfg_panelShadowSize
    property int cfg_panelShadowX
    property int cfg_panelShadowY
    property string cfg_panelWidgets
    property string cfg_panelWidgetsWithTray
    property bool cfg_bgLineModeEnabled
    property int cfg_bgLinePosition
    property int cfg_bgLineWidth
    property int cfg_bgLineXOffset
    property int cfg_bgLineYOffset

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
                    presets = stdout.trim().split("\n")
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
        const ignoredConfigs = ["panelWidgetsWithTray", "panelWidgets", "objectName"]
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
        console.log("Restoring default settings");
        var config = plasmoid.configuration
        const ignoredConfigs = ["panelWidgetsWithTray", "panelWidgets", "objectName"]
        for (var key of Object.keys(config)) {
            if (typeof config[key] === "function") continue
            if (key.endsWith("Default")) {
                let newName = key.slice(0, -7)
                const cfgKey = "cfg_" + newName;
                if (ignoredConfigs.some(function (k) { return key.includes(k)})) continue
                root[cfgKey] = config[key]
            }
        }
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

    Component.onCompleted: {
        runCommand.exec(cratePresetsDirCmd)
        runCommand.exec(listPresetsCmd)
    }

    Kirigami.FormLayout {

        CheckBox {
            Kirigami.FormData.label: i18n("Enabled:")
            id: isEnabled
            checked: cfg_isEnabled
            onCheckedChanged: cfg_isEnabled = checked
        }

        CheckBox {
            Kirigami.FormData.label: i18n("Hide widget:")
            id: hideWidget
            checked: cfg_hideWidget
            onCheckedChanged: cfg_hideWidget = checked
        }

        Label {
            text: i18n("Widget will show when configuring or panel Edit Mode")
            opacity: 0.7
            Layout.maximumWidth: 300
            wrapMode: Text.Wrap
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Presets")
        }

        RowLayout {
            Layout.preferredWidth: presetCards.width
            Layout.minimumWidth: 300
            Button {
                text: i18n("Restore defaults")
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
                placeholderText: i18n("New preset name")
                validator: RegularExpressionValidator {
                    regularExpression: /^(?![\s\.])([a-zA-Z0-9. _\-]+)(?<![\.|\s])$/
                }
            }
            Button {
                icon.name: "document-save-symbolic"
                text: i18n("Save")
                enabled: saveNameField.acceptableInput
                onClicked: {
                    savePreset(saveNameField.text)
                    runCommand.exec(listPresetsCmd)
                    saveNameField.text = ""
                }
            }
            
        }

        ColumnLayout {
            id: presetCards
            Layout.minimumWidth: 400
            Label {
                text: i18n("Presets")
                font.bold: true
            }
            RowLayout {
                Layout.preferredWidth: presetCards.width
                Button {
                    Layout.fillWidth: true
                    text: i18n("Refresh")
                    icon.name: "view-refresh-symbolic"
                    onClicked: {
                        runCommand.exec(listPresetsCmd)
                    }
                }
            }
            Repeater {
                model: presets
                delegate: Kirigami.AbstractCard {
                    contentItem: RowLayout {
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
                            icon.name: "document-save-symbolic"
                            text: i18n("Update")
                            onClicked: {
                                if (modelData.length > 0) {
                                    savePreset(modelData)
                                }
                            }
                        }
                        
                        Button {
                            text: i18n("Apply")
                            icon.name: "checkmark-symbolic"
                            onClicked: {
                                applyPreset(modelData)
                            }
                        }
                        Button {
                            text: i18n("Delete")
                            icon.name: "edit-delete-remove-symbolic"
                            onClicked: {
                                deletePreset(modelData)
                                runCommand.exec(listPresetsCmd)
                            }
                        }
                    }
                }
            }
        }
    }
}

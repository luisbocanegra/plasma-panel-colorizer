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
    property string presetsDir: StandardPaths.writableLocation(
                    StandardPaths.HomeLocation).toString().substring(7) + "/.config/panel-colorizer/"
    property string cratePresetsDirCmd: "mkdir -p " + presetsDir
    property string listPresetsCmd: "find "+presetsDir+" -type f -print0 | while IFS= read -r -d '' file; do basename \"$file\"; done | sort"
    property var presets: []
    property var presetContent: ""
    property var ignoredConfigs: [
        "panelWidgetsWithTray",
        "panelWidgets",
        "objectName",
        "lastPreset",
        "floatingPreset",
        "normalPreset",
        "maximizedPreset"
    ]

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
    property string lastPreset
    property string cfg_lastPreset
    property string editingPreset
    property int cfg_colorModeTheme
    property int cfg_widgetOutlineColorMode
    property int cfg_widgetOutlineColorModeTheme
    property real cfg_widgetOutlineOpacity
    property int cfg_fgColorModeTheme
    property int cfg_fgBlacklistedColorMode
    property int cfg_fgBlacklistedColorModeTheme
    property int cfg_panelBgColorMode
    property int cfg_panelBgColorModeTheme
    property int cfg_panelOutlineColorMode
    property int cfg_panelOutlineColorModeTheme
    property real cfg_panelOutlineOpacity
    property int cfg_panelSpacing
    property bool cfg_fgShadowEnabled
    property string cfg_fgShadowColor
    property int cfg_fgShadowX
    property int cfg_fgShadowY
    property int cfg_fgShadowRadius
    property bool cfg_fixCustomBadges
    property int cfg_colorModeThemeVariant
    property int cfg_widgetOutlineColorModeThemeVariant
    property int cfg_fgColorModeThemeVariant
    property int cfg_panelBgColorModeThemeVariant
    property int cfg_panelOutlineColorModeThemeVariant

    Connections {
        target: plasmoid.configuration
        onValueChanged: {
            cfg_lastPreset = lastPreset
        }
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
            loadPreset()
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
        cfg_lastPreset = ""
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

    property Component widgetBgComponent: Kirigami.ShadowedRectangle {
        property var target // holds element with expanded property
        
        color: "red"
        height: parent.height
        width:  parent.width
        opacity: 0.5

    }

    Component.onCompleted: {
        runCommand.exec(cratePresetsDirCmd)
        runCommand.exec(listPresetsCmd)
    }

    header: RowLayout {
        RowLayout {
            Layout.leftMargin: Kirigami.Units.mediumSpacing
            Layout.rightMargin: Kirigami.Units.smallSpacing
            RowLayout {
                Layout.alignment: Qt.AlignRight
                Label {
                    text: i18n("Enable:")
                }
                CheckBox {
                    id: isEnabled
                    checked: cfg_isEnabled
                    onCheckedChanged: cfg_isEnabled = checked
                    text: checked ? "Enabled" : "⚠️ Disabled"
                }
            }
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
        RowLayout {
            Kirigami.FormData.label: i18n("Hide widget:")
            Kirigami.FormData.labelAlignment: Qt.AlignTop
            RowLayout {
            CheckBox {
                Layout.alignment: Qt.AlignTop
                id: hideWidget
                checked: cfg_hideWidget
                onCheckedChanged: cfg_hideWidget = checked
            }
            Label {
                Layout.alignment: Qt.AlignTop
                text: i18n("Widget will show when configuring or panel Edit Mode")
                opacity: 0.7
                wrapMode: Text.Wrap
                Layout.maximumWidth: 300
            }
            }
        }
    }

        Kirigami.FormLayout  {
            Item {
                Kirigami.FormData.isSection: true
                Kirigami.FormData.label: i18n("Presets")
            }
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
                            // text: i18n("Update")
                            onClicked: {
                                editingPreset = modelData
                                updatePresetDialog.open()
                            }
                        }
                        Button {
                            // text: i18n("Delete")
                            icon.name: "edit-delete-remove-symbolic"
                            onClicked: {
                                editingPreset = modelData
                                onClicked: deletePresetDialog.open()
                            }
                        }
                    }
                }
            }
        }
        }
    }
}

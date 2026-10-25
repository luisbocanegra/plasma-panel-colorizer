pragma ComponentBehavior: Bound
import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid

import "components" as Components
import "code/utils.js" as Utils
import "code/globals.js" as Globals

KCM.SimpleKCM {
    id: root
    property string presetsDir: StandardPaths.writableLocation(StandardPaths.HomeLocation).toString().substring(7) + "/.config/panel-colorizer/presets/"
    property string cratePresetsDirCmd: "mkdir -p '" + presetsDir + "'"
    property string presetsBuiltinDir: Qt.resolvedUrl("./presets").toString().substring(7) + "/"
    property string toolsDir: Qt.resolvedUrl("./tools").toString().substring(7) + "/"
    property string listUserPresetsCmd: "'" + toolsDir + "list_presets.sh' '" + presetsDir + "'"
    property string listBuiltinPresetsCmd: "'" + toolsDir + "list_presets.sh' '" + presetsBuiltinDir + "' b"
    property string listPresetsCmd: listBuiltinPresetsCmd + ";" + listUserPresetsCmd

    ListModel {
        id: presetListModel
        function presetExists(name) {
            for (let i = 0; i < count; i++) {
                if (get(i).name === name) {
                    return true;
                }
            }
            return false;
        }
    }

    property string editingPreset
    property string cfg_globalSettings
    property string cfg_lastPreset
    property string lastPreset
    property alias cfg_isEnabled: headerComponent.isEnabled

    Connections {
        target: plasmoid.configuration
        function onValueChanged() {
            plasmoid.configuration.lastPreset = root.lastPreset;
            plasmoid.configuration.writeConfig();
        }
    }

    RunCommand {
        id: runCommand
    }

    signal refreshImage(editingPreset: string)

    function reloadPresetList() {
        runCommand.exec(listPresetsCmd, o => {
            if (o.exitCode !== 0) {
                console.error(o.cmd, o.exitCode, o.stdout, o.stderr);
                return;
            }
            if (o.stdout.length === 0)
                return;
            const out = o.stdout.trim().split("\n");
            var tmp = [];
            presetListModel.clear();
            for (const line of out) {
                const parts = line.split(":");
                const builtin = parts[parts.length - 1] === "b";
                const path = parts.slice(0, parts.length - 2).join("");
                const name = path.split("/").pop();
                const hasPreview = parts[parts.length - 2] === "1";
                presetListModel.append({
                    name,
                    "dir": path,
                    hasPreview,
                    builtin
                });
            }
        });
    }

    Connections {
        target: runCommand
    }

    function createPreview(presetDir) {
        runCommand.exec(`spectacle -bn -r -o '${presetDir}/preview.png'`, output => {
            root.reloadPresetList();
        });
    }

    Kirigami.PromptDialog {
        id: deletePresetDialog
        title: i18n("Delete preset") + " '" + root.editingPreset + "'?"
        subtitle: i18n("This will permanently delete the file from your system!")
        standardButtons: Kirigami.Dialog.Ok | Kirigami.Dialog.Cancel
        onAccepted: {
            root.deletePreset(root.editingPreset);
            runCommand.exec(root.listPresetsCmd);
        }
    }

    Kirigami.PromptDialog {
        id: updatePresetDialog
        title: i18n("Update preset") + " '" + root.editingPreset + "'?"
        subtitle: i18n("Preset configuration will be overwritten!")
        standardButtons: Kirigami.Dialog.Ok | Kirigami.Dialog.Cancel
        onAccepted: {
            root.savePreset(root.editingPreset);
        }
    }

    Kirigami.PromptDialog {
        id: createPreviewDialog
        title: i18n("Create preset preview?")
        subtitle: i18n("Current preview will be overwritten!")
        standardButtons: Kirigami.Dialog.Ok | Kirigami.Dialog.Cancel
        onAccepted: {
            createPreview(root.editingPreset);
        }
    }

    Kirigami.PromptDialog {
        id: newPresetDialog
        title: i18n("Create preset") + " '" + saveNameField.text + "'?"
        standardButtons: Kirigami.Dialog.Ok | Kirigami.Dialog.Cancel
        onAccepted: {
            const isNew = true;
            root.savePreset(root.editingPreset, isNew);
            saveNameField.text = "";
        }
    }

    function applyPreset(presetDir) {
        console.log("Reading preset:", presetDir);
        runCommand.exec("cat '" + presetDir + "/settings.json'", output => {
            if (output.exitCode !== 0) {
                console.error(output.stderr || output.stdout);
                return;
            }
            Utils.loadPreset(JSON.parse(output.stdout.trim()), root, Globals.ignoredConfigs, Globals.defaultConfig, false);
        });
    }

    function restoreSettings() {
        console.log("Restoring default configuration");
        cfg_globalSettings = JSON.stringify(Globals.defaultConfig, null, null);
    }

    function savePreset(presetDir, isNew) {
        console.log("Saving preset ", presetDir);
        var config = plasmoid.configuration;
        var output = {};
        for (let key of Object.keys(config)) {
            if (typeof config[key] === "function")
                continue;
            if (key.endsWith("Default")) {
                if (Globals.ignoredConfigs.some(function (k) {
                    return key.includes(k);
                }))
                    continue;
                let name = key.slice(0, -7);
                let val = config[name];
                let parsed = JSON.parse(val);
                if (name === "globalSettings") {
                    val = Utils.mergeConfigs(Globals.defaultConfig, parsed);
                }
                output[name] = parsed;
            }
        }
        runCommand.exec(`mkdir -p '${presetDir}'`, result => {
            if (result.exitCode !== 0) {
                console.error(result.stderr || result.stdout);
                return;
            }
            Utils.writeFileChunked(presetDir + "/settings.json", JSON.stringify(output), null, runCommand, () => {
                createPreviewDialog.open();
                if (isNew) {
                    root.reloadPresetList();
                }
            });
        });
    }

    function deletePreset(path) {
        if (!path.includes("panel-colorizer/presets/") || path.includes("/ ") || path.includes(" /") || path.endsWith(" ") || path.includes("..")) {
            console.error(`Detected unsafe deletion of '${path}' aborting.`);
            return;
        }
        console.warn("rm -r '" + path + "'");
        runCommand.exec("rm -r '" + path + "'");
    }

    Component.onCompleted: {
        Utils.delay(100, () => {
            runCommand.exec(cratePresetsDirCmd);
            reloadPresetList();
        }, root);
    }

    header: ColumnLayout {
        Components.Header {
            id: headerComponent
        }
    }

    ColumnLayout {
        Kirigami.InlineMessage {
            Layout.fillWidth: true
            text: i18n("Changes to the current preset are not synced to disk automatically. You should come back to this tab and update it manually before switching to a different preset, otherwise unsaved preset settings will be lost when presets change!")
            visible: true
            type: Kirigami.MessageType.Information
        }
        Kirigami.FormLayout {
            enabled: root.cfg_isEnabled
            RowLayout {
                Layout.preferredWidth: presetCards.width
                Layout.minimumWidth: 300
                Button {
                    text: i18n("Restore default preset")
                    icon.name: "kt-restore-defaults-symbolic"
                    onClicked: {
                        root.restoreSettings();
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
                    enabled: saveNameField.acceptableInput && !presetListModel.presetExists(saveNameField.text)
                    onClicked: {
                        root.editingPreset = root.presetsDir + saveNameField.text;
                        newPresetDialog.open();
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
                            runCommand.exec(root.listPresetsCmd);
                        }
                    }
                }
                Repeater {
                    model: presetListModel
                    delegate: Kirigami.AbstractCard {
                        id: content
                        required property int index
                        required property string name
                        required property string dir
                        required property bool builtin
                        required property bool hasPreview
                        contentItem: ColumnLayout {
                            width: row.implicitWidth
                            height: row.implicitHeight + scrollView.implicitHeight
                            RowLayout {
                                id: row
                                Label {
                                    text: (parseInt(content.index) + 1) + "."
                                    font.bold: true
                                }
                                Label {
                                    text: content.name
                                    elide: Text.ElideRight
                                }

                                Rectangle {
                                    visible: content.builtin
                                    color: Kirigami.Theme.highlightColor
                                    Kirigami.Theme.colorSet: root.Kirigami.Theme["Selection"]
                                    radius: parent.height / 2
                                    implicitWidth: label.width + 12
                                    implicitHeight: label.height + 2
                                    Kirigami.Theme.inherit: false
                                    Label {
                                        id: label
                                        anchors.centerIn: parent
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
                                    icon.name: "dialog-ok-apply-symbolic"
                                    text: i18n("Load")
                                    Layout.preferredHeight: saveBtn.height
                                    onClicked: {
                                        root.lastPreset = content.dir;
                                        root.applyPreset(root.lastPreset);
                                    }
                                }
                                Button {
                                    id: saveBtn
                                    icon.name: "document-save-symbolic"
                                    text: i18n("Update")
                                    onClicked: {
                                        root.editingPreset = content.dir;
                                        updatePresetDialog.open();
                                    }
                                    visible: !content.builtin
                                }
                                Button {
                                    text: i18n("Delete")
                                    icon.name: "edit-delete-remove-symbolic"
                                    onClicked: {
                                        root.editingPreset = content.dir;
                                        deletePresetDialog.open();
                                    }
                                    visible: !content.builtin
                                }
                            }
                            Button {
                                text: i18n("Create preview")
                                icon.name: "insert-image-symbolic"
                                visible: !hasPreview
                                Layout.alignment: Qt.AlignHCenter
                                onClicked: createPreview(content.dir)
                            }
                            Item {
                                id: scrollView
                                // Layout.preferredWidth: 500
                                Layout.fillWidth: true
                                Layout.maximumHeight: 100
                                Layout.alignment: Qt.AlignHCenter
                                visible: false

                                Image {
                                    id: image
                                    anchors.centerIn: parent
                                    anchors.fill: parent
                                    onStatusChanged: if (image.status == Image.Ready) {
                                        scrollView.visible = true;
                                        scrollView.height = sourceSize.height;
                                    } else {
                                        scrollView.visible = false;
                                    }
                                    source: hasPreview ? content.dir + "/preview.png" : ""
                                    fillMode: Image.PreserveAspectFit
                                    horizontalAlignment: Image.AlignHCenter
                                    cache: false
                                    asynchronous: true
                                }
                                Button {
                                    id: btn
                                    visible: true
                                    text: i18n("Update preview")
                                    anchors.fill: parent
                                    icon.name: "edit-image-symbolic"
                                    enabled: !content.builtin
                                    onClicked: createPreview(content.dir)
                                    property bool showTooltip: false
                                    property bool hasPosition: tooltipX !== 0 && tooltipY !== 0
                                    property int tooltipX: 0
                                    property int tooltipY: 0
                                    ToolTip {
                                        text: i18n("Update preview")
                                        parent: btn
                                        visible: btn.showTooltip && btn.hasPosition
                                        x: btn.tooltipX - width / 2
                                        y: btn.tooltipY - height - 2
                                        delay: 1
                                    }
                                    background: Rectangle {
                                        anchors.fill: parent
                                        property color bgColor: parent.Kirigami.Theme.highlightColor
                                        color: Qt.rgba(bgColor.r, bgColor.g, bgColor.b, hoverHandler.hovered ? 0.6 : 0)

                                        HoverHandler {
                                            id: hoverHandler
                                            enabled: btn.enabled
                                            cursorShape: hovered ? Qt.PointingHandCursor : Qt.ArrowCursor
                                            onHoveredChanged: {
                                                if (hovered) {
                                                    btn.tooltipX = 0;
                                                    btn.tooltipY = 0;
                                                }
                                                btn.showTooltip = hovered;
                                                if (!hovered)
                                                    hoverTimer.stop();
                                            }
                                            onPointChanged: {
                                                hoverTimer.restart();
                                            }
                                        }
                                        TapHandler {
                                            enabled: !content.builtin
                                            onTapped: createPreview(content.dir)
                                        }
                                        Timer {
                                            id: hoverTimer
                                            interval: 500
                                            onTriggered: {
                                                btn.tooltipX = hoverHandler.point.position.x;
                                                btn.tooltipY = hoverHandler.point.position.y;
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

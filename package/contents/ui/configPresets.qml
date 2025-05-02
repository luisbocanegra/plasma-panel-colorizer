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
            plasmoid.configuration.lastPreset = root.lastPreset;
            plasmoid.configuration.writeConfig();
        }
    }

    RunCommand {
        id: runCommand
    }

    signal refreshImage(editingPreset: string)

    signal reloadPresetList

    onReloadPresetList: {
        runCommand.run(listPresetsCmd);
    }

    Connections {
        target: runCommand
        function onExited(cmd, exitCode, exitStatus, stdout, stderr) {
            if (exitCode !== 0) {
                console.error(cmd, exitCode, exitStatus, stdout, stderr);
                return;
            }
            if (cmd === root.listPresetsCmd) {
                root.presets = ({});
                if (stdout.length === 0)
                    return;
                const out = stdout.trim().split("\n");
                var tmp = {};
                for (const line of out) {
                    let builtin = false;
                    const parts = line.split(":");
                    const path = parts[parts.length - 1];
                    let name = path.split("/");
                    name = name[name.length - 1];
                    if (line.startsWith("b:")) {
                        builtin = true;
                    }
                    console.log("Found preset:", parts[1]);
                    tmp[name] = {
                        "dir": parts[1],
                        "builtin": builtin
                    };
                }
                root.presets = tmp;
            }
            if (cmd.startsWith("cat")) {
                root.presetContent = JSON.parse(stdout.trim());
                Utils.loadPreset(root.presetContent, root, Globals.ignoredConfigs, Globals.defaultConfig, false);
            }
            if (cmd.startsWith("echo")) {
                root.reloadPresetList();
                createPreviewDialog.open();
            }
            if (cmd.startsWith("spectacle")) {
                root.reloadPresetList();
            }
        }
    }

    Kirigami.PromptDialog {
        id: deletePresetDialog
        title: "Delete preset '" + root.editingPreset + "?"
        subtitle: i18n("This will permanently delete the file from your system!")
        standardButtons: Kirigami.Dialog.Ok | Kirigami.Dialog.Cancel
        onAccepted: {
            root.deletePreset(root.editingPreset);
            runCommand.run(root.listPresetsCmd);
        }
    }

    Kirigami.PromptDialog {
        id: updatePresetDialog
        title: "Update preset '" + root.editingPreset + "'?"
        subtitle: i18n("Preset configuration will be overwritten!")
        standardButtons: Kirigami.Dialog.Ok | Kirigami.Dialog.Cancel
        onAccepted: {
            root.savePreset(root.editingPreset);
        }
    }

    Kirigami.PromptDialog {
        id: createPreviewDialog
        title: "Create preview?"
        subtitle: i18n("Current preview will be overwritten!")
        standardButtons: Kirigami.Dialog.Ok | Kirigami.Dialog.Cancel
        onAccepted: {
            runCommand.run(root.spectaclePreviewCmd + "'" + root.editingPreset + "/preview.png'");
        }
    }

    Kirigami.PromptDialog {
        id: newPresetDialog
        title: "Create preset '" + root.editingPreset + "'?"
        standardButtons: Kirigami.Dialog.Ok | Kirigami.Dialog.Cancel
        onAccepted: {
            root.savePreset(root.editingPreset);
            saveNameField.text = "";
        }
    }

    function applyPreset(presetDir) {
        console.log("Reading preset:", presetDir);
        runCommand.run("cat '" + presetDir + "/settings.json'");
    }

    function restoreSettings() {
        console.log("Restoring default configuration");
        cfg_globalSettings = JSON.stringify(Globals.defaultConfig, null, null);
    }

    function savePreset(presetDir) {
        console.log("Saving preset ", presetDir);
        var config = plasmoid.configuration;
        var output = {};
        for (var key of Object.keys(config)) {
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
                } else {
                    parsed;
                }
                output[name] = parsed;
            }
        }
        runCommand.run("mkdir -p '" + presetDir + "'");
        runCommand.run("echo '" + JSON.stringify(output, null, 4) + "' > '" + presetDir + "/settings.json'");
    }

    function deletePreset(path) {
        if (!path.includes("panel-colorizer/presets/") || path.includes("/ ") || path.includes(" /") || path.endsWith(" ") || path.includes("..")) {
            console.error(`Detected unsafe deletion of '${path}' aborting.`);
            return;
        }
        console.warn("rm -r '" + path + "'");
        runCommand.run("rm -r '" + path + "'");
    }

    Component.onCompleted: {
        Utils.delay(100, () => {
            runCommand.run(cratePresetsDirCmd);
            runCommand.run(listPresetsCmd);
        }, root);
    }

    header: ColumnLayout {
        Components.Header {
            id: headerComponent
            Layout.leftMargin: Kirigami.Units.mediumSpacing
            Layout.rightMargin: Kirigami.Units.mediumSpacing
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
                    text: i18n("Restore default panel appearance")
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
                    enabled: saveNameField.acceptableInput && !(Object.keys(root.presets).includes(saveNameField.text))
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
                            runCommand.run(root.listPresetsCmd);
                        }
                    }
                }
                Repeater {
                    model: Object.keys(root.presets)
                    Kirigami.AbstractCard {
                        id: content
                        required property int index
                        required property var modelData
                        property string dir: root.presets[content.modelData].dir
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
                                    text: content.modelData
                                    elide: Text.ElideRight
                                }

                                Rectangle {
                                    visible: root.presets[content.modelData].builtin
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
                                    visible: !root.presets[content.modelData].builtin
                                }
                                Button {
                                    text: i18n("Delete")
                                    icon.name: "edit-delete-remove-symbolic"
                                    onClicked: {
                                        root.editingPreset = content.dir;
                                        deletePresetDialog.open();
                                    }
                                    visible: !root.presets[content.modelData].builtin
                                }
                            }
                            Button {
                                text: i18n("Create preview")
                                icon.name: "insert-image-symbolic"
                                visible: !scrollView.visible
                                Layout.alignment: Qt.AlignHCenter
                                onClicked: {
                                    runCommand.run(root.spectaclePreviewCmd + "'" + content.dir + "/preview.png'");
                                }
                            }
                            ScrollView {
                                id: scrollView
                                Layout.preferredWidth: 500
                                Layout.maximumHeight: 100
                                visible: false
                                contentWidth: btn.implicitWidth
                                contentHeight: btn.implicitHeight

                                Image {
                                    id: image
                                    onStatusChanged: if (image.status == Image.Ready) {
                                        scrollView.visible = true;
                                        scrollView.height = sourceSize.height;
                                    } else {
                                        scrollView.visible = false;
                                    }
                                    source: content.dir + "/preview.png"
                                    fillMode: Image.PreserveAspectCrop
                                    horizontalAlignment: Image.AlignLeft
                                    cache: false
                                    asynchronous: true
                                    function refresh(presetName) {
                                        // only refresh preview of the changed preset
                                        if (presetName !== content.dir)
                                            return;
                                        source = "";
                                        source = content.dir + "/preview.png";
                                    }
                                    Component.onCompleted: {
                                        root.refreshImage.connect(refresh);
                                    }
                                }
                                Button {
                                    id: btn
                                    visible: true
                                    text: i18n("Update preview")
                                    anchors.fill: parent
                                    icon.name: "edit-image-symbolic"
                                    enabled: !root.presets[content.modelData].builtin
                                    onClicked: {
                                        runCommand.run(root.spectaclePreviewCmd + "'" + content.dir + "/preview.png" + "'");
                                    }
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
                                            enabled: !root.presets[content.modelData].builtin
                                            onTapped: runCommand.run(root.spectaclePreviewCmd + "'" + content.dir + "/preview.png" + "'")
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

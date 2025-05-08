pragma ComponentBehavior: Bound
import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.activities as Activities
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import "components" as Components
import "code/enum.js" as Enum

KCM.SimpleKCM {
    id: root
    property alias cfg_isEnabled: headerComponent.isEnabled
    property string presetsDir: StandardPaths.writableLocation(StandardPaths.HomeLocation).toString().substring(7) + "/.config/panel-colorizer/presets"
    property string cratePresetsDirCmd: "mkdir -p " + presetsDir
    property string presetsBuiltinDir: Qt.resolvedUrl("./presets").toString().substring(7) + "/"
    property string toolsDir: Qt.resolvedUrl("./tools").toString().substring(7) + "/"
    property string listUserPresetsCmd: "'" + toolsDir + "list_presets.sh' '" + presetsDir + "'"
    property string listBuiltinPresetsCmd: "'" + toolsDir + "list_presets.sh' '" + presetsBuiltinDir + "' b"
    property string listPresetsCmd: listBuiltinPresetsCmd + ";" + listUserPresetsCmd

    property string cfg_presetAutoloading
    property var autoLoadConfig: JSON.parse(cfg_presetAutoloading)

    property alias cfg_widgetClickMode: widgetClickModeCombo.currentIndex
    readonly property list<string> widgetClickModes: ["Toggle Panel Colorizer", "Switch presets", "Show popup"]

    property string cfg_switchPresets
    property var switchPresets: JSON.parse(cfg_switchPresets)

    property var presetsList: []

    function updateConfig() {
        cfg_presetAutoloading = JSON.stringify(autoLoadConfig, null, null);
        cfg_switchPresets = JSON.stringify(switchPresets, null, null);
    }

    ListModel {
        id: presetsModel
    }

    RunCommand {
        id: runCommand
    }

    Activities.ActivityModel {
        id: activityModel
    }

    Connections {
        target: runCommand
        function onExited(cmd, exitCode, exitStatus, stdout, stderr) {
            if (exitCode !== 0) {
                console.error(cmd, exitCode, exitStatus, stdout, stderr);
                return;
            }
            // console.log(stdout);
            if (cmd === listPresetsCmd) {
                if (stdout.length === 0)
                    return;
                presetsModel.append({
                    "name": i18n("Do nothing"),
                    "value": ""
                });

                const out = stdout.trim().split("\n");
                for (const line of out) {
                    const parts = line.split(":");
                    const path = parts[parts.length - 1];
                    let name = path.split("/");
                    name = name[name.length - 1];
                    const dir = parts[1];
                    console.log(dir);
                    const preset = {
                        "name": name,
                        "value": dir
                    };
                    presetsModel.append(preset);
                    presetsList.push(preset);
                }
            }
            if (presetsList.length && switchPresets.length) {
                switchPresets = pruneMissingPresets(switchPresets);
            }
        }
    }

    function pruneMissingPresets(switchPresets) {
        return switchPresets.filter(saved => presetsList.some(p => p.value === saved));
    }

    function getIndex(model, savedValue) {
        for (let i = 0; i < model.count; i++) {
            if (model.get(i).value === savedValue) {
                return i;
            }
        }
        return 0;
    }

    Component.onCompleted: {
        runCommand.run(cratePresetsDirCmd);
        runCommand.run(listPresetsCmd);
    }

    header: ColumnLayout {
        Components.Header {
            id: headerComponent
            Layout.leftMargin: Kirigami.Units.mediumSpacing
            Layout.rightMargin: Kirigami.Units.mediumSpacing
        }
    }

    ColumnLayout {
        enabled: cfg_isEnabled
        Kirigami.InlineMessage {
            Layout.fillWidth: true
            text: i18n("Disable preset auto-loading when making changes to presets, unsaved preset settings will be lost when presets change!")
            visible: true
            type: Kirigami.MessageType.Information
        }
        Label {
            text: i18n("Switch between different panel presets based on the Panel and window states")
            Layout.maximumWidth: root.width - (Kirigami.Units.gridUnit * 2)
            wrapMode: Text.Wrap
        }

        Kirigami.FormLayout {

            Kirigami.Separator {
                Kirigami.FormData.isSection: true
                Kirigami.FormData.label: i18n("Environment")
                Layout.fillWidth: true
            }

            RowLayout {
                Kirigami.FormData.label: i18n("Enabled:")
                CheckBox {
                    id: enabledCheckbox
                    checked: autoLoadConfig.enabled
                    onCheckedChanged: {
                        autoLoadConfig.enabled = checked;
                        updateConfig();
                    }
                }
                Kirigami.ContextualHelpButton {
                    toolTipText: i18n("Priorities go in descending order. E.g. if both <b>Maximized window is shown</b> and <b>Panel touching window</b> have a preset selected, and there is a maximized window on the screen, the <b>Maximized</b> preset will be applied.")
                }
            }

            CheckBox {
                Kirigami.FormData.label: i18n("Window tracking:")
                text: i18n("Per screen")
                checked: autoLoadConfig.filterByScreen
                onCheckedChanged: {
                    autoLoadConfig.filterByScreen = checked;
                    updateConfig();
                }
                enabled: enabledCheckbox.checked
            }

            CheckBox {
                text: i18n("Active only")
                checked: autoLoadConfig.filterByActive
                onCheckedChanged: {
                    autoLoadConfig.filterByActive = checked;
                    updateConfig();
                }
                enabled: enabledCheckbox.checked
            }

            RowLayout {
                CheckBox {
                    text: i18n("Active window fallback")
                    checked: autoLoadConfig.trackLastActive
                    onCheckedChanged: {
                        autoLoadConfig.trackLastActive = checked;
                        updateConfig();
                    }
                    enabled: enabledCheckbox.checked
                }
                Kirigami.ContextualHelpButton {
                    toolTipText: i18n("Track KWin's top window when there is no active one in the screen.")
                }
            }

            ComboBox {
                model: presetsModel
                textRole: "name"
                Kirigami.FormData.label: i18n("Fullscreen window:")
                onCurrentIndexChanged: {
                    autoLoadConfig.fullscreenWindow = model.get(currentIndex)["value"];
                    updateConfig();
                }
                currentIndex: getIndex(model, autoLoadConfig.fullscreenWindow)
                enabled: enabledCheckbox.checked
            }

            ComboBox {
                model: presetsModel
                textRole: "name"
                Kirigami.FormData.label: i18n("Maximized window:")
                onCurrentIndexChanged: {
                    autoLoadConfig.maximized = model.get(currentIndex)["value"];
                    updateConfig();
                }
                currentIndex: getIndex(model, autoLoadConfig.maximized)
                enabled: enabledCheckbox.checked
            }

            ComboBox {
                model: presetsModel
                textRole: "name"
                Kirigami.FormData.label: i18n("Window touching panel:")
                onCurrentIndexChanged: {
                    autoLoadConfig.touchingWindow = model.get(currentIndex)["value"];
                    updateConfig();
                }
                currentIndex: getIndex(model, autoLoadConfig.touchingWindow)
                enabled: enabledCheckbox.checked
            }

            ComboBox {
                model: presetsModel
                textRole: "name"
                Kirigami.FormData.label: i18n("Active window:")
                onCurrentIndexChanged: {
                    autoLoadConfig.activeWindow = model.get(currentIndex)["value"];
                    updateConfig();
                }
                currentIndex: getIndex(model, autoLoadConfig.activeWindow)
                enabled: enabledCheckbox.checked
            }

            ComboBox {
                model: presetsModel
                textRole: "name"
                Kirigami.FormData.label: i18n("At least one window is visible:")
                onCurrentIndexChanged: {
                    autoLoadConfig.visibleWindows = model.get(currentIndex)["value"];
                    updateConfig();
                }
                currentIndex: getIndex(model, autoLoadConfig.visibleWindows)
                enabled: enabledCheckbox.checked
            }

            ComboBox {
                model: presetsModel
                textRole: "name"
                Kirigami.FormData.label: i18n("Floating panel:")
                onCurrentIndexChanged: {
                    autoLoadConfig.floating = model.get(currentIndex)["value"];
                    updateConfig();
                }
                currentIndex: getIndex(model, autoLoadConfig.floating)
                enabled: enabledCheckbox.checked
            }

            Repeater {
                id: activitiesRepeater
                model: activityModel.rowCount() > 1 ? activityModel : []
                ComboBox {
                    model: presetsModel
                    textRole: "name"
                    required property var name
                    required property var id
                    Kirigami.FormData.label: "\"" + name + "\" " + i18n("activity:")
                    function cleanup() {
                        let activityIds = [];
                        for (let i = 0; i < activityModel.rowCount(); i++) {
                            const current = activityModel.index(i, 0);
                            activityIds.push(activityModel.data(current, Qt.UserRole));
                        }

                        // remove config for deleted activities
                        for (let activity in root.autoLoadConfig.activity) {
                            if (!(activityIds.includes(activity)) || root.autoLoadConfig.activity[activity] === "") {
                                delete root.autoLoadConfig.activity[activity];
                            }
                        }
                    }
                    onCurrentIndexChanged: {
                        if (!('activity' in root.autoLoadConfig)) {
                            root.autoLoadConfig.activity = {};
                        }
                        root.autoLoadConfig.activity[id] = model.get(currentIndex)["value"];
                        cleanup();
                        root.updateConfig();
                    }
                    currentIndex: root.getIndex(model, root.autoLoadConfig?.activity[id])
                    enabled: enabledCheckbox.checked
                }
            }

            ComboBox {
                model: presetsModel
                textRole: "name"
                Kirigami.FormData.label: i18n("Normal:")
                onCurrentIndexChanged: {
                    autoLoadConfig.normal = model.get(currentIndex)["value"];
                    updateConfig();
                }
                currentIndex: getIndex(model, autoLoadConfig.normal)
                enabled: enabledCheckbox.checked
            }

            Kirigami.Separator {
                Kirigami.FormData.isSection: true
                Kirigami.FormData.label: i18n("Widget Click")
                Layout.fillWidth: true
            }

            ComboBox {
                id: widgetClickModeCombo
                Kirigami.FormData.label: "Action:"
                model: widgetClickModes
            }

            ColumnLayout {
                Layout.fillWidth: true
                ScrollView {
                    enabled: cfg_widgetClickMode === Enum.WidgetClickModes.SwitchPresets
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.min(implicitHeight + 20, 200)
                    ListView {
                        id: listView
                        model: presetsModel
                        Layout.preferredWidth: Math.min(width + 50, 100)
                        reuseItems: true
                        clip: true
                        focus: true
                        activeFocusOnTab: true
                        keyNavigationEnabled: true
                        delegate: RowLayout {
                            width: ListView.view.width
                            required property var model
                            CheckBox {
                                id: presetCheckbox
                                text: model.name
                                checked: root.switchPresets.includes(model.value)
                                Layout.rightMargin: Kirigami.Units.smallSpacing * 4
                                onCheckedChanged: {
                                    if (checked) {
                                        if (!root.switchPresets.includes(model.value)) {
                                            root.switchPresets.push(model.value);
                                        }
                                    } else {
                                        root.switchPresets = root.switchPresets.filter(p => p !== model.value);
                                    }
                                    updateConfig();
                                }
                            }
                        }
                        highlight: Item {}
                        highlightMoveDuration: 0
                        highlightResizeDuration: 0
                    }
                }
            }
        }
    }
}

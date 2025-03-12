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
    property alias cfg_isEnabled: headerComponent.isEnabled
    property string cfg_panelWidgets
    property bool clearing: false
    property string cfg_configurationOverrides
    property var config: JSON.parse(cfg_configurationOverrides)
    property bool loaded: false
    property string overrideName
    property var editingConfig
    property bool showingConfig: false
    property bool userInput: false
    property var configOverrides
    property var associationsModel
    property int currentTab
    property string configDir: StandardPaths.writableLocation(StandardPaths.HomeLocation).toString().substring(7) + "/.config/panel-colorizer/"
    property string importCmd: "cat '" + configDir + "overrides.json'"
    property string crateConfigDirCmd: "mkdir -p " + configDir

    Component.onCompleted: {
        configOverrides = JSON.parse(JSON.stringify(config.overrides));
        associationsModel = JSON.parse(JSON.stringify(config.associations));
        associationsModel = Utils.clearOldWidgetConfig(associationsModel);
        console.log(JSON.stringify(associationsModel));
        initWidgets();
    }

    Timer {
        id: readTimer
        interval: 100
        onTriggered: {
            initWidgets();
        }
    }

    function updateConfig() {
        console.log("updateConfig()");
        const tmp = JSON.parse(JSON.stringify(configOverrides, null, null));
        // configOverrides = []
        configOverrides = tmp;
        config.overrides = configOverrides;
        associationsModel = JSON.parse(JSON.stringify(associationsModel, null, null));
        config.associations = associationsModel;
        console.log(JSON.stringify(associationsModel));
        cfg_configurationOverrides = JSON.stringify(config, null, null);
    }

    ListModel {
        id: widgetsModel
    }

    RunCommand {
        id: runCommand
    }
    Connections {
        target: runCommand
        function onExited(cmd, exitCode, exitStatus, stdout, stderr) {
            if (exitCode !== 0)
                return;
            if (cmd.startsWith("cat")) {
                const content = stdout.trim().split("\n");
                try {
                    const newConfig = JSON.parse(content);
                    root.importConfig(newConfig);
                } catch (e) {
                    console.error(e);
                }
            }
        }
    }

    function importConfig(newConfig) {
        loaded = false;
        configOverrides = newConfig.overrides;
        configOverrides = newConfig.overrides;
        associationsModel = newConfig.associations;
        updateConfig();
        loaded = true;
    }

    function initWidgets() {
        console.log("initWidgets()");
        widgetsModel.clear();
        const object = JSON.parse(cfg_panelWidgets);
        for (const widget of object) {
            const id = widget.id;
            const name = widget.name;
            const title = widget.title;
            const icon = widget.icon;
            const inTray = widget.inTray;
            widgetsModel.append({
                "id": id,
                "name": name,
                "title": title,
                "icon": icon,
                "inTray": inTray
            });
        }
        loaded = true;
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
            text: i18n("Create configuration overrides and apply them to one or multiple widgets. These overrides are independent and will be applied on top of the current settings and across presets.")
            visible: true
            type: Kirigami.MessageType.Information
        }
        Components.SettingImportExport {
            onExportConfirmed: {
                runCommand.run(crateConfigDirCmd);
                runCommand.run("echo '" + cfg_configurationOverrides + "' > '" + configDir + "overrides.json'");
            }
            onImportConfirmed: runCommand.run(importCmd)
        }

        Kirigami.FormLayout {

            Kirigami.Separator {
                Kirigami.FormData.isSection: true
                Kirigami.FormData.label: i18n("Configuration overrides")
            }

            ColumnLayout {
                id: presetCards
                Layout.minimumWidth: 500
                Repeater {
                    model: Object.keys(root.configOverrides)
                    delegate: Components.WidgetCardOverride {
                        onDeleteOverride: name => {
                            delete configOverrides[name];
                            root.updateConfig();
                        }
                        onEditingName: name => {
                            overrideName = name;
                        }
                    }
                }
                RowLayout {
                    Item {
                        Layout.fillWidth: true
                    }
                    Button {
                        icon.name: "list-add-symbolic"
                        text: "New override"
                        onClicked: {
                            let nextOverride = Object.keys(configOverrides).length + 1;
                            while (`Global Override ${nextOverride}` in configOverrides) {
                                nextOverride++;
                            }
                            configOverrides[`Global Override ${nextOverride}`] = Globals.baseOverrideConfig;
                            root.updateConfig();
                        }
                    }
                }
            }

            // Label {
            //     text: overrideName
            // }

            ColumnLayout {
                visible: showingConfig && userInput
                Kirigami.FormLayout {
                    id: parentLayout
                    // Layout.preferredWidth: 600
                    Kirigami.Separator {
                        Kirigami.FormData.isSection: true
                        Kirigami.FormData.label: i18n("Override settings")
                    }
                    RowLayout {
                        Kirigami.FormData.label: "Name:"
                        TextField {
                            id: nameField
                            Layout.fillWidth: true
                            placeholderText: i18n("Override name")
                            text: overrideName
                            validator: RegularExpressionValidator {
                                regularExpression: /^(?![\s\.])([a-zA-Z0-9. _\-]+)(?<![\.|])$/
                            }
                        }
                        Button {
                            icon.name: "checkmark-symbolic"
                            text: "Rename"
                            onClicked: {
                                configOverrides[nameField.text] = configOverrides[overrideName];
                                delete configOverrides[overrideName];
                                overrideName = nameField.text;
                                root.updateConfig();
                            }
                        }
                    }
                    RowLayout {
                        Kirigami.FormData.label: i18n("Fallback:")
                        CheckBox {
                            checked: configOverrides[overrideName]?.disabledFallback || false
                            onCheckedChanged: {
                                configOverrides[overrideName].disabledFallback = checked;
                                root.updateConfig();
                            }
                        }
                        Kirigami.ContextualHelpButton {
                            toolTipText: i18n("Fallback to the Global/Preset widget settings for disabled options, except for <b>Enable</b> and <b>Blur</>.")
                        }
                    }
                }
                Loader {
                    id: componentLoader
                    asynchronous: true
                    sourceComponent: showingConfig ? settingsComp : null
                    onLoaded: {
                        item.config = configOverrides[overrideName];
                        item.onUpdateConfigString.connect((newString, config) => {
                            configOverrides[overrideName] = config;
                            root.updateConfig();
                        });
                        item.currentTab = root.currentTab;
                        item.keyFriendlyName = "Widgets";
                        item.tabChanged.connect(currentTab => {
                            root.currentTab = currentTab;
                        });
                    }
                }

                Component {
                    id: settingsComp
                    Components.FormWidgetSettings {}
                }
            }

            Kirigami.Separator {
                Kirigami.FormData.isSection: true
                Kirigami.FormData.label: i18n("Widgets")
            }

            Label {
                text: i18n("Overrides are applied from top to bottom, if two or more configuration overrides share the same option, the last occurence replaces the value of the previous one.")
                opacity: 0.7
                Layout.maximumWidth: presetCards.width
                wrapMode: Text.Wrap
            }

            ColumnLayout {
                id: widgetCards
                Layout.minimumWidth: 500
                Repeater {
                    model: widgetsModel
                    delegate: Components.WidgetCardConfig {
                        widget: model
                        configOverrides: Object.keys(root.configOverrides)
                        overrideAssociations: associationsModel
                        currentOverrides: associationsModel[Utils.getWidgetConfigIdx(id, name, associationsModel)]?.presets || []
                        onAddOverride: (preset, index) => {
                            if (!loaded)
                                return;
                            let asocIndex = Utils.getWidgetConfigIdx(id, name, associationsModel);
                            console.log("asocIndex", asocIndex);
                            if (asocIndex === -1) {
                                associationsModel.push({
                                    "id": id,
                                    "name": name,
                                    "presets": []
                                });
                                asocIndex = associationsModel.length - 1;
                            }
                            if (index === null) {
                                associationsModel[asocIndex].presets.push(preset);
                            } else {
                                associationsModel[asocIndex].presets[index] = preset;
                            }
                            root.updateConfig();
                        }
                        onRemoveOverride: index => {
                            const asocIndex = Utils.getWidgetConfigIdx(id, name, associationsModel);
                            associationsModel[asocIndex].presets.splice(index, 1);
                            root.updateConfig();
                        }
                        onClearOverrides: () => {
                            const asocIndex = Utils.getWidgetConfigIdx(id, name, associationsModel);
                            associationsModel[asocIndex].presets = [];
                            root.updateConfig();
                        }
                    }
                }
            }
        }
    }
}

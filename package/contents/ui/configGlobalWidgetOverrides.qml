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
    id: appearanceRoot
    property alias parentLayout: parentLayout
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
    property int currentState
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

    function restoreSettings() {
        importConfig({
            "overrides": {},
            "associations": []
        });
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
                    appearanceRoot.importConfig(newConfig);
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
        }
    }

    ColumnLayout {
        enabled: cfg_isEnabled
        Kirigami.InlineMessage {
            Layout.fillWidth: true
            text: i18n("Create configuration overrides and apply them to one or multiple widgets. These overrides are independent of presets and will be applied on top of the current settings and across presets.<br>To blacklist a widget from modifications, <b>uncheck</b> options <b>Enable</b> and <b>Fallback</b>, and apply the override to the widget.")
            visible: true
            type: Kirigami.MessageType.Information
        }
        RowLayout {
            Button {
                text: i18n("Restore default (removes all overrides)")
                icon.name: "kt-restore-defaults-symbolic"
                onClicked: {
                    appearanceRoot.restoreSettings();
                }
                Layout.fillWidth: true
            }
        }
        Components.WidgetOverrideHint {
            Layout.alignment: Qt.AlignHCenter
        }
        Components.SettingImportExport {
            onExportConfirmed: {
                runCommand.exec(crateConfigDirCmd);
                runCommand.exec("echo '" + cfg_configurationOverrides + "' > '" + configDir + "overrides.json'");
            }
            onImportConfirmed: runCommand.exec(importCmd)
        }

        Kirigami.FormLayout {
            Kirigami.Separator {
                Kirigami.FormData.isSection: true
                Kirigami.FormData.label: i18n("Configuration overrides")
            }
        }

        ColumnLayout {
            id: presetCards
            Layout.minimumWidth: 500
            Layout.maximumWidth: 500
            Layout.alignment: Qt.AlignHCenter
            Repeater {
                model: Object.keys(appearanceRoot.configOverrides)
                delegate: Components.WidgetCardOverride {
                    onDeleteOverride: name => {
                        delete configOverrides[name];
                        showingConfig = false;
                        appearanceRoot.updateConfig();
                    }
                    onEditingName: name => {
                        overrideName = name;
                    }
                }
            }
            Button {
                icon.name: "list-add-symbolic"
                text: i18n("New override")
                Layout.fillWidth: true
                onClicked: {
                    let nextOverride = Object.keys(configOverrides).length + 1;
                    while (`Global Override ${nextOverride}` in configOverrides) {
                        nextOverride++;
                    }
                    configOverrides[`Global Override ${nextOverride}`] = Globals.baseOverrideConfig;
                    appearanceRoot.updateConfig();
                }
            }
        }

        ColumnLayout {
            visible: showingConfig && userInput
            Kirigami.FormLayout {
                id: parentLayout
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
                        text: i18n("Rename")
                        onClicked: {
                            configOverrides[nameField.text] = configOverrides[overrideName];
                            delete configOverrides[overrideName];
                            overrideName = nameField.text;
                            appearanceRoot.updateConfig();
                        }
                    }
                }
                RowLayout {
                    Kirigami.FormData.label: i18n("Fallback:")
                    CheckBox {
                        checked: configOverrides[overrideName]?.disabledFallback || false
                        onCheckedChanged: {
                            configOverrides[overrideName].disabledFallback = checked;
                            appearanceRoot.updateConfig();
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
                    item.width = appearanceRoot.availableWidth;
                    item.config = configOverrides[overrideName];
                    item.onUpdateConfigString.connect((newString, config) => {
                        configOverrides[overrideName] = config;
                        appearanceRoot.updateConfig();
                    });
                    item.elementState = appearanceRoot.currentState;
                    item.currentTab = appearanceRoot.currentTab;
                    item.elementFriendlyName = i18n("Widgets");
                    item.tabChanged.connect(currentTab => {
                        appearanceRoot.currentTab = currentTab;
                    });
                    item.elementStateChanged.connect(() => {
                        appearanceRoot.currentState = item.elementState;
                        componentLoader.sourceComponent = null;
                        componentLoader.sourceComponent = Qt.binding(() => showingConfig ? settingsComp : null);
                    });
                }
            }

            Component {
                id: settingsComp
                Components.FormWidgetSettings {}
            }
        }

        Kirigami.FormLayout {
            Kirigami.Separator {
                Kirigami.FormData.isSection: true
                Kirigami.FormData.label: i18n("Widgets")
            }
        }

        Label {
            text: i18n("Overrides are applied from top to bottom, if two or more configuration overrides share the same option, the last occurence replaces the value of the previous one.")
            opacity: 0.7
            Layout.maximumWidth: 700
            wrapMode: Text.Wrap
            Layout.alignment: Qt.AlignHCenter
        }

        ColumnLayout {
            id: widgetCards
            Layout.alignment: Qt.AlignHCenter
            Repeater {
                model: widgetsModel
                delegate: Components.WidgetCardConfig {
                    widget: model
                    configOverrides: Object.keys(appearanceRoot.configOverrides)
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
                        appearanceRoot.updateConfig();
                    }
                    onRemoveOverride: index => {
                        const asocIndex = Utils.getWidgetConfigIdx(id, name, associationsModel);
                        associationsModel[asocIndex].presets.splice(index, 1);
                        appearanceRoot.updateConfig();
                    }
                    onClearOverrides: () => {
                        const asocIndex = Utils.getWidgetConfigIdx(id, name, associationsModel);
                        associationsModel[asocIndex].presets = [];
                        appearanceRoot.updateConfig();
                    }
                }
            }
        }
    }
}

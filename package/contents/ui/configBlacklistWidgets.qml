pragma ComponentBehavior: Bound
import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "code/utils.js" as Utils
import "code/globals.js" as Globals
import "components" as Components
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid

KCM.SimpleKCM {
    id: root

    property alias cfg_isEnabled: headerComponent.isEnabled
    property string cfg_panelWidgets
    property bool clearing: false
    property string cfg_blacklistedWidgets
    property var config: JSON.parse(cfg_blacklistedWidgets)
    property var blacklistedWidgetsConfig
    property bool loaded: false
    property string configDir: StandardPaths.writableLocation(StandardPaths.HomeLocation).toString().substring(7) + "/.config/panel-colorizer/"
    property string importCmd: "cat '" + configDir + "blacklistWidgets.json'"
    property string crateConfigDirCmd: "mkdir -p " + configDir
    property alias cfg_blacklistSpacers: blacklistSpacers.checked

    function updateConfig() {
        console.log("updateConfig()");
        for (let i = 0; i < widgetsModel.count; i++) {
            // console.error(widget)

            const widget = widgetsModel.get(i);
            const id = widget.id;
            const name = widget.name;
            const blacklisted = widget.blacklisted;
            const cfgIndex = Utils.getWidgetConfigIdx(id, name, blacklistedWidgetsConfig);
            if (blacklisted) {
                if (cfgIndex !== -1) {
                    blacklistedWidgetsConfig[cfgIndex].blacklisted = blacklisted;
                } else {
                    blacklistedWidgetsConfig.push({
                        name,
                        id,
                        blacklisted
                    });
                }
            } else {
                blacklistedWidgetsConfig.splice(i);
            }
        }
        console.log(JSON.stringify(blacklistedWidgetsConfig));
        config.widgets = blacklistedWidgetsConfig;
        cfg_blacklistedWidgets = JSON.stringify(config, null, null);
    }

    function importConfig(newConfig) {
        loaded = false;
        blacklistedWidgetsConfig = newConfig.widgets;
        updateWidgetsModel();
        loaded = true;
        updateConfig();
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
            const globalShortcut = widget.globalShortcut ?? "";
            const isSpacer = Globals.spacerWidgets.includes(name);
            if (inTray || (isSpacer && cfg_blacklistSpacers))
                continue;
            widgetsModel.append({
                id,
                name,
                title,
                icon,
                inTray,
                blacklisted: false,
                globalShortcut
            });
        }
    }

    function updateWidgetsModel() {
        console.log("updateWidgetsModel()");
        for (let i = 0; i < widgetsModel.count; i++) {
            const widget = widgetsModel.get(i);
            const id = widget.id;
            const name = widget.name;
            let index = Utils.getWidgetConfigIdx(id, name, blacklistedWidgetsConfig);
            if (index !== -1) {
                const cfg = blacklistedWidgetsConfig[index];
                widgetsModel.set(i, {
                    "blacklisted": cfg.blacklisted
                });
            } else {
                widgetsModel.set(i, {
                    blacklisted: false
                });
            }
        }
        loaded = true;
    }

    function restoreSettings() {
        importConfig({
            "widgets": []
        });
    }

    Component.onCompleted: {
        blacklistedWidgetsConfig = config.widgets;
        console.log(JSON.stringify(blacklistedWidgetsConfig, null, null));
        initWidgets();
        updateWidgetsModel();
    }

    onCfg_blacklistSpacersChanged: {
        if (!loaded)
            return;

        initWidgets();
    }

    ListModel {
        id: widgetsModel
    }

    RunCommand {
        id: runCommand
    }

    Connections {
        function onExited(cmd, exitCode, exitStatus, stdout, stderr) {
            if (exitCode !== 0)
                return;

            if (cmd.startsWith("cat")) {
                const content = stdout.trim();
                try {
                    console.log(content);
                    const newConfig = JSON.parse(content);
                    root.importConfig(newConfig);
                } catch (e) {
                    console.error(e);
                }
            }
        }

        target: runCommand
    }

    ColumnLayout {
        enabled: cfg_isEnabled

        Kirigami.InlineMessage {
            Layout.fillWidth: true
            text: i18n("Blacklist widgets to keep their default appearance. A logout may be required for some widgets to fully restore their default appearance.")
            visible: true
            type: Kirigami.MessageType.Information
        }

        Kirigami.FormLayout {
            CheckBox {
                id: blacklistSpacers
                text: i18n("Blacklist spacers")
                checked: root.cfg_blacklistSpacers
                onCheckedChanged: {
                    root.updateConfig();
                }
            }
        }

        RowLayout {
            Button {
                text: i18n("Remove all")
                icon.name: ""
                onClicked: {
                    root.restoreSettings();
                }
                Layout.fillWidth: true
            }
        }

        Components.SettingImportExport {
            onExportConfirmed: {
                runCommand.exec(crateConfigDirCmd);
                runCommand.exec("echo '" + cfg_blacklistedWidgets + "' > '" + configDir + "blacklistWidgets.json'");
            }
            onImportConfirmed: runCommand.exec(importCmd)
        }

        ColumnLayout {
            id: widgetCards
            Layout.alignment: Qt.AlignHCenter
            Repeater {
                model: widgetsModel

                delegate: Components.WidgetCardBlacklist {
                    required property int index
                    onUpdateWidget: blacklisted => {
                        if (!root.loaded)
                            return;

                        widgetsModel.set(index, {
                            blacklisted
                        });
                        root.updateConfig();
                    }
                }
            }
        }
    }

    header: ColumnLayout {
        Components.Header {
            id: headerComponent
        }
    }
}

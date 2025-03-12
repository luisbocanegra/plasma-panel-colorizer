import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "code/utils.js" as Utils
import "components" as Components
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid

KCM.SimpleKCM {
    id: root

    property alias cfg_isEnabled: headerComponent.isEnabled
    property string cfg_panelWidgets
    property bool clearing: false
    property string cfg_forceForegroundColor
    property var config: JSON.parse(cfg_forceForegroundColor)
    property var forceFgConfig
    property bool loaded: false
    property string configDir: StandardPaths.writableLocation(StandardPaths.HomeLocation).toString().substring(7) + "/.config/panel-colorizer/"
    property string importCmd: "cat '" + configDir + "forceForegroundColor.json'"
    property string crateConfigDirCmd: "mkdir -p " + configDir

    function updateConfig() {
        console.log("updateConfig()");
        for (let i = 0; i < widgetsModel.count; i++) {
            // console.error(widget)

            const widget = widgetsModel.get(i);
            const id = widget.id;
            const name = widget.name;
            const method = widget.method;
            const reload = widget.reload;
            const cfgIndex = Utils.getWidgetConfigIdx(id, name, forceFgConfig);
            if (method.mask || method.multiEffect || reload) {
                if (cfgIndex !== -1) {
                    forceFgConfig[cfgIndex].method = method;
                    forceFgConfig[cfgIndex].reload = reload;
                } else {
                    forceFgConfig.push({
                        "name": name,
                        "id": id,
                        "method": method,
                        "reload": reload
                    });
                }
            } else {
                forceFgConfig.splice(i);
            }
        }
        console.log(JSON.stringify(forceFgConfig));
        config.widgets = forceFgConfig;
        cfg_forceForegroundColor = JSON.stringify(config, null, null);
    }

    function importConfig(newConfig) {
        loaded = false;
        // ignore 1.2.0- old config format
        forceFgConfig = Utils.clearOldWidgetConfig(newConfig.widgets);
        config.reloadInterval = newConfig.reloadInterval;
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
            widgetsModel.append({
                "id": id,
                "name": name,
                "title": title,
                "icon": icon,
                "inTray": inTray,
                "method": {
                    "mask": false,
                    "multiEffect": false
                },
                "reload": false
            });
        }
    }

    function updateWidgetsModel() {
        console.log("updateWidgetsModel()");
        for (let i = 0; i < widgetsModel.count; i++) {
            const widget = widgetsModel.get(i);
            const id = widget.id;
            const name = widget.name;
            let index = Utils.getWidgetConfigIdx(id, name, forceFgConfig);
            if (index !== -1) {
                const cfg = forceFgConfig[index];
                widgetsModel.set(i, {
                    "method": cfg.method,
                    "reload": cfg.reload
                });
            } else {
                widgetsModel.set(i, {
                    "method": {
                        "mask": false,
                        "multiEffect": false
                    },
                    "reload": false
                });
            }
        }
        loaded = true;
    }

    Component.onCompleted: {
        // ignore 1.2.0- old config format
        forceFgConfig = Utils.clearOldWidgetConfig(config.widgets);
        console.log(JSON.stringify(forceFgConfig, null, null));
        initWidgets();
        updateWidgetsModel();
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
            text: i18n("Force text and icon colors for specified widgets.<br><strong>Mask</strong>: Force Icon colorization (symbolic icons).<br><strong>Color Effect</strong>: Force Text/Icons colorization using post-processing effect (any icon).<br><strong>Refresh</strong>: Re-apply colorization at a fixed interval, for widgets that recreate or recolor content themselves<br>To restore the <strong>Mask<strong> and <strong>Color Effect</strong> disable and restart Plasma or logout.")
            visible: true
            type: Kirigami.MessageType.Information
        }

        Components.SettingImportExport {
            onExportConfirmed: {
                runCommand.run(crateConfigDirCmd);
                runCommand.run("echo '" + cfg_forceForegroundColor + "' > '" + configDir + "forceForegroundColor.json'");
            }
            onImportConfirmed: runCommand.run(importCmd)
        }

        Kirigami.FormLayout {
            Kirigami.Separator {
                Kirigami.FormData.isSection: true
                Kirigami.FormData.label: i18n("Force Text/Icon color")
            }

            SpinBox {
                Kirigami.FormData.label: i18n("Refresh interval:")
                from: 16
                to: 1000
                stepSize: 50
                value: config.reloadInterval
                onValueModified: {
                    config.reloadInterval = value;
                    root.updateConfig();
                }
            }
        }

        Kirigami.FormLayout {
            ColumnLayout {
                id: widgetCards

                Repeater {
                    model: widgetsModel

                    delegate: Components.WidgetCardCheck {
                        widget: model
                        onUpdateWidget: (maskEnabled, effectEnabled, reload) => {
                            if (!loaded)
                                return;

                            widgetsModel.set(index, {
                                "method": {
                                    "mask": maskEnabled,
                                    "multiEffect": effectEnabled
                                },
                                "reload": reload
                            });
                            root.updateConfig();
                        }
                    }
                }
            }
        }
    }

    header: ColumnLayout {
        Components.Header {
            id: headerComponent

            Layout.leftMargin: Kirigami.Units.mediumSpacing
            Layout.rightMargin: Kirigami.Units.mediumSpacing
        }
    }
}

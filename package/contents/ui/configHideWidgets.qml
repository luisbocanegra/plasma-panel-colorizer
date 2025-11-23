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
    property string cfg_hiddenWidgets
    property var config: JSON.parse(cfg_hiddenWidgets)
    property var hiddenWidgetsConfig
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
            const hide = widget.hide;
            const cfgIndex = Utils.getWidgetConfigIdx(id, name, hiddenWidgetsConfig);
            if (hide) {
                if (cfgIndex !== -1) {
                    hiddenWidgetsConfig[cfgIndex].hide = hide;
                } else {
                    hiddenWidgetsConfig.push({
                        name,
                        id,
                        hide
                    });
                }
            } else {
                hiddenWidgetsConfig.splice(i);
            }
        }
        console.log(JSON.stringify(hiddenWidgetsConfig));
        config.widgets = hiddenWidgetsConfig;
        cfg_hiddenWidgets = JSON.stringify(config, null, null);
    }

    function importConfig(newConfig) {
        loaded = false;
        hiddenWidgetsConfig = newConfig.widgets;
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
            if (inTray)
                continue;
            widgetsModel.append({
                id,
                name,
                title,
                icon,
                inTray,
                hide: false,
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
            let index = Utils.getWidgetConfigIdx(id, name, hiddenWidgetsConfig);
            if (index !== -1) {
                const cfg = hiddenWidgetsConfig[index];
                widgetsModel.set(i, {
                    "hide": cfg.hide
                });
            } else {
                widgetsModel.set(i, {
                    hide: false
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
        hiddenWidgetsConfig = config.widgets;
        console.log(JSON.stringify(hiddenWidgetsConfig, null, null));
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
            text: i18n("Hidden widgets can still be activated using keyboard shortcuts and are always visible in the Desktop Edit Mode.<br>The activation shortcut can be configured from the <b>Keyboard Shortcuts</b> page on each widget's configuration window.")
            visible: true
            type: Kirigami.MessageType.Information
        }

        RowLayout {
            Button {
                text: i18n("Restore default (controlled by each widget)")
                icon.name: ""
                onClicked: {
                    root.restoreSettings();
                }
                Layout.fillWidth: true
            }
        }

        Components.SettingImportExport {
            onExportConfirmed: {
                runCommand.run(crateConfigDirCmd);
                runCommand.run("echo '" + cfg_hiddenWidgets + "' > '" + configDir + "hiddenWidgets.json'");
            }
            onImportConfirmed: runCommand.run(importCmd)
        }

        ColumnLayout {
            id: widgetCards
            Layout.alignment: Qt.AlignHCenter
            Repeater {
                model: widgetsModel

                delegate: Components.WidgetCardHide {
                    widget: model
                    onUpdateWidget: hide => {
                        if (!loaded)
                            return;

                        widgetsModel.set(index, {
                            hide
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

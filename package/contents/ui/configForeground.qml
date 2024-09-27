import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import "components" as Components
import "code/utils.js" as Utils

KCM.SimpleKCM {
    id:root
    property alias cfg_isEnabled: headerComponent.isEnabled
    property string cfg_panelWidgets
    property bool clearing: false
    property string cfg_forceForegroundColor
    property var config: JSON.parse(cfg_forceForegroundColor)
    property var forceFgConfig
    property bool loaded: false
    property string configDir: StandardPaths.writableLocation(
                    StandardPaths.HomeLocation).toString().substring(7) + "/.config/panel-colorizer/"
    property string importCmd: "cat '" + configDir + "forceForegroundColor.json'"
    property string crateConfigDirCmd: "mkdir -p " + configDir

    Component.onCompleted: {
        forceFgConfig = config.widgets
        console.error(JSON.stringify(forceFgConfig, null, null))
        initWidgets()
        updateWidgetsModel()
    }

    function updateConfig() {
        for (let i = 0; i < widgetsModel.count; i++) {
            const widget = widgetsModel.get(i)
            const name = widget.name
            const method = widget.method
            const reload = widget.reload
            console.error(name, method.mask, method.multiEffect)
            if (method.mask || method.multiEffect || reload) {
                forceFgConfig[name] = {"method": method, "reload":reload}
            } else {
                delete forceFgConfig[widget.name]
            }
        }
        config.widgets = forceFgConfig
        cfg_forceForegroundColor = JSON.stringify(config, null, null)
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
            if (exitCode!==0) return
            if (cmd.startsWith("cat")) {
                const content = stdout.trim().split("\n")
                try {
                    console.error(content)
                    const newConfig = JSON.parse(content)
                    importConfig(newConfig)
                } catch (e) {
                    console.error(e)
                }
            }
        }
    }

    function importConfig(newConfig) {
        loaded = false
        forceFgConfig = newConfig.widgets
        config.reloadInterval = newConfig.reloadInterval
        updateWidgetsModel()
        loaded = true
        updateConfig()
    }

    function initWidgets(){
        widgetsModel.clear()
        const object = JSON.parse(cfg_panelWidgets)
        for (const widget of object) {
            const name = widget.name
            const title = widget.title
            const icon = widget.icon
            const inTray = widget.inTray
            widgetsModel.append({
                "name": name, "title": title, "icon": icon, "inTray":inTray,
                "method": { "mask": false, "multiEffect": false }, "reload": false
            })
        }
    }

    function updateWidgetsModel(){
        for (let i = 0; i < widgetsModel.count; i++) {
            const widget = widgetsModel.get(i)
            const name = widget.name
            if (name in forceFgConfig) {
                let cfg = forceFgConfig[name]
                widgetsModel.set(i, {"method": cfg.method, "reload": cfg.reload})
            } else {
                widgetsModel.set(i, {"method": { "mask": false, "multiEffect": false }, "reload": false})
            }
        }
        loaded = true
    }

    header: ColumnLayout {
        Components.Header {
            id: headerComponent
            Layout.leftMargin: Kirigami.Units.mediumSpacing
            Layout.rightMargin: Kirigami.Units.mediumSpacing
        }
    }

    ColumnLayout {
        Components.SettingImportExport {
            onExportConfirmed: {
                runCommand.run(crateConfigDirCmd)
                runCommand.run("echo '"+cfg_forceForegroundColor+"' > '" + configDir + "forceForegroundColor.json'")
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
                    config.reloadInterval = value
                    root.updateConfig()
                }
            }
        }
    Kirigami.FormLayout {

        Label {
            text: i18n("<strong>[M]ask</strong>: Force Icon colorization (symbolic icons).<br><strong>[E]ffect</strong>: Force Text/Icons colorization using post-processing effect (any icon).<br><strong>[R]eload</strong>: Re-apply colorization at a fixed interval, use for widgets whore color gets stuck.<br>To restore the <strong>Mask<strong> and <strong>Color Effect</strong> disable and restart Plasma or logout.")
            opacity: 0.7
            Layout.maximumWidth: widgetCards.width
            wrapMode: Text.Wrap
        }

        ColumnLayout {
            id: widgetCards
            Repeater {
                model: widgetsModel
                delegate: Components.WidgetCardCheck {
                    widget: model
                    onUpdateWidget: (maskEnabled, effectEnabled, reload) => {
                        if (!loaded) return
                        widgetsModel.set(index,
                        {
                            "method":{ "mask": maskEnabled, "multiEffect": effectEnabled},
                            "reload": reload
                        })
                        root.updateConfig()
                    }
                }
            }
        }
    }
    }
}

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
    property string cfg_globalSettings
    property var config: JSON.parse(cfg_globalSettings)
    property var unifiedBackgroundSettings
    property bool loaded: false
    property string configDir: StandardPaths.writableLocation(
                    StandardPaths.HomeLocation).toString().substring(7) + "/.config/panel-colorizer/"
    property string importCmd: "cat '" + configDir + "forceForegroundColor.json'"
    property string crateConfigDirCmd: "mkdir -p " + configDir

    Component.onCompleted: {
        unifiedBackgroundSettings = config.unifiedBackground
        console.error(JSON.stringify(unifiedBackgroundSettings, null, null))
        initWidgets()
        updateWidgetsModel()
    }

    function updateConfig() {
        for (let i = 0; i < widgetsModel.count; i++) {
            const widget = widgetsModel.get(i)
            const widgetName = widget.name
            const unifyBgType = widget.unifyBgType
            console.error(widgetName, unifyBgType)
            if (unifyBgType !== 0) {
                unifiedBackgroundSettings[widgetName] = unifyBgType
            } else {
                delete unifiedBackgroundSettings[widgetName]
            }
        }
        config.unifiedBackground = unifiedBackgroundSettings
        cfg_globalSettings = JSON.stringify(config, null, null)
    }

    ListModel {
        id: widgetsModel
    }

    RunCommand {
        id: runCommand
    }

    function initWidgets(){
        widgetsModel.clear()
        const object = JSON.parse(cfg_panelWidgets)
        for (const widget of object) {
            const name = widget.name
            const title = widget.title
            const icon = widget.icon
            const inTray = widget.inTray
            if (inTray) continue
            widgetsModel.append({
                "name": name, "title": title, "icon": icon, "inTray":inTray,
                "unifyBgType": 0
            })
        }
    }

    function updateWidgetsModel(){
        for (let i = 0; i < widgetsModel.count; i++) {
            const widget = widgetsModel.get(i)
            const name = widget.name
            if (name in unifiedBackgroundSettings) {
                let unifyBgType = unifiedBackgroundSettings[name]
                widgetsModel.set(i, {"unifyBgType": unifyBgType})
            } else {
                widgetsModel.set(i, {"unifyBgType": 0})
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
        enabled: cfg_isEnabled
    Kirigami.FormLayout {

        Label {
            text: i18n("Select start and end of unified background areas, widgets between <b>Start</b> and <b>End</b> must be left Disabled.")
            opacity: 0.7
            Layout.maximumWidth: widgetCards.width
            wrapMode: Text.Wrap
        }

        ColumnLayout {
            id: widgetCards
            Repeater {
                model: widgetsModel
                delegate: Components.WidgetCardUnifiedBg {
                    widget: model
                    onUpdateWidget: (unifyBgType) => {
                        if (!loaded) return
                        console.log(model.name, unifyBgType)
                        widgetsModel.set(index, {"unifyBgType": unifyBgType})
                        root.updateConfig()
                    }
                }
            }
        }
    }
    }
}

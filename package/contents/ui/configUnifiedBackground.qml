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
    property string cfg_globalSettings
    property var config: JSON.parse(cfg_globalSettings)
    property var unifiedBackgroundSettings
    property bool loaded: false

    Component.onCompleted: {
        unifiedBackgroundSettings = config.unifiedBackground
        console.error(JSON.stringify(unifiedBackgroundSettings, null, null))
        initWidgets()
        updateWidgetsModel()
    }

    function updateConfig() {
        console.log("updateConfig()")
        for (let i = 0; i < widgetsModel.count; i++) {
            const widget = widgetsModel.get(i)
            const id = widget.id
            const name = widget.name
            const unifyBgType = widget.unifyBgType
            console.error(name, unifyBgType)

            const cfgIndex = getUnifiedBgConfigIdx(id, name, unifiedBackgroundSettings)
            if (unifyBgType != 0) {
                if (cfgIndex !== -1) {
                    unifiedBackgroundSettings[cfgIndex].unifyBgType = unifyBgType
                } else {
                    unifiedBackgroundSettings.push({
                        "name": name, "id": id, "unifyBgType": unifyBgType
                    })
                }
            } else {
                unifiedBackgroundSettings.splice(i)
            }
        }
        console.log(JSON.stringify(unifiedBackgroundSettings))
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
        console.log("initWidgets()")
        widgetsModel.clear()
        const object = JSON.parse(cfg_panelWidgets)
        for (const widget of object) {
            const id = widget.id
            const name = widget.name
            const title = widget.title
            const icon = widget.icon
            const inTray = widget.inTray
            if (inTray) continue
            widgetsModel.append({
                "id": id, "name": name, "title": title, "icon": icon,
                "inTray": inTray, "unifyBgType": 0
            })
        }
    }

    // cfg_globalSettings.unifiedBackground is now an array instead of key-value,
    // this allows us to find the target when have more than one instance
    // of the same widget in a panel
    // NOTE: this is not a workaround for issue #125,
    function getUnifiedBgConfigIdx(id, name, config) {
        // console.log("getUnifiedBgConfigIdx()")
        return config.findIndex((item) => item.id == id && item.name == name)
    }

    function updateWidgetsModel(){
        for (let i = 0; i < widgetsModel.count; i++) {
            const widget = widgetsModel.get(i)
            const id = widget.id
            const name = widget.name

            const index = getUnifiedBgConfigIdx(id, name, unifiedBackgroundSettings)
            if (index !== -1) {
                const unifyBgType = unifiedBackgroundSettings[index].unifyBgType
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
        Kirigami.InlineMessage {
            Layout.fillWidth: true
            text: i18n("Select start and end of unified background areas, widgets between <b>Start</b> and <b>End</b> must be left Disabled.")
            visible: true
            type: Kirigami.MessageType.Information
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

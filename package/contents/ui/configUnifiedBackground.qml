pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "code/utils.js" as Utils
import "components" as Components
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami

KCM.SimpleKCM {
    id: root

    property alias cfg_isEnabled: headerComponent.isEnabled
    property string cfg_panelWidgets
    property string cfg_globalSettings
    property var config: JSON.parse(cfg_globalSettings)
    property var unifiedBackgroundSettings
    property bool loaded: false

    function updateConfig() {
        console.log("updateConfig()");
        for (let i = 0; i < widgetsModel.count; i++) {
            const widget = widgetsModel.get(i);
            const id = widget.id;
            const name = widget.name;
            const unifyBgType = widget.unifyBgType;
            const cfgIndex = Utils.getWidgetConfigIdx(id, name, unifiedBackgroundSettings);
            console.log(name, unifyBgType, cfgIndex);
            if (unifyBgType != 0) {
                if (cfgIndex !== -1) {
                    unifiedBackgroundSettings[cfgIndex].unifyBgType = unifyBgType;
                } else {
                    console.log("push");
                    unifiedBackgroundSettings.push({
                        "name": name,
                        "id": id,
                        "unifyBgType": unifyBgType
                    });
                }
            } else if (cfgIndex !== -1) {
                unifiedBackgroundSettings.splice(cfgIndex);
            }
        }
        console.log(JSON.stringify(unifiedBackgroundSettings));
        config.unifiedBackground = unifiedBackgroundSettings;
        cfg_globalSettings = JSON.stringify(config, null, null);
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
            if (inTray)
                continue;

            widgetsModel.append({
                "id": id,
                "name": name,
                "title": title,
                "icon": icon,
                "inTray": inTray,
                "unifyBgType": 0
            });
        }
    }

    function updateWidgetsModel() {
        for (let i = 0; i < widgetsModel.count; i++) {
            const widget = widgetsModel.get(i);
            const id = widget.id;
            const name = widget.name;
            const index = Utils.getWidgetConfigIdx(id, name, unifiedBackgroundSettings);
            if (index !== -1) {
                const unifyBgType = unifiedBackgroundSettings[index].unifyBgType;
                widgetsModel.set(i, {
                    "unifyBgType": unifyBgType
                });
            } else {
                widgetsModel.set(i, {
                    "unifyBgType": 0
                });
            }
        }
        loaded = true;
    }

    Component.onCompleted: {
        // ignore 1.2.0- old config format
        unifiedBackgroundSettings = Utils.clearOldWidgetConfig(config.unifiedBackground);
        console.log(JSON.stringify(unifiedBackgroundSettings, null, null));
        initWidgets();
        updateWidgetsModel();
    }

    ListModel {
        id: widgetsModel
    }

    RunCommand {
        id: runCommand
    }

    ColumnLayout {
        enabled: root.cfg_isEnabled

        Kirigami.FormLayout {
            Kirigami.InlineMessage {
                Layout.fillWidth: true
                text: i18n("Select start and end of unified background areas, widgets between <b>Start</b> and <b>End</b> must be left <b>disabled</b>. Note: <strong>odd</strong> widget spacing values are automatically converted to <strong>evens</strong> when this feature is used.")
                visible: true
                type: Kirigami.MessageType.Information
            }

            ColumnLayout {
                id: widgetCards

                Repeater {
                    model: widgetsModel

                    Components.WidgetCardUnifiedBg {
                        required property int index
                        required property string name
                        required property var model
                        widget: model
                        onUpdateWidget: unifyBgType => {
                            if (!root.loaded)
                                return;

                            console.log(name, unifyBgType);
                            widgetsModel.set(index, {
                                "unifyBgType": unifyBgType
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

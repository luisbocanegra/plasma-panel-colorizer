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
    property bool cfg_isEnabled
    property string cfg_panelWidgets
    property bool clearing: false
    property string cfg_allSettings
    property var config: JSON.parse(cfg_allSettings)
    property var forceFgConfig
    property bool loaded: false

    Component.onCompleted: {
        forceFgConfig = config.forceForegroundColor
        console.error(JSON.stringify(forceFgConfig, null, null))
        initWidgets()
        updateWidgetsModel()
    }

    function updateConfig() {
        for (let i = 0; i < widgetsModel.count; i++) {
            const widget = widgetsModel.get(i)
            const name = widget.name
            const method = widget.method
            console.error(name, method.mask, method.multiEffect)
            if (method.mask || method.multiEffect) {
                forceFgConfig[name] = {"method": widget.method}
            } else {
                delete forceFgConfig[widget.name]
            }
        }
        config.forceForegroundColor = forceFgConfig
        cfg_allSettings = JSON.stringify(config, null, null)
    }

    ListModel {
        id: widgetsModel
    }

    function initWidgets(){
        widgetsModel.clear()
        const object = JSON.parse(cfg_panelWidgets)
        for (const widget of object) {
            const name = widget.name
            const title = widget.title
            const icon = widget.icon
            widgetsModel.append({ "name": name, "title": title, "icon": icon, "method": { "mask":false, "multiEffect": false }} )
        }
    }

    function updateWidgetsModel(){
        for (let i = 0; i < widgetsModel.count; i++) {
            const widget = widgetsModel.get(i)
            const name = widget.name
            if (name in forceFgConfig) {
                let cfg = forceFgConfig[name]
                widgetsModel.set(i, {"method": cfg.method})
            }
        }
        loaded = true
    }

    header: RowLayout {
        RowLayout {
            Layout.leftMargin: Kirigami.Units.mediumSpacing
            Layout.rightMargin: Kirigami.Units.smallSpacing
            RowLayout {
                Layout.alignment: Qt.AlignRight
                Label {
                    text: i18n("Enabled:")
                }
                CheckBox {
                    id: fgColorEnabled
                }
            }
            Item {
                Layout.fillWidth: true
            }
            RowLayout {
                Layout.alignment: Qt.AlignRight
                Label {
                    text: i18n("Last preset loaded:")
                }
                Label {
                    text: "None"
                    font.weight: Font.DemiBold
                }
            }
        }
    }

    ColumnLayout {
    Kirigami.FormLayout {
        // enabled: cfg_fgColorEnabled
        // visible: cfg_isEnabled

        // CheckBox {
        //     Kirigami.FormData.label: i18n("Fix custom badges:")
        //     id: fixCustomBadgesCheckbox
        //     checked: cfg_fixCustomBadges
        //     onCheckedChanged: cfg_fixCustomBadges = checked
        // }

        // Label {
        //     text: i18n("Fix unreadable custom badges (e.g. counters) drawn by some widgets.")
        //     opacity: 0.7
        //     Layout.maximumWidth: 400
        //     wrapMode: Text.Wrap
        // }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Force Text/Icon color")
        }

        Label {
            text: i18n("<strong>Mask</strong>: Force Icon colorization.<br><strong>Effect</strong>: Force Icons/Text colorization using post-processing effect.<br>To restore the original color disable and restart Plasma or logout.")
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
                    onUpdateWidget: (maskEnabled, effectEnabled) => {
                        if (!loaded) return
                        widgetsModel.set(index,
                        {
                            "method":{ "mask": maskEnabled, "multiEffect": effectEnabled}
                        })
                        root.updateConfig()
                    }
                }
            }
        }
    }
    }
    Components.CategoryDisabled {
        visible: !cfg_isEnabled
    }
}

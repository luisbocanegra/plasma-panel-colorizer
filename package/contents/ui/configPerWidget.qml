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
    id:root
    property bool cfg_isEnabled
    property string cfg_panelWidgets
    property bool clearing: false
    property string cfg_allSettings
    property var config: JSON.parse(cfg_allSettings)
    property var perWidgetConfig
    property bool loaded: false
    property string overrideName
    property var editingConfig
    property bool showingConfig: false
    property bool userInput: false
    property var configOverrides
    property var associationsModel

    Component.onCompleted: {
        perWidgetConfig = config.configurationOverrides
        configOverrides = JSON.parse(JSON.stringify(config.configurationOverrides))
        associationsModel = JSON.parse(JSON.stringify(config.overrideAssociations))
        initWidgets()
        updateWidgetsModel()
    }

    Timer {
        id: readTimer
        interval: 100
        onTriggered: {
            initWidgets()
            updateWidgetsModel()
        }
    }

    function updateConfig() {
        for (let i = 0; i < widgetsModel.count; i++) {
            const widget = widgetsModel.get(i)
            const name = widget.name
            const method = widget.method
            console.error(name, method.mask, method.multiEffect)
            if (method.mask || method.multiEffect) {
                perWidgetConfig[name] = {"method": widget.method}
            } else {
                delete perWidgetConfig[widget.name]
            }
        }
        const tmp = JSON.parse(JSON.stringify(configOverrides, null, null))
        // configOverrides = []
        configOverrides = tmp
        config.configurationOverrides = configOverrides
        cfg_allSettings = JSON.stringify(config, null, null)
    }

    function updateConfigA() {
        config.overrideAssociations = associationsModel
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
            const inTray = widget.inTray
            widgetsModel.append({
                "name": name, "title": title, "icon": icon, "inTray":inTray,
                "method": { "mask":false, "multiEffect": false }
            })
        }
    }

    function updateWidgetsModel(){
        for (let i = 0; i < widgetsModel.count; i++) {
            const widget = widgetsModel.get(i)
            const name = widget.name
            if (name in perWidgetConfig) {
                let cfg = perWidgetConfig[name]
                widgetsModel.set(i, {"method": cfg.method})
            }
        }
        loaded = true
    }

    header: RowLayout {
        RowLayout {
            Layout.leftMargin: Kirigami.Units.mediumSpacing
            Layout.rightMargin: Kirigami.Units.smallSpacing
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

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Configuration overrides")
        }

        Label {
            text: i18n("Create configuration overrides and apply them to one or multiple widgets.")
            opacity: 0.7
            Layout.maximumWidth: presetCards.width
            wrapMode: Text.Wrap
        }

        ColumnLayout {
            id: presetCards
            Layout.minimumWidth: 500
            Repeater {
                model: Object.keys(root.configOverrides)
                delegate: Kirigami.AbstractCard {
                    visible: modelData !== "-"
                    checked: editBtn.checked
                    contentItem: RowLayout {
                        Label {
                            text: (index+1).toString()+"."
                            font.bold: true
                        }
                        ColumnLayout {
                            Label {
                                text: modelData
                                elide: Text.ElideRight
                            }
                        }
                        Item {
                            Layout.fillWidth: true
                        }
                        Button {
                            id: editBtn
                            icon.name: "document-edit-symbolic"
                            text: i18n("Edit")
                            checkable: true
                            checked: overrideName === modelData && userInput
                            onClicked: {
                                userInput = true
                            }
                            onCheckedChanged: {
                                if (checked || overrideName === modelData)
                                overrideName = modelData
                                showingConfig = checked
                            }
                        }
                        Button {
                            text: i18n("Delete")
                            icon.name: "edit-delete-remove-symbolic"
                            onClicked: {
                                delete configOverrides[modelData]
                                root.updateConfig()
                            }
                        }
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
                        configOverrides[`Override ${Object.keys(configOverrides).length+1}`] = Globals.baseOverrideConfig
                        root.updateConfig()
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
                        text: "Apply"
                        onClicked: {
                            configOverrides[nameField.text] = configOverrides[overrideName]
                            delete configOverrides[overrideName]
                            overrideName = nameField.text
                            root.updateConfig()
                        }
                    }
                }
                RowLayout {
                    Kirigami.FormData.label: i18n("Fallback:")
                    CheckBox {
                        checked: configOverrides[overrideName].disabledFallback
                        onCheckedChanged: {
                            configOverrides[overrideName].disabledFallback = checked
                            root.updateConfig()
                        }
                    }
                    Button {
                        icon.name: "dialog-information-symbolic"
                        ToolTip.text: i18n("Fallback to the global widget settings for disabled options, except for <b>Enable</b>.")
                        highlighted: true
                        hoverEnabled: true
                        ToolTip.visible: hovered
                        Kirigami.Theme.inherit: false
                        flat: true
                    }
                }
            }
            Loader {
                id: componentLoader
                sourceComponent: showingConfig ? settingsComp : null
                onLoaded: {
                    item.config = configOverrides[overrideName]
                    item.onUpdateConfigString.connect((newString, config) => {
                        configOverrides[overrideName] = config
                        root.updateConfig()
                    })
                }
            }

            Component {
                id: settingsComp
                Components.FormPerWidgetSettings {
                    currentTab: 0
                    handleString: false
                    keyName: "configuration"
                }
            }
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Widgets")
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
                    onUpdateWidget: (name, text) => {
                        if (!loaded) return
                        associationsModel[name] = text
                        root.updateConfigA()
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

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
    id:root
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
    property string configDir: StandardPaths.writableLocation(
                    StandardPaths.HomeLocation).toString().substring(7) + "/.config/panel-colorizer/"
    property string importCmd: "cat '" + configDir + "overrides.json'"
    property string crateConfigDirCmd: "mkdir -p " + configDir

    Component.onCompleted: {
        configOverrides = JSON.parse(JSON.stringify(config.overrides))
        associationsModel = JSON.parse(JSON.stringify(config.associations))
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
                configOverrides[name] = {"method": widget.method}
            } else {
                delete configOverrides[widget.name]
            }
        }
        const tmp = JSON.parse(JSON.stringify(configOverrides, null, null))
        // configOverrides = []
        configOverrides = tmp
        config.overrides = configOverrides
        config.associations = associationsModel
        cfg_configurationOverrides = JSON.stringify(config, null, null)
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
        configOverrides = newConfig.overrides
        configOverrides = newConfig.overrides
        associationsModel = newConfig.associations
        updateWidgetsModel()
        updateConfig()
        loaded = true
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
            if (name in configOverrides) {
                let cfg = configOverrides[name]
                widgetsModel.set(i, {"method": cfg.method})
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
        Components.SettingImportExport {
            onExportConfirmed: {
                runCommand.run(crateConfigDirCmd)
                    runCommand.run("echo '"+cfg_configurationOverrides+"' > '" + configDir + "overrides.json'")
            }
            onImportConfirmed: runCommand.run(importCmd)
        }

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
                        checked: configOverrides[overrideName]?.disabledFallback || false
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
                    item.currentTab = root.currentTab
                    item.tabChanged.connect((currentTab) => {
                        root.currentTab = currentTab
                    })
                }
            }

            Component {
                id: settingsComp
                Components.FormWidgetSettings {}
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
                        root.updateConfig()
                    }
                }
            }
        }
    }
    }
}

import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import org.kde.plasma.plasma5support as P5Support
import "../code/utils.js" as Utils
import "../code/globals.js" as Globals

ColumnLayout {
    id: backgroundRoot
    property bool isSection: true
    // wether read from the string or existing config object
    property bool handleString: false
    // key to extract config from
    property string keyName
    property string keyFriendlyName
    // internal config objects to be sent, both string and json
    property string configString: "{}"
    property var config: handleString ? JSON.parse(configString) : undefined
    property var configLocal: keyName ? config[keyName] : config
    signal updateConfigString(configString: string, config: var)

    property alias isEnabled: isEnabled.checked

    property int currentTab

    signal tabChanged(currentTab: int)

    onCurrentTabChanged: {
        tabChanged(currentTab)
    }

    property bool showBlurMessage: false

    property var followVisbility: {
        "background": {
            "panel": false,
            "widget": false,
            "tray": false
        },
        "foreground": {
            "panel": false,
            "widget": false,
            "tray": false
        },
    }

    function updateConfig() {
        if (keyName) {
            config[keyName] = configLocal
        } else {
            config = configLocal
        }
        configString = JSON.stringify(config, null, null)
        // console.error(configString)
        updateConfigString(configString, config)
        // console.error(JSON.stringify(configLocal, null, null))
    }

    RowLayout {
        Layout.leftMargin: Kirigami.Units.mediumSpacing
        Layout.rightMargin: Kirigami.Units.smallSpacing
        Layout.bottomMargin: Kirigami.Units.smallSpacing
        ColumnLayout {

            RowLayout {
                // Layout.alignment: Qt.AlignRight
                Label {
                    text: i18n("Enable") + " " + keyFriendlyName + " " + i18n("customization") + ":"
                }
                CheckBox {
                    id: isEnabled
                    checked: configLocal.enabled
                    onCheckedChanged: {
                        configLocal.enabled = checked
                        updateConfig()
                    }
                }
            }
            RowLayout {
                visible: keyName === "panel"
                Label {
                    text: i18n("Native panel background:")
                }
                CheckBox {
                    id: nativePanelBackgroundCheckbox
                    checked: config.nativePanelBackground.enabled
                    onCheckedChanged: {
                        config.nativePanelBackground.enabled = checked
                        updateConfig()
                    }
                }
                Kirigami.ContextualHelpButton {
                    toolTipText: i18n("Disable to make panel fully transparent, removes contrast and blur effects.")
                }
            }
            RowLayout {
                visible: keyName === "panel"
                Label {
                    text: i18n("Panel Opacity:")
                }
                SpinBoxDecimal {
                    Layout.preferredWidth: backgroundRoot.Kirigami.Units.gridUnit * 5
                    from: 0
                    to: 1
                    value: config.nativePanelBackground.opacity ?? 0
                    onValueChanged: {
                        config.nativePanelBackground.opacity = value
                        updateConfig()
                    }
                    enabled: nativePanelBackgroundCheckbox.checked
                }
                Kirigami.ContextualHelpButton {
                    toolTipText: i18n("Set Opacity to 0 to keep just the mask required by Blur custom background.")
                }
            }
            RowLayout {
                Label {
                    text: i18n("Blur custom background (Beta):")
                }
                CheckBox {
                    id: blurCheckbox
                    checked: configLocal.blurBehind
                    onCheckedChanged: {
                        configLocal.blurBehind = checked
                        if (checked) {
                        }
                        updateConfig()
                    }
                    enabled: isEnabled.checked
                }
                Button {
                    checkable: true
                    checked: showBlurMessage
                    onClicked: {
                        showBlurMessage = !showBlurMessage
                    }
                    text: i18n("Not working? Read this (click to show)")
                }
            }
            Kirigami.InlineMessage {
                id: warningResources
                Layout.fillWidth: true
                text: i18n("Draw a custom blur mask behind the custom background(s).<br>Requires the C++ plugin to work, check the repository README on GitHub for details.<br><strong>Native panel background must be enabled with opacity of 0 for this to work as intended.</strong>")
                visible: showBlurMessage
                actions: [
                    Kirigami.Action {
                        icon.name: "view-readermode-symbolic"
                        text: "Plugin install instructions"
                        onTriggered: {
                            Qt.openUrlExternally("https://github.com/luisbocanegra/plasma-panel-colorizer?tab=readme-ov-file#manually")
                        }
                    }
                ]
            }
        }
    }


    Kirigami.NavigationTabBar {
        // Layout.preferredWidth: root.parent.width
        // Layout.minimumWidth: root.parent.width
        enabled: backgroundRoot.isEnabled
        Layout.fillWidth: true
        maximumContentWidth: {
            const minDelegateWidth = Kirigami.Units.gridUnit * 6;
            // Always have at least the width of 5 items, so that small amounts of actions look natural.
            return minDelegateWidth * Math.max(visibleActions.length, 5);
        }
        actions: [
            Kirigami.Action {
                icon.name: "color-picker"
                text: "Color"
                checked: currentTab === 0
                onTriggered: currentTab = 0
            },
            Kirigami.Action {
                icon.name: "rectangle-shape-symbolic"
                text: "Shape"
                checked: currentTab === 1
                onTriggered: currentTab = 1
            },
            Kirigami.Action {
                icon.name: "bordertool-symbolic"
                text: "Border"
                checked: currentTab === 2
                onTriggered: currentTab = 2
            },
            Kirigami.Action {
                icon.name: "kstars_horizon-symbolic"
                text: "Shadow"
                checked: currentTab === 3
                onTriggered: currentTab = 3
            }
        ]
    }

    Kirigami.FormLayout {
        enabled: backgroundRoot.isEnabled
        // required to align with parent form
        property alias formLayout: backgroundRoot
        twinFormLayouts: parentLayout
        Layout.fillWidth: true

        SpinBox {
            Kirigami.FormData.label: i18n("Spacing:")
            id: spacingCheckbox
            value: configLocal.spacing || 0
            from: 0
            to: 999
            visible: keyName === "widgets" && currentTab === 1
            enabled: visible
            onValueModified: {
                if (!enabled) return
                configLocal.spacing = value
                updateConfig()
            }
        }
    }

    FormColors {
        enabled: backgroundRoot.isEnabled
        visible: currentTab === 0
        config: backgroundRoot.configLocal.backgroundColor
        onUpdateConfigString: (newString, newConfig) => {
            backgroundRoot.configLocal.backgroundColor = newConfig
            backgroundRoot.updateConfig()
        }
        followOptions: followVisbility.background
        sectionName: i18n("Background Color")
    }

    FormColors {
        enabled: backgroundRoot.isEnabled
        // the panel does not support foreground customization
        visible: currentTab === 0 && keyName !== "panel"
        config: backgroundRoot.configLocal.foregroundColor
        isSection: true
        onUpdateConfigString: (newString, newConfig) => {
            backgroundRoot.configLocal.foregroundColor = newConfig
            backgroundRoot.updateConfig()
        }
        followOptions: followVisbility.foreground
        sectionName: i18n("Foreground Color")
    }

    FormShape {
        enabled: backgroundRoot.isEnabled
        visible: currentTab === 1
        config: backgroundRoot.configLocal
        onUpdateConfigString: (newString, newConfig) => {
            backgroundRoot.configLocal = newConfig
            backgroundRoot.updateConfig()
        }
    }

    FormPadding {
        enabled: backgroundRoot.isEnabled
        visible: currentTab === 1 && keyName === "panel"
        config: backgroundRoot.configLocal
        onUpdateConfigString: (newString, newConfig) => {
            backgroundRoot.configLocal = newConfig
            backgroundRoot.updateConfig()
        }
    }

    FormBorder {
        enabled: backgroundRoot.isEnabled
        visible: currentTab === 2
        config: backgroundRoot.configLocal
        onUpdateConfigString: (newString, newConfig) => {
            backgroundRoot.configLocal = newConfig
            backgroundRoot.updateConfig()
        }
    }

    FormColors {
        enabled: backgroundRoot.isEnabled
        visible: currentTab === 2
        config: backgroundRoot.configLocal.border.color
        onUpdateConfigString: (newString, newConfig) => {
            backgroundRoot.configLocal.border.color = newConfig
            backgroundRoot.updateConfig()
        }
        followOptions: followVisbility.foreground
    }

    FormShadow {
        enabled: backgroundRoot.isEnabled
        visible: currentTab === 3
        config: backgroundRoot.configLocal.shadow.background
        onUpdateConfigString: (newString, newConfig) => {
            backgroundRoot.configLocal.shadow.background = newConfig
            backgroundRoot.updateConfig()
        }
        sectionName: i18n("Background Shadow")
    }

    FormColors {
        enabled: backgroundRoot.isEnabled
        visible: currentTab === 3
        config: backgroundRoot.configLocal.shadow.background.color
        onUpdateConfigString: (newString, newConfig) => {
            backgroundRoot.configLocal.shadow.background.color = newConfig
            backgroundRoot.updateConfig()
        }
        isSection: false
        followOptions: followVisbility.foreground
        sectionName: i18n("Background Shadow Color")
    }

    FormShadow {
        enabled: backgroundRoot.isEnabled
        visible: currentTab === 3 && keyName !== "panel"
        config: backgroundRoot.configLocal.shadow.foreground
        onUpdateConfigString: (newString, newConfig) => {
            backgroundRoot.configLocal.shadow.foreground = newConfig
            backgroundRoot.updateConfig()
        }
        sectionName: i18n("Foreground Shadow")
    }

    FormColors {
        enabled: backgroundRoot.isEnabled
        visible: currentTab === 3 && keyName !== "panel"
        config: backgroundRoot.configLocal.shadow.foreground.color
        onUpdateConfigString: (newString, newConfig) => {
            backgroundRoot.configLocal.shadow.foreground.color = newConfig
            backgroundRoot.updateConfig()
        }
        isSection: false
        followOptions: followVisbility.foreground
        sectionName: i18n("Foreground Shadow Color")
    }
}

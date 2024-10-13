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
    // internal config objects to be sent, both string and json
    property string configString: "{}"
    property var config: handleString ? JSON.parse(configString) : undefined
    property var configLocal: keyName ? config[keyName] : config
    signal updateConfigString(configString: string, config: var)
    // whether the current item supports foreground customization, e.g the panel does not
    property bool supportsForeground: true

    property alias isEnabled: isEnabled.checked

    property int currentTab

    signal tabChanged(currentTab: int)

    onCurrentTabChanged: {
        tabChanged(currentTab)
    }

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
                    text: i18n("Enable:")
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
                Label {
                    text: i18n("Blur behind (Beta):")
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
                Kirigami.ContextualHelpButton {
                    toolTipText: i18n("Draw a custom blur mask behind the custom background(s).\n\nRequires the C++ plugin to work, check the repository README on GitHub for details.\n\nNative panel background must be enabled with opacity of 0 for this to work as intended.")
                }
            }
            RowLayout {
                property bool isPanel: keyName === "panel"
                visible: isPanel
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
                Label {
                    text: i18n("Opacity:")
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
                }
                Kirigami.ContextualHelpButton {
                    toolTipText: i18n("Disabling the native Panel background also removes the contrast and blur.\n\nSet this to 0 to keep just the mask required by Blur behind.")
                }
            }
        }
        Item {
            Layout.fillWidth: true
        }
        RowLayout {
            Layout.alignment: Qt.AlignRight|Qt.AlignTop
            Label {
                text: i18n("Last preset loaded:")
            }
            Label {
                text: "None"
                font.weight: Font.DemiBold
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
                icon.name: "globe"
                text: "Color"
                checked: currentTab === 0
                onTriggered: currentTab = 0
            },
            Kirigami.Action {
                icon.name: "globe"
                text: "Shape"
                checked: currentTab === 1
                onTriggered: currentTab = 1
            },
            Kirigami.Action {
                icon.name: "globe"
                text: "Border"
                checked: currentTab === 2
                onTriggered: currentTab = 2
            },
            Kirigami.Action {
                icon.name: "globe"
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
        visible: currentTab === 0 && supportsForeground
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

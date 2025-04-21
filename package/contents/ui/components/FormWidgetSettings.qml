import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid

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
    property alias isEnabled: isEnabled.checked
    property int currentTab
    property var panelColorizer: null
    property bool ready: false
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
        }
    }

    signal updateConfigString(string configString, var config)
    signal tabChanged(int currentTab)

    function updateConfig() {
        Qt.callLater(() => {
            if (keyName)
                config[keyName] = configLocal;
            else
                config = configLocal;
            configString = JSON.stringify(config, null, null);
            updateConfigString(configString, config);
        });
    }

    onCurrentTabChanged: {
        tabChanged(currentTab);
    }
    Component.onCompleted: {
        Qt.callLater(() => {
            try {
                panelColorizer = Qt.createQmlObject("import org.kde.plasma.panelcolorizer 1.0; PanelColorizer { id: panelColorizer }", backgroundRoot);
                console.error("QML Plugin org.kde.plasma.panelcolorizer loaded");
            } catch (err) {
                console.error("QML Plugin org.kde.plasma.panelcolorizer not found");
            }
            ready = true;
        });
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
                        configLocal.enabled = checked;
                        updateConfig();
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
                        config.nativePanelBackground.enabled = checked;
                        updateConfig();
                    }
                }

                Kirigami.ContextualHelpButton {
                    toolTipText: i18n("Disable to make panel fully transparent, removes contrast and blur effects.")
                }
            }

            RowLayout {
                visible: keyName === "panel"
                enabled: nativePanelBackgroundCheckbox.checked

                Label {
                    text: i18n("Native panel background shadow:")
                }

                CheckBox {
                    id: nativePanelBackgroundShadowCheckbox

                    checked: config.nativePanelBackground.shadow
                    onCheckedChanged: {
                        config.nativePanelBackground.shadow = checked;
                        updateConfig();
                    }
                }
            }

            RowLayout {
                visible: keyName === "panel"
                enabled: nativePanelBackgroundCheckbox.checked

                Label {
                    text: i18n("Native panel background opacity:")
                }

                SpinBoxDecimal {
                    Layout.preferredWidth: backgroundRoot.Kirigami.Units.gridUnit * 5
                    from: 0
                    to: 1
                    value: config.nativePanelBackground.opacity ?? 0
                    onValueChanged: {
                        config.nativePanelBackground.opacity = value;
                        updateConfig();
                    }
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
                        configLocal.blurBehind = checked;
                        updateConfig();
                    }
                    enabled: isEnabled.checked
                }

                Kirigami.ContextualHelpButton {
                    toolTipText: i18n("Draw a custom blur mask behind the custom background(s).<br><strong>Native panel background must be enabled with opacity of 0 for this to work as intended.</strong>")
                }
            }

            Kirigami.InlineMessage {
                id: warningResources

                Layout.fillWidth: true
                text: i18n("C++ plugin not installed, <b>Blur custom background</b> will not work.<br>Check the repository README on GitHub for details.")
                visible: backgroundRoot.panelColorizer === null && backgroundRoot.ready
                type: Kirigami.MessageType.Warning
                actions: [
                    Kirigami.Action {
                        icon.name: "view-readermode-symbolic"
                        text: "Plugin install instructions"
                        onTriggered: {
                            Qt.openUrlExternally("https://github.com/luisbocanegra/plasma-panel-colorizer?tab=readme-ov-file#manually");
                        }
                    }
                ]
            }

            RowLayout {
                Label {
                    text: i18n("Force floating dialogs:")
                }

                CheckBox {
                    checked: configLocal.floatingDialogs
                    onCheckedChanged: {
                        configLocal.floatingDialogs = checked;
                        updateConfig();
                    }
                }
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
        // required to align with parent form
        property alias formLayout: backgroundRoot

        enabled: backgroundRoot.isEnabled
        twinFormLayouts: parentLayout
        Layout.fillWidth: true

        RowLayout {
            Kirigami.FormData.label: i18n("Spacing:")
            visible: keyName === "widgets" && currentTab === 1

            SpinBox {
                id: spacingCheckbox

                value: configLocal.spacing || 0
                from: 0
                to: 999
                onValueModified: {
                    if (!enabled)
                        return;

                    configLocal.spacing = value;
                    updateConfig();
                }
            }

            Button {
                visible: spacingCheckbox.value % 2 !== 0 && spacingCheckbox.visible
                icon.name: "dialog-warning-symbolic"
                ToolTip.text: i18n("<strong>Odd</strong> values are automatically converted to <strong>evens</strong> if <strong>Unified Background</strong> feature is used.")
                highlighted: true
                hoverEnabled: true
                ToolTip.visible: hovered
            }
        }
    }

    FormColors {
        enabled: backgroundRoot.isEnabled
        visible: currentTab === 0
        config: backgroundRoot.configLocal.backgroundColor
        onUpdateConfigString: (newString, newConfig) => {
            backgroundRoot.configLocal.backgroundColor = newConfig;
            backgroundRoot.updateConfig();
        }
        followOptions: followVisbility.background
        sectionName: i18n("Background Color")
        multiColor: keyName !== "panel"
        supportsGradient: true
        supportsImage: true
    }

    FormColors {
        enabled: backgroundRoot.isEnabled
        // the panel does not support foreground customization
        visible: currentTab === 0 && keyName !== "panel"
        config: backgroundRoot.configLocal.foregroundColor
        isSection: true
        onUpdateConfigString: (newString, newConfig) => {
            backgroundRoot.configLocal.foregroundColor = newConfig;
            backgroundRoot.updateConfig();
        }
        followOptions: followVisbility.foreground
        sectionName: i18n("Foreground Color")
    }

    FormShape {
        enabled: backgroundRoot.isEnabled
        visible: currentTab === 1
        config: backgroundRoot.configLocal
        onUpdateConfigString: (newString, newConfig) => {
            backgroundRoot.configLocal = newConfig;
            backgroundRoot.updateConfig();
        }
    }

    FormPadding {
        enabled: backgroundRoot.isEnabled
        visible: currentTab === 1 && keyName === "panel"
        config: backgroundRoot.configLocal
        onUpdateConfigString: (newString, newConfig) => {
            backgroundRoot.configLocal = newConfig;
            backgroundRoot.updateConfig();
        }
    }

    FormBorder {
        isSection: true
        sectionName: i18n("Primary Border")
        enabled: backgroundRoot.isEnabled
        visible: currentTab === 2
        config: backgroundRoot.configLocal.border
        onUpdateConfigString: (newString, newConfig) => {
            backgroundRoot.configLocal.border = newConfig;
            backgroundRoot.updateConfig();
        }
    }

    FormColors {
        isSection: false
        enabled: backgroundRoot.isEnabled
        visible: currentTab === 2
        config: backgroundRoot.configLocal.border.color
        onUpdateConfigString: (newString, newConfig) => {
            backgroundRoot.configLocal.border.color = newConfig;
            backgroundRoot.updateConfig();
        }
        followOptions: followVisbility.foreground
    }

    FormBorder {
        isSection: true
        sectionName: i18n("Secondary Border")
        enabled: backgroundRoot.isEnabled
        visible: currentTab === 2
        config: backgroundRoot.configLocal.borderSecondary
        onUpdateConfigString: (newString, newConfig) => {
            backgroundRoot.configLocal.borderSecondary = newConfig;
            backgroundRoot.updateConfig();
        }
    }

    FormColors {
        isSection: false
        enabled: backgroundRoot.isEnabled
        visible: currentTab === 2
        config: backgroundRoot.configLocal.borderSecondary.color
        onUpdateConfigString: (newString, newConfig) => {
            backgroundRoot.configLocal.borderSecondary.color = newConfig;
            backgroundRoot.updateConfig();
        }
        followOptions: followVisbility.foreground
    }

    FormShadow {
        enabled: backgroundRoot.isEnabled
        visible: currentTab === 3
        config: backgroundRoot.configLocal.shadow.background
        onUpdateConfigString: (newString, newConfig) => {
            backgroundRoot.configLocal.shadow.background = newConfig;
            backgroundRoot.updateConfig();
        }
        sectionName: i18n("Background Shadow")
    }

    FormColors {
        enabled: backgroundRoot.isEnabled
        visible: currentTab === 3
        config: backgroundRoot.configLocal.shadow.background.color
        onUpdateConfigString: (newString, newConfig) => {
            backgroundRoot.configLocal.shadow.background.color = newConfig;
            backgroundRoot.updateConfig();
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
            backgroundRoot.configLocal.shadow.foreground = newConfig;
            backgroundRoot.updateConfig();
        }
        sectionName: i18n("Foreground Shadow")
    }

    FormColors {
        enabled: backgroundRoot.isEnabled
        visible: currentTab === 3 && keyName !== "panel"
        config: backgroundRoot.configLocal.shadow.foreground.color
        onUpdateConfigString: (newString, newConfig) => {
            backgroundRoot.configLocal.shadow.foreground.color = newConfig;
            backgroundRoot.updateConfig();
        }
        isSection: false
        followOptions: followVisbility.foreground
        sectionName: i18n("Foreground Shadow Color")
    }
}

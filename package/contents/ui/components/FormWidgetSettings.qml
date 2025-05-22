import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import "../code/enum.js" as Enum

ColumnLayout {
    id: root

    property bool isSection: true
    // wether read from the string or existing config object
    property bool handleString: false
    // key to extract config from
    property string elementName
    property string elementFriendlyName

    property int elementState: Enum.WidgetStates.Normal
    property string stateFriendlyName

    // internal config objects to be sent, both string and json
    property string configString: "{}"
    property var config: handleString ? JSON.parse(configString) : undefined

    property string stateName: {
        if (elementState === Enum.WidgetStates.Normal) {
            return "normal";
        } else if (elementState === Enum.WidgetStates.Busy) {
            return "busy";
        } else if (elementState === Enum.WidgetStates.NeedsAttention) {
            return "needsAttention";
        } else if (elementState === Enum.WidgetStates.Hovered) {
            return "hovered";
        } else if (elementState === Enum.WidgetStates.Expanded) {
            return "expanded";
        }
        return "";
    }

    property var configLocal: elementName ? config[elementName][stateName] : config[stateName]

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
            if (elementName) {
                config[elementName][stateName] = configLocal;
            } else {
                config[stateName] = configLocal;
            }
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
                panelColorizer = Qt.createQmlObject("import org.kde.plasma.panelcolorizer 1.0; PanelColorizer { id: panelColorizer }", root);
                console.error("QML Plugin org.kde.plasma.panelcolorizer loaded");
            } catch (err) {
                console.error("QML Plugin org.kde.plasma.panelcolorizer not found");
            }
            ready = true;
        });
    }

    Kirigami.FormLayout {
        // required to align with parent form
        property alias formLayout: root
        twinFormLayouts: parentLayout
        Layout.fillWidth: true

        RowLayout {
            Kirigami.FormData.label: i18n("State:")
            ComboBox {
                id: targetState
                textRole: "name"
                valueRole: "value"
                onActivated: {
                    if (currentValue !== root.elementState && root.ready) {
                        root.elementState = currentValue;
                    }
                }

                currentIndex: {
                    let newValue = indexOfValue(root.elementState);
                    return newValue !== -1 ? newValue : 0;
                }

                onOptionsChanged: {
                    model = options;
                    if (root.ready) {
                        let newValue = indexOfValue(root.elementState);
                        currentIndex = newValue !== -1 ? newValue : 0;
                    }
                }

                property var options: {
                    let options = [
                        {
                            "name": i18n("Normal"),
                            "value": Enum.WidgetStates.Normal
                        },
                        {
                            "name": i18n("Hover"),
                            "value": Enum.WidgetStates.Hovered
                        }
                    ];
                    if (root.elementName !== "panel") {
                        options = options.concat([
                            {
                                "name": i18n("Expanded"),
                                "value": Enum.WidgetStates.Expanded
                            },
                            {
                                "name": i18n("Needs attention"),
                                "value": Enum.WidgetStates.NeedsAttention
                            },
                            {
                                "name": i18n("Busy"),
                                "value": Enum.WidgetStates.Busy
                            }
                        ]);
                    }
                    return options;
                }
                model: options
            }
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Native panel:")
            visible: elementName === "panel"
            CheckBox {
                id: nativePanelBackgroundCheckbox
                text: i18n("Background")
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

        CheckBox {
            id: nativePanelBackgroundShadowCheckbox
            text: i18n("Shadow")
            visible: elementName === "panel"
            enabled: nativePanelBackgroundCheckbox.checked

            checked: config.nativePanelBackground.shadow
            onCheckedChanged: {
                config.nativePanelBackground.shadow = checked;
                updateConfig();
            }
        }

        RowLayout {
            visible: elementName === "panel"
            Label {
                text: i18n("Opacity:")
            }
            SpinBoxDecimal {
                enabled: nativePanelBackgroundCheckbox.checked
                Layout.preferredWidth: root.Kirigami.Units.gridUnit * 5
                from: 0
                to: 1
                value: config.nativePanelBackground.opacity ?? 0
                onValueChanged: {
                    config.nativePanelBackground.opacity = value;
                    updateConfig();
                }
            }
            Kirigami.ContextualHelpButton {
                toolTipText: i18n("Set to 0 to keep the mask required for custom background blur.")
            }
        }

        CheckBox {
            visible: elementName === "panel" && root.elementState === Enum.WidgetStates.Normal
            text: i18n("Force floating dialogs")
            checked: configLocal.floatingDialogs
            onCheckedChanged: {
                configLocal.floatingDialogs = checked;
                updateConfig();
            }
        }

        CheckBox {
            id: isEnabled
            Kirigami.FormData.label: elementFriendlyName + " " + i18n("customization") + ":"
            checked: configLocal.enabled
            onCheckedChanged: {
                configLocal.enabled = checked;
                updateConfig();
            }
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Blur custom background (Beta)")
            CheckBox {
                id: blurCheckbox
                enabled: isEnabled.checked

                checked: configLocal.blurBehind
                onCheckedChanged: {
                    configLocal.blurBehind = checked;
                    updateConfig();
                }
            }

            Kirigami.ContextualHelpButton {
                toolTipText: i18n("Draw a custom blur mask behind the custom background(s).<br><strong>Native panel background must be enabled with opacity of 0 for this to work as intended.</strong>")
            }
        }

        Kirigami.InlineMessage {
            id: warningResources

            Layout.fillWidth: true
            text: i18n("C++ plugin not installed, <b>Blur custom background</b> will not work.<br>Check the repository README on GitHub for details.")
            visible: root.panelColorizer === null && root.ready
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
    }

    Kirigami.NavigationTabBar {
        // Layout.preferredWidth: root.parent.width
        // Layout.minimumWidth: root.parent.width
        enabled: root.isEnabled
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
        property alias formLayout: root
        twinFormLayouts: parentLayout
        Layout.fillWidth: true

        enabled: root.isEnabled

        RowLayout {
            Kirigami.FormData.label: i18n("Spacing:")
            visible: elementName === "widgets" && currentTab === 1 && root.elementState === Enum.WidgetStates.Normal

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
        enabled: root.isEnabled
        visible: currentTab === 0
        config: root.configLocal.backgroundColor
        onUpdateConfigString: (newString, newConfig) => {
            root.configLocal.backgroundColor = newConfig;
            root.updateConfig();
        }
        followOptions: followVisbility.background
        sectionName: i18n("Background Color")
        multiColor: elementName !== "panel"
        supportsGradient: true
        supportsImage: true
    }

    FormColors {
        enabled: root.isEnabled
        // the panel does not support foreground customization
        visible: currentTab === 0 && elementName !== "panel"
        config: root.configLocal.foregroundColor
        isSection: true
        onUpdateConfigString: (newString, newConfig) => {
            root.configLocal.foregroundColor = newConfig;
            root.updateConfig();
        }
        followOptions: followVisbility.foreground
        sectionName: i18n("Foreground Color")
    }

    FormShape {
        enabled: root.isEnabled
        visible: currentTab === 1
        config: root.configLocal
        onUpdateConfigString: (newString, newConfig) => {
            root.configLocal = newConfig;
            root.updateConfig();
        }
    }

    FormPadding {
        enabled: root.isEnabled
        visible: currentTab === 1 && elementName === "panel"
        config: root.configLocal
        onUpdateConfigString: (newString, newConfig) => {
            root.configLocal = newConfig;
            root.updateConfig();
        }
    }

    FormBorder {
        isSection: true
        sectionName: i18n("Primary Border")
        enabled: root.isEnabled
        visible: currentTab === 2
        config: root.configLocal.border
        onUpdateConfigString: (newString, newConfig) => {
            root.configLocal.border = newConfig;
            root.updateConfig();
        }
    }

    FormColors {
        isSection: false
        enabled: root.isEnabled
        visible: currentTab === 2
        config: root.configLocal.border.color
        onUpdateConfigString: (newString, newConfig) => {
            root.configLocal.border.color = newConfig;
            root.updateConfig();
        }
        followOptions: followVisbility.foreground
    }

    FormBorder {
        isSection: true
        sectionName: i18n("Secondary Border")
        enabled: root.isEnabled
        visible: currentTab === 2
        config: root.configLocal.borderSecondary
        onUpdateConfigString: (newString, newConfig) => {
            root.configLocal.borderSecondary = newConfig;
            root.updateConfig();
        }
    }

    FormColors {
        isSection: false
        enabled: root.isEnabled
        visible: currentTab === 2
        config: root.configLocal.borderSecondary.color
        onUpdateConfigString: (newString, newConfig) => {
            root.configLocal.borderSecondary.color = newConfig;
            root.updateConfig();
        }
        followOptions: followVisbility.foreground
    }

    FormShadow {
        enabled: root.isEnabled
        visible: currentTab === 3
        config: root.configLocal.shadow.background
        onUpdateConfigString: (newString, newConfig) => {
            root.configLocal.shadow.background = newConfig;
            root.updateConfig();
        }
        sectionName: i18n("Background Shadow")
    }

    FormColors {
        enabled: root.isEnabled
        visible: currentTab === 3
        config: root.configLocal.shadow.background.color
        onUpdateConfigString: (newString, newConfig) => {
            root.configLocal.shadow.background.color = newConfig;
            root.updateConfig();
        }
        isSection: false
        followOptions: followVisbility.foreground
        sectionName: i18n("Background Shadow Color")
    }

    FormShadow {
        enabled: root.isEnabled
        visible: currentTab === 3 && elementName !== "panel"
        config: root.configLocal.shadow.foreground
        onUpdateConfigString: (newString, newConfig) => {
            root.configLocal.shadow.foreground = newConfig;
            root.updateConfig();
        }
        sectionName: i18n("Foreground Shadow")
    }

    FormColors {
        enabled: root.isEnabled
        visible: currentTab === 3 && elementName !== "panel"
        config: root.configLocal.shadow.foreground.color
        onUpdateConfigString: (newString, newConfig) => {
            root.configLocal.shadow.foreground.color = newConfig;
            root.updateConfig();
        }
        isSection: false
        followOptions: followVisbility.foreground
        sectionName: i18n("Foreground Shadow Color")
    }
}

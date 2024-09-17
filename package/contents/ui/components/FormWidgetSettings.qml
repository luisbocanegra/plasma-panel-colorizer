import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import org.kde.plasma.plasma5support as P5Support

ColumnLayout {
    id: backgroundRoot
    property bool isSection: true
    // wether read from the string or existing config object
    property bool handleString
    // key to extract config from
    property string keyName
    // internal config objects to be sent, both string and json
    property string configString: "{}"
    property var config: handleString ? JSON.parse(configString) : undefined
    property var configLocal: config[keyName]
    signal updateConfigString(configString: string, config: var)
    // whether the current item supports foreground customization, e.g the panel does not
    property bool supportsForeground: true

    Component.onCompleted: {
        console.error(configString)
        console.error(JSON.stringify(configLocal, null, null))
    }

    property var folllowVisbility: {
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
        config[keyName] = configLocal
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
                    text: i18n("Blur behind:")
                }
                CheckBox {
                    Kirigami.FormData.label: i18n("Blur behind:")
                    id: blurCheckbox
                    checked: configLocal.blurBehind
                    onCheckedChanged: {
                        configLocal.blurBehind = checked
                        if (checked) {
                            nativePanelBackgroundCheckbox.checked = true
                        }
                        updateConfig()
                    }
                }
                Button {
                    icon.name: "dialog-information-symbolic"
                    ToolTip.text: i18n("Draw a custom blur mask behind the custom background(s).\n\nEnables the native panel background.")
                    highlighted: true
                    hoverEnabled: true
                    ToolTip.visible: hovered
                    Kirigami.Theme.inherit: false
                    flat: true
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
                TextField {
                    id: panelRealBgOpacity
                    placeholderText: "0-1"
                    text: parseFloat(config.nativePanelBackground.opacity).toFixed(validator.decimals)
                    enabled: nativePanelBackgroundCheckbox.checked
                    Layout.preferredWidth: Kirigami.Units.gridUnit * 4

                    validator: DoubleValidator {
                        bottom: 0.0
                        top: 1.0
                        decimals: 2
                        notation: DoubleValidator.StandardNotation
                    }

                    onTextChanged: {
                        const newVal = parseFloat(text).toFixed(validator.decimals)
                        config.nativePanelBackground.opacity = isNaN(newVal) ? 0 : newVal
                        updateConfig()
                    }

                    ValueMouseControl {
                        height: parent.height - 8
                        width: height
                        anchors.right: parent.right
                        anchors.rightMargin: 4
                        anchors.verticalCenter: parent.verticalCenter

                        from: parent.validator.bottom
                        to: parent.validator.top
                        decimals: parent.validator.decimals
                        stepSize: 0.05
                        value: config.nativePanelBackground.opacity
                        onValueChanged: {
                            config.nativePanelBackground.opacity = parseFloat(value)
                            updateConfig()
                        }
                    }
                }
                Button {
                    icon.name: "dialog-information-symbolic"
                    ToolTip.text: i18n("Disabling the native Panel background also removes the contrast and blur.\n\nSet this to 0 to keep just the blur mask.")
                    highlighted: true
                    hoverEnabled: true
                    ToolTip.visible: hovered
                    Kirigami.Theme.inherit: false
                    flat: true
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
                checked: true
                onTriggered: currentTab = 0
            },
            Kirigami.Action {
                icon.name: "globe"
                text: "Shape"
                onTriggered: currentTab = 1
            },
            Kirigami.Action {
                icon.name: "globe"
                text: "Border"
                onTriggered: currentTab = 2
            },
            Kirigami.Action {
                icon.name: "globe"
                text: "Shadow"
                onTriggered: currentTab = 3
            }
        ]
    }

    property int currentTab: 0
    Kirigami.FormLayout {
        // required to align with parent form
        property alias formLayout: backgroundRoot
        twinFormLayouts: parentLayout
        Layout.fillWidth: true
    }

    FormColors {
        visible: currentTab === 0
        config: backgroundRoot.configLocal.backgroundColor
        onUpdateConfigString: (newString, newConfig) => {
            backgroundRoot.configLocal.backgroundColor = newConfig
            backgroundRoot.updateConfig()
        }
        followOptions: folllowVisbility.background
        sectionName: i18n("Background Color")
    }

    FormColors {
        visible: currentTab === 0 && supportsForeground
        config: backgroundRoot.configLocal.foregroundColor
        isSection: true
        onUpdateConfigString: (newString, newConfig) => {
            backgroundRoot.configLocal.foregroundColor = newConfig
            backgroundRoot.updateConfig()
        }
        followOptions: folllowVisbility.foreground
        sectionName: i18n("Foreground Color")
    }

    FormShape {
        visible: currentTab === 1
        config: backgroundRoot.configLocal
        onUpdateConfigString: (newString, newConfig) => {
            backgroundRoot.configLocal = newConfig
            backgroundRoot.updateConfig()
        }
    }

    FormBorder {
        visible: currentTab === 2
        config: backgroundRoot.configLocal
        onUpdateConfigString: (newString, newConfig) => {
            backgroundRoot.configLocal = newConfig
            backgroundRoot.updateConfig()
        }
    }

    FormColors {
        visible: currentTab === 2
        config: backgroundRoot.configLocal.border.color
        onUpdateConfigString: (newString, newConfig) => {
            backgroundRoot.configLocal.border.color = newConfig
            backgroundRoot.updateConfig()
        }
        followOptions: folllowVisbility.foreground
    }

    FormShadow {
        visible: currentTab === 3
        config: backgroundRoot.configLocal
        onUpdateConfigString: (newString, newConfig) => {
            backgroundRoot.configLocal = newConfig
            backgroundRoot.updateConfig()
        }
    }

    FormColors {
        visible: currentTab === 3
        config: backgroundRoot.configLocal.shadow.color
        onUpdateConfigString: (newString, newConfig) => {
            backgroundRoot.configLocal.shadow.color = newConfig
            backgroundRoot.updateConfig()
        }
        followOptions: folllowVisbility.foreground
    }
}

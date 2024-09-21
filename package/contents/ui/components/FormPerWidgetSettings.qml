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
    property bool handleString
    // key to extract config from
    property string keyName
    // internal config objects to be sent, both string and json
    property string configString: "{}"
    property var config: handleString ? JSON.parse(configString) : undefined
    signal updateConfigString(configString: string, config: var)
    // whether the current item supports foreground customization, e.g the panel does not
    property bool supportsForeground: true

    property alias isEnabled: isEnabled.checked

    signal closeDialog()

    property int configIndex

    Component.onCompleted: {
        // Qt.callLater(function() {
        //     console.error(configString)
        //     config = Utils.mergeConfigs(Globals.defaultConfig, config)
        //     configString = JSON.stringify(config, null, null)
        //     console.error(configString)
        //     // console.error(JSON.stringify(config, null, null))
        //     updateConfig()
        // })
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
        // config[keyName] = config
        configString = JSON.stringify(config, null, null)
        // console.error(configString)
        updateConfigString(configString, config)
        // console.error(JSON.stringify(config, null, null))
    }

    // Button {
    //     text: "Update"
    //     onClicked: closeDialog()
    //     Layout.alignment: Qt.AlignHCenter
    // }

    RowLayout {
        Layout.leftMargin: Kirigami.Units.mediumSpacing
        Layout.rightMargin: Kirigami.Units.smallSpacing
        Layout.bottomMargin: Kirigami.Units.smallSpacing
        ColumnLayout {

            // Label {
            //     text: JSON.stringify(config)
            //     Layout.maximumWidth: 600
            //     wrapMode: Text.Wrap
            // }

            RowLayout {
                // Layout.alignment: Qt.AlignRight
                Label {
                    text: i18n("Enable:")
                }
                CheckBox {
                    id: isEnabled
                    checked: config.enabled
                    onCheckedChanged: {
                        config.enabled = checked
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
                    checked: config.blurBehind
                    onCheckedChanged: {
                        config.blurBehind = checked
                        if (checked) {
                        }
                        updateConfig()
                    }
                    enabled: isEnabled.checked
                }
                Button {
                    icon.name: "dialog-information-symbolic"
                    ToolTip.text: i18n("Draw a custom blur mask behind the custom background(s).\n\nNative panel background must be enabled with opacity of 0 for this to work as intended.")
                    highlighted: true
                    hoverEnabled: true
                    ToolTip.visible: hovered
                    Kirigami.Theme.inherit: false
                    flat: true
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
        enabled: backgroundRoot.isEnabled
        // required to align with parent form
        property alias formLayout: backgroundRoot
        twinFormLayouts: parentLayout
        Layout.fillWidth: true

        SpinBox {
            Kirigami.FormData.label: i18n("Spacing:")
            id: spacingCheckbox
            value: config.spacing || 0
            from: 0
            to: 999
            visible: keyName === "widgets" && currentTab === 1
            enabled: visible
            onValueModified: {
                if (!enabled) return
                config.spacing = value
                updateConfig()
            }
        }
    }

    FormColors {
        enabled: backgroundRoot.isEnabled
        visible: currentTab === 0
        config: backgroundRoot.config.backgroundColor
        onUpdateConfigString: (newString, newConfig) => {
            backgroundRoot.config.backgroundColor = newConfig
            backgroundRoot.updateConfig()
        }
        followOptions: folllowVisbility.background
        sectionName: i18n("Background Color")
    }

    FormColors {
        enabled: backgroundRoot.isEnabled
        visible: currentTab === 0 && supportsForeground
        config: backgroundRoot.config.foregroundColor
        isSection: true
        onUpdateConfigString: (newString, newConfig) => {
            backgroundRoot.config.foregroundColor = newConfig
            backgroundRoot.updateConfig()
        }
        followOptions: folllowVisbility.foreground
        sectionName: i18n("Foreground Color")
    }

    FormShape {
        enabled: backgroundRoot.isEnabled
        visible: currentTab === 1
        config: backgroundRoot.config
        onUpdateConfigString: (newString, newConfig) => {
            backgroundRoot.config = newConfig
            backgroundRoot.updateConfig()
        }
    }

    FormPadding {
        enabled: backgroundRoot.isEnabled
        visible: currentTab === 1 && keyName === "panel"
        config: backgroundRoot.config
        onUpdateConfigString: (newString, newConfig) => {
            backgroundRoot.config = newConfig
            backgroundRoot.updateConfig()
        }
    }

    FormBorder {
        enabled: backgroundRoot.isEnabled
        visible: currentTab === 2
        config: backgroundRoot.config
        onUpdateConfigString: (newString, newConfig) => {
            backgroundRoot.config = newConfig
            backgroundRoot.updateConfig()
        }
    }

    FormColors {
        enabled: backgroundRoot.isEnabled
        visible: currentTab === 2
        config: backgroundRoot.config.border.color
        onUpdateConfigString: (newString, newConfig) => {
            backgroundRoot.config.border.color = newConfig
            backgroundRoot.updateConfig()
        }
        followOptions: folllowVisbility.foreground
    }

    FormShadow {
        enabled: backgroundRoot.isEnabled
        visible: currentTab === 3
        config: backgroundRoot.config
        onUpdateConfigString: (newString, newConfig) => {
            backgroundRoot.config = newConfig
            backgroundRoot.updateConfig()
        }
    }

    FormColors {
        enabled: backgroundRoot.isEnabled
        visible: currentTab === 3
        config: backgroundRoot.config.shadow.color
        onUpdateConfigString: (newString, newConfig) => {
            backgroundRoot.config.shadow.color = newConfig
            backgroundRoot.updateConfig()
        }
        followOptions: folllowVisbility.foreground
    }

    // Button {
    //     text: "Update"
    //     onClicked: closeDialog()
    //     Layout.alignment: Qt.AlignHCenter
    // }
}


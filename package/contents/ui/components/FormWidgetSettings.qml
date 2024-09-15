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
    // internal config objects to be sent, both string and json
    property string configString: "{}"
    property var config: handleString ? JSON.parse(configString) : undefined
    signal updateConfigString(configString: string, config: var)

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
        configString = JSON.stringify(config, null, null)
        updateConfigString(configString, config)
    }

    Kirigami.NavigationTabBar {
        // Layout.preferredHeight: 60
        Layout.fillWidth: true
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

        CheckBox {
            Kirigami.FormData.label: i18n("Blur behind:")
            id: animationCheckbox
            checked: config.blurBehind
            onCheckedChanged: {
                config.blurBehind = checked
                updateConfig()
            }
        }
    }

    FormColors {
        visible: currentTab === 0
        config: backgroundRoot.config.backgroundColor
        onUpdateConfigString: (newString, newConfig) => {
            backgroundRoot.config.backgroundColor = newConfig
            backgroundRoot.updateConfig()
        }
        followOptions: folllowVisbility.background
    }

    FormShape {
        visible: currentTab === 1
        config: backgroundRoot.config
        onUpdateConfigString: (newString, newConfig) => {
            backgroundRoot.config = newConfig
            backgroundRoot.updateConfig()
        }
    }

    FormBorder {
        visible: currentTab === 2
        config: backgroundRoot.config
        onUpdateConfigString: (newString, newConfig) => {
            backgroundRoot.config = newConfig
            backgroundRoot.updateConfig()
        }
    }

    FormColors {
        visible: currentTab === 2
        config: backgroundRoot.config.border.color
        isSection: false
        onUpdateConfigString: (newString, newConfig) => {
            backgroundRoot.config.border.color = newConfig
            backgroundRoot.updateConfig()
        }
        followOptions: folllowVisbility.foreground
    }

    FormShadow {
        visible: currentTab === 3
        config: backgroundRoot.config
        onUpdateConfigString: (newString, newConfig) => {
            backgroundRoot.config = newConfig
            backgroundRoot.updateConfig()
        }
    }

    FormColors {
        visible: currentTab === 3
        config: backgroundRoot.config.shadow.color
        isSection: false
        onUpdateConfigString: (newString, newConfig) => {
            backgroundRoot.config.shadow.color = newConfig
            backgroundRoot.updateConfig()
        }
        followOptions: folllowVisbility.foreground
    }
}

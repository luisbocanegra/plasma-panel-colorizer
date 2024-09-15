import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

ColumnLayout {
    id: backgroundRoot

    // internal config object
    property var config: JSON.parse(configString)
    // we save as string so we return as that
    property string configString: "{}"
    signal updateConfigString(configString: string, config: var)
    // wether or not show color list option
    property bool multiColor: true

    function updateConfig() {
        configString = JSON.stringify(config, null, null)
        updateConfigString(configString, config)
    }

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
        config: backgroundRoot.config.backgroundColor
        onUpdateConfigString: (newString, newConfig) => {
            backgroundRoot.config.backgroundColor = newConfig
            backgroundRoot.updateConfig()
        }
    }

    FormShape {
        config: backgroundRoot.config
        isSection: false
        isFg: true
        onUpdateConfigString: (newString, newConfig) => {
            backgroundRoot.config = newConfig
            backgroundRoot.updateConfig()
        }
    }

    FormBorder {
        config: backgroundRoot.config
        isSection: false
        isFg: true
        onUpdateConfigString: (newString, newConfig) => {
            backgroundRoot.config = newConfig
            backgroundRoot.updateConfig()
        }
    }

    FormColors {
        config: backgroundRoot.config.border.color
        isSection: false
        isFg: true
        onUpdateConfigString: (newString, newConfig) => {
            backgroundRoot.config.border.color = newConfig
            backgroundRoot.updateConfig()
        }
    }

    FormShadow {
        config: backgroundRoot.config.shadow
        isSection: false
        isFg: true
        onUpdateConfigString: (newString, newConfig) => {
            backgroundRoot.config.shadow = newConfig
            backgroundRoot.updateConfig()
        }
    }

    FormColors {
        config: backgroundRoot.config.shadow.color
        isSection: false
        isFg: true
        onUpdateConfigString: (newString, newConfig) => {
            backgroundRoot.config.shadow.color = newConfig
            backgroundRoot.updateConfig()
        }
    }
}

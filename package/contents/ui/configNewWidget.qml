import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import org.kde.plasma.plasma5support as P5Support
import "components" as Components

KCM.SimpleKCM {
    id: root
    property alias cfg_globalWidgetSettings: root.configString
    property var config: JSON.parse(cfg_globalWidgetSettings)
    // we save as string
    property string configString: "{}"

    function updateConfig() {
        configString = JSON.stringify(config, null, null)
    }

    ColumnLayout {
        Kirigami.FormLayout {
            id: parentLayout
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
        Components.FormColors {
            config: root.config.backgroundColor
            onUpdateConfigString: (newString, newConfig) => {
                root.config.backgroundColor = newConfig
                root.updateConfig()
            }
            showFollowPanel: true
        }

        Components.FormShape {
            config: root.config
            onUpdateConfigString: (newString, newConfig) => {
                root.config = newConfig
                root.updateConfig()
            }
        }

        Components.FormBorder {
            config: root.config
            onUpdateConfigString: (newString, newConfig) => {
                root.config = newConfig
                root.updateConfig()
            }
        }

        Components.FormColors {
            config: root.config.border.color
            isSection: false
            onUpdateConfigString: (newString, newConfig) => {
                root.config.border.color = newConfig
                root.updateConfig()
            }
            showFollowPanel: true
            showFollowWidget: true
        }

        Components.FormShadow {
            config: root.config
            onUpdateConfigString: (newString, newConfig) => {
                root.config = newConfig
                root.updateConfig()
            }
        }

        Components.FormColors {
            config: root.config.shadow.color
            isSection: false
            onUpdateConfigString: (newString, newConfig) => {
                root.config.shadow.color = newConfig
                root.updateConfig()
            }
            showFollowPanel: true
            showFollowWidget: true
        }
    }
}

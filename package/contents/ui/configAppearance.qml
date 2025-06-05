import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "code/utils.js" as Utils
import "code/globals.js" as Globals
import "components" as Components
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid

KCM.SimpleKCM {
    id: root

    property int currentTab
    property int currentState
    property string cfg_globalSettings
    property alias cfg_isEnabled: headerComponent.isEnabled
    property bool ready: false
    property var followVisbility: {
        "widgets": {
            "background": {
                "panel": true,
                "widget": false,
                "tray": false
            },
            "foreground": {
                "panel": true,
                "widget": true,
                "tray": false
            }
        },
        "panel": {
            "background": {
                "panel": false,
                "widget": false,
                "tray": false
            },
            "foreground": {
                "panel": true,
                "widget": false,
                "tray": false
            }
        },
        "trayWidgets": {
            "background": {
                "panel": true,
                "widget": true,
                "tray": false
            },
            "foreground": {
                "panel": true,
                "widget": true,
                "tray": true
            }
        }
    }

    ColumnLayout {
        enabled: cfg_isEnabled

        Kirigami.InlineMessage {
            Layout.fillWidth: true
            text: i18n("Not getting the expected result? Make sure you're editing the correct element.")
            visible: true
            type: Kirigami.MessageType.Information
        }

        Button {
            text: i18n("Restore default (removes all customizations)")
            icon.name: "kt-restore-defaults-symbolic"
            onClicked: {
                cfg_globalSettings = JSON.stringify(Globals.defaultConfig);
            }
            Layout.fillWidth: true
        }

        Kirigami.FormLayout {
            id: parentLayout

            Layout.fillWidth: true

            ComboBox {
                id: targetComponent

                Kirigami.FormData.label: i18n("Element:")
                textRole: "name"
                valueRole: "value"

                model: [
                    {
                        "name": i18n("Panel"),
                        "value": "panel"
                    },
                    {
                        "name": i18n("Widgets"),
                        "value": "widgets"
                    },
                    {
                        "name": i18n("Tray widgets"),
                        "value": "trayWidgets"
                    }
                ]
            }
        }

        Components.FormWidgetSettings {
            id: settingsComp
            currentTab: root.currentTab
            configString: root.cfg_globalSettings
            handleString: true
            elementState: root.currentState
            elementName: targetComponent.currentValue
            elementFriendlyName: targetComponent.currentText
            followVisbility: root.followVisbility[targetComponent.currentValue]
            onElementStateChanged: root.currentState = elementState
            onTabChanged: root.currentTab = currentTab
            onUpdateConfigString: (newString, newConfig) => {
                root.cfg_globalSettings = JSON.stringify(newConfig);
            }
        }
    }

    header: ColumnLayout {
        Components.Header {
            id: headerComponent
        }
    }
}

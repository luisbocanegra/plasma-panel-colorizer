import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import "components" as Components

KCM.SimpleKCM {
    id: root

    property int currentTab
    property alias cfg_allSettings: settingsComp.configString

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
            "background" : {
                "panel": false,
                "widget": false,
                "tray": false
            },
            "foreground" : {
                "panel": true,
                "widget": false,
                "tray": false
            }
        },
        "trayWidgets": {
            "background" : {
                "panel": true,
                "widget": true,
                "tray": false
            },
            "foreground" : {
                "panel": true,
                "widget": true,
                "tray": true
            },
        }
    }

    ColumnLayout {
        Kirigami.FormLayout {
            id: parentLayout
            Layout.fillWidth: true
            ComboBox {
                Kirigami.FormData.label: i18n("Element:")
                id: targetComponent
                textRole: "name"
                valueRole: "value"
                model: ListModel {
                    ListElement { name: "Widgets"; value: "widgets" }
                    ListElement { name: "Tray elements"; value: "trayWidgets" }
                    ListElement { name: "Panel"; value: "panel" }
                }
            }
        }
        Components.FormWidgetSettings {
            id: settingsComp
            currentTab: root.currentTab
            handleString: true
            keyName: targetComponent.currentValue
            onUpdateConfigString: (newString, config) => {
                cfg_allSettings = newString
            }
            followVisbility: root.followVisbility
        }
    }
}

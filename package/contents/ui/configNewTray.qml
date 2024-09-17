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
    property var folllowVisbility: {
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

    ColumnLayout {
        Kirigami.FormLayout {
            id: parentLayout
            Layout.fillWidth: true
        }
        Components.FormWidgetSettings {
            id: settingsComp
            currentTab: root.currentTab
            handleString: true
            keyName: "trayWidgets"
            onUpdateConfigString: (newString, config) => {
                cfg_allSettings = newString
            }
            folllowVisbility: root.folllowVisbility
        }
    }
}

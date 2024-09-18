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
            "panel": false,
            "widget": false,
            "tray": false
        },
        "foreground" : {
            "panel": true,
            "widget": false,
            "tray": false
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
            keyName: "panel"
            supportsForeground: false
            onUpdateConfigString: (newString, config) => {
                cfg_allSettings = newString
            }
            folllowVisbility: root.folllowVisbility
        }
    }
}
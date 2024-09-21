import QtQuick 2.0
import org.kde.plasma.configuration 2.0

ConfigModel {

    ConfigCategory {
        name: i18n("Overrides")
        icon: "preferences"
        source: "configPerWidget.qml"
    }

    ConfigCategory {
        name: i18n("General")
        icon: "preferences"
        source: "configGeneral.qml"
    }

    ConfigCategory {
        name: i18n("Panel")
        icon: "preferences"
        source: "configNewPanel.qml"
    }

    ConfigCategory {
        name: i18n("Widgets")
        icon: "preferences"
        source: "configNewWidget.qml"
    }

    ConfigCategory {
        name: i18n("Tray Widgets")
        icon: "preferences"
        source: "configNewTray.qml"
    }

    //

    ConfigCategory {
        name: i18n("Presets autoloading")
        icon: "system-run"
        source: "configPresetAutoload.qml"
    }

    ConfigCategory {
        name: i18n("Text and icons")
        icon: "preferences-desktop-icons"
        source: "configForeground.qml"
    }
}

import QtQuick 2.0
import org.kde.plasma.configuration 2.0

ConfigModel {
    ConfigCategory {
        name: i18n("General")
        icon: "preferences"
        source: "configGeneral.qml"
    }

    ConfigCategory {
        name: i18n("Presets autoloading")
        icon: "system-run"
        source: "configPresetAutoload.qml"
    }

    ConfigCategory {
        name: i18n("Widget background")
        icon: "preferences-desktop-theme-global"
        source: "configWidgetBg.qml"
    }

    ConfigCategory {
        name: i18n("Text and icons")
        icon: "preferences-desktop-icons"
        source: "configForeground.qml"
    }

    ConfigCategory {
        name: i18n("Panel background")
        icon: "preferences-desktop-plasma-theme"
        source: "configPanelBg.qml"
    }

    ConfigCategory {
        name: i18n("Blacklist")
        icon: "preferences-desktop-filter"
        source: "configWidgetBlacklist.qml"
    }
}

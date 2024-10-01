import QtQuick 2.0
import org.kde.plasma.configuration 2.0

ConfigModel {

    ConfigCategory {
        name: i18n("Presets")
        icon: "preferences"
        source: "configPresets.qml"
    }

    ConfigCategory {
        name: i18n("Presets autoloading")
        icon: "system-run"
        source: "configPresetAutoload.qml"
    }

    ConfigCategory {
        name: i18n("Appearance")
        icon: "preferences"
        source: "configGlobal.qml"
    }

    ConfigCategory {
        name: i18n("Unified background")
        icon: "preferences"
        source: "configUnifiedBackground.qml"
    }

    ConfigCategory {
        name: i18n("Overrides")
        icon: "preferences"
        source: "configPerWidget.qml"
    }

    ConfigCategory {
        name: i18n("Text and icons")
        icon: "preferences-desktop-icons"
        source: "configForeground.qml"
    }

    ConfigCategory {
        name: i18n("General")
        icon: "preferences"
        source: "configGeneral.qml"
    }
}

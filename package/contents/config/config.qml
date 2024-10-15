import QtQuick 2.0
import org.kde.plasma.configuration 2.0

ConfigModel {

    ConfigCategory {
        name: i18n("Presets")
        icon: "starred-symbolic"
        source: "configPresets.qml"
    }

    ConfigCategory {
        name: i18n("Presets autoloading")
        icon: "system-run-symbolic"
        source: "configPresetAutoload.qml"
    }

    ConfigCategory {
        name: i18n("Appearance")
        icon: "desktop-symbolic"
        source: "configGlobal.qml"
    }

    ConfigCategory {
        name: i18n("Unified background")
        icon: "lines-connector-symbolic"
        source: "configUnifiedBackground.qml"
    }

    ConfigCategory {
        name: i18n("Preset Overrides")
        icon: "semi-starred-symbolic"
        source: "configPresetWidgetOverrides.qml"
    }

    ConfigCategory {
        name: i18n("User Overrides")
        icon: "user-properties-symbolic"
        source: "configUserWidgetOverrides.qml"
    }

    ConfigCategory {
        name: i18n("Text and icons")
        icon: "color-mode-invert-text-symbolic"
        source: "configForeground.qml"
    }

    ConfigCategory {
        name: i18n("General")
        icon: "configure-symbolic"
        source: "configGeneral.qml"
    }
}

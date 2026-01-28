import org.kde.plasma.configuration 2.0

ConfigModel {

    ConfigCategory {
        name: i18n("Presets")
        icon: "starred-symbolic"
        source: "configPresets.qml"
    }

    ConfigCategory {
        name: i18n("Presets auto-loading")
        icon: "system-run-symbolic"
        source: "configPresetAutoload.qml"
    }

    ConfigCategory {
        name: i18n("Appearance")
        icon: "desktop-symbolic"
        source: "configAppearance.qml"
    }

    ConfigCategory {
        name: i18n("Stock Panel Settings")
        icon: "configure-symbolic"
        source: "configStockPanelSettings.qml"
    }

    ConfigCategory {
        name: i18n("Widget Islands")
        icon: "distribute-horizontal-margin-symbolic"
        source: "configWidgetIslands.qml"
    }

    ConfigCategory {
        name: i18n("Preset Overrides")
        icon: "semi-starred-symbolic"
        source: "configPresetWidgetOverrides.qml"
    }

    ConfigCategory {
        name: i18n("Global Overrides")
        icon: "globe-symbolic"
        source: "configGlobalWidgetOverrides.qml"
    }

    ConfigCategory {
        name: i18n("Text/Icon Fixes")
        icon: "color-mode-invert-text-symbolic"
        source: "configTextIconFix.qml"
    }

    ConfigCategory {
        name: i18n("Hide Widgets")
        icon: "view-hidden-symbolic"
        source: "configHideWidgets.qml"
    }

    ConfigCategory {
        name: i18n("System Tray Icons Replacer")
        icon: "document-replace-symbolic"
        source: "configTrayIconsReplacer.qml"
    }

    ConfigCategory {
        name: i18n("General")
        icon: "configure-symbolic"
        source: "configGeneral.qml"
    }
}

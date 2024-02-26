import QtQuick 2.0
import org.kde.plasma.configuration 2.0

ConfigModel {
    ConfigCategory {
        name: i18n("General")
        icon: "configure-symbolic"
        source: "configGeneral.qml"
    }

    ConfigCategory {
        name: i18n("Widget background")
        icon: "box-symbolic"
        source: "configWidgetBg.qml"
    }

    ConfigCategory {
        name: i18n("Text and icons")
        icon: "format-text-color-symbolic"
        source: "configForeground.qml"
    }

    ConfigCategory {
        name: i18n("Panel background")
        icon: "desktop-symbolic"
        source: "configPanelBg.qml"
    }

    ConfigCategory {
        name: i18n("Widget rules")
        icon: "view-list-details-symbolic"
        source: "configWidgetRules.qml"
    }
}

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami



Kirigami.FormLayout {
    id: shadowRoot
    // required to align with parent form
    property alias formLayout: shadowRoot
    twinFormLayouts: parentLayout
    Layout.fillWidth: true
    property bool isSection: true
    // wether read from the string or existing config object
    property bool handleString
    // internal config objects to be sent, both string and json
    property string configString: "{}"
    property var config: handleString ? JSON.parse(configString) : undefined
    signal updateConfigString(configString: string, config: var)

    function updateConfig() {
        configString = JSON.stringify(config, null, null)
        updateConfigString(configString, config)
    }

    Kirigami.Separator {
        Kirigami.FormData.isSection: shadowRoot
        Kirigami.FormData.label: i18n("Shadow")
    }

    SpinBox {
        Kirigami.FormData.label: i18n("Size:")
        id: shadowSize
        value: config.shadow.size
        from: 0
        to: 99
        onValueModified: {
            config.shadow.size = value
            updateConfig()
        }
    }

    SpinBox {
        Kirigami.FormData.label: i18n("X offset:")
        id: shadowX
        value: config.shadow.xOffset
        from: -99
        to: 99
        onValueModified: {
            config.shadow.xOffset = value
            updateConfig()
        }
    }

    SpinBox {
        Kirigami.FormData.label: i18n("Y offset:")
        id: shadowY
        value: config.shadow.yOffset
        from: -99
        to: 99
        onValueModified: {
            config.shadow.yOffset = value
            updateConfig()
        }
    }
}

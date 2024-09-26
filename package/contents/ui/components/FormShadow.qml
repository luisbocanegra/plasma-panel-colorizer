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
    property string sectionName
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
        Kirigami.FormData.isSection: isSection
        Kirigami.FormData.label: sectionName || i18n("Shadow")
    }

    CheckBox {
        Kirigami.FormData.label: i18n("Enabled:")
        id: enabledCheckbox
        checked: config.enabled
        onCheckedChanged: {
            config.enabled = checked
            updateConfig()
        }
        Binding {
            target: enabledCheckbox
            property: "Kirigami.Theme.textColor"
            value: shadowRoot.Kirigami.Theme.neutralTextColor
            when: !enabledCheckbox.checked
        }
        Kirigami.Theme.inherit: false
        text: checked ? "" : i18n("Disabled")
    }

    SpinBox {
        Kirigami.FormData.label: i18n("Size:")
        id: shadowSize
        value: config.size
        from: 0
        to: 99
        onValueModified: {
            config.size = value
            updateConfig()
        }
        enabled: enabledCheckbox.checked
    }

    SpinBox {
        Kirigami.FormData.label: i18n("X offset:")
        id: shadowX
        value: config.xOffset
        from: -99
        to: 99
        onValueModified: {
            config.xOffset = value
            updateConfig()
        }
        enabled: enabledCheckbox.checked
    }

    SpinBox {
        Kirigami.FormData.label: i18n("Y offset:")
        id: shadowY
        value: config.yOffset
        from: -99
        to: 99
        onValueModified: {
            config.yOffset = value
            updateConfig()
        }
        enabled: enabledCheckbox.checked
    }
}

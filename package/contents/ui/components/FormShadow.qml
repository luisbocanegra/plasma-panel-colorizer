import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: shadowRoot

    // required to align with parent form
    property alias formLayout: shadowRoot
    property bool isSection: true
    property string sectionName
    // wether read from the string or existing config object
    property bool handleString
    // internal config objects to be sent, both string and json
    property string configString: "{}"
    property var config: handleString ? JSON.parse(configString) : undefined

    signal updateConfigString(string configString, var config)

    function updateConfig() {
        configString = JSON.stringify(config, null, null);
        updateConfigString(configString, config);
    }

    twinFormLayouts: parentLayout
    Layout.fillWidth: true

    Kirigami.Separator {
        Kirigami.FormData.isSection: isSection
        Kirigami.FormData.label: sectionName || i18n("Shadow")
    }

    CheckBox {
        id: enabledCheckbox

        Kirigami.FormData.label: i18n("Enabled:")
        checked: config.enabled
        onCheckedChanged: {
            config.enabled = checked;
            updateConfig();
        }
        Kirigami.Theme.inherit: false
        text: checked ? "" : i18n("Disabled")

        Binding {
            target: enabledCheckbox
            property: "Kirigami.Theme.textColor"
            value: shadowRoot.Kirigami.Theme.neutralTextColor
            when: !enabledCheckbox.checked
        }
    }

    SpinBox {
        id: shadowSize

        Kirigami.FormData.label: i18n("Size:")
        value: config.size
        from: 0
        to: 99
        onValueModified: {
            config.size = value;
            updateConfig();
        }
        enabled: enabledCheckbox.checked
    }

    SpinBox {
        id: shadowX

        Kirigami.FormData.label: i18n("X offset:")
        value: config.xOffset
        from: -99
        to: 99
        onValueModified: {
            config.xOffset = value;
            updateConfig();
        }
        enabled: enabledCheckbox.checked
    }

    SpinBox {
        id: shadowY

        Kirigami.FormData.label: i18n("Y offset:")
        value: config.yOffset
        from: -99
        to: 99
        onValueModified: {
            config.yOffset = value;
            updateConfig();
        }
        enabled: enabledCheckbox.checked
    }
}

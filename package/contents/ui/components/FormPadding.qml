import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: shapeRoot
    // required to align with parent form
    property alias formLayout: shapeRoot
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
        Kirigami.FormData.isSection: isSection
        Kirigami.FormData.label: i18n("Padding")
    }

    CheckBox {
        Kirigami.FormData.label: i18n("Enabled:")
        id: enabledCheckbox
        checked: config.paddingEnabled
        onCheckedChanged: {
            config.paddingEnabled = checked
            updateConfig()
        }
    }

    GridLayout {
        enabled: enabledCheckbox.checked
        columns: 3
        rows: 3
        Kirigami.FormData.label: i18n("Padding:")
        SpinBox {
            id: topMargin
            value: config.padding.top
            from: 0
            to: 99
            Layout.row: 0
            Layout.column: 1
            onValueModified: {
                config.padding.top = value
                updateConfig()
            }
        }
        SpinBox {
            id: bottomMargin
            value: config.padding.bottom
            from: 0
            to: 99
            Layout.row: 2
            Layout.column: 1
            onValueModified: {
                config.padding.bottom = value
                updateConfig()
            }
        }
        SpinBox {
            id: leftMargin
            value: config.padding.left
            from: 0
            to: 99
            Layout.row: 1
            Layout.column: 0
            onValueModified: {
                config.padding.left = value
                updateConfig()
            }
        }

        SpinBox {
            id: rightMargin
            value: config.padding.right
            from: 0
            to: 99
            Layout.row: 1
            Layout.column: 2
            onValueModified: {
                config.padding.right = value
                updateConfig()
            }
        }
    }
}


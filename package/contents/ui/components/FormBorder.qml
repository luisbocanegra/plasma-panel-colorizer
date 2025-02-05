import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: borderRoot
    // required to align with parent form
    property alias formLayout: borderRoot
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
        Kirigami.FormData.label: sectionName || i18n("Border")
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
            value: borderRoot.Kirigami.Theme.neutralTextColor
            when: !enabledCheckbox.checked
        }
        Kirigami.Theme.inherit: false
        text: checked ? "" : i18n("Disabled")
    }
    RowLayout {
        SpinBoxDecimal {
            Kirigami.FormData.label: i18n("Width:")
            id: borderWidth
            value: config.width
            from: 0
            to: 99
            Layout.preferredWidth: Kirigami.Units.gridUnit * 5
            Layout.fillWidth: false
            onValueChanged: {
                config.width = value
                updateConfig()
            }
            enabled: !borderCustomSidesCheckbox.checked && enabledCheckbox.checked
        }
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Custom widths:")
        CheckBox {
            id: borderCustomSidesCheckbox
            checked: config.customSides
            onCheckedChanged: {
                config.customSides = checked
                updateConfig()
            }
        }

        GridLayout {
            columns: 3
            rows: 3
            enabled: borderCustomSidesCheckbox.checked && enabledCheckbox.checked
            SpinBox {
                id: topBorderWidth
                value: config.custom.widths.top
                from: 0
                to: 99
                Layout.row: 0
                Layout.column: 1
                onValueModified: {
                    config.custom.widths.top = value
                    updateConfig()
                }
            }
            SpinBox {
                id: bottomBorderWidth
                value: config.custom.widths.bottom
                from: 0
                to: 99
                Layout.row: 2
                Layout.column: 1
                onValueModified: {
                    config.custom.widths.bottom = value
                    updateConfig()
                }
            }
            SpinBox {
                id: leftBorderWidth
                value: config.custom.widths.left
                from: 0
                to: 99
                Layout.row: 1
                Layout.column: 0
                onValueModified: {
                    config.custom.widths.left = value
                    updateConfig()
                }
            }

            SpinBox {
                id: rightBorderWidth
                value: config.custom.widths.right
                from: 0
                to: 99
                Layout.row: 1
                Layout.column: 2
                onValueModified: {
                    config.custom.widths.right = value
                    updateConfig()
                }
            }
        }
    }
}


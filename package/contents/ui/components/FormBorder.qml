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
    // Kirigami.Separator {
    //     Kirigami.FormData.isSection: isSection
    //     Kirigami.FormData.label: i18n("Border")
    // }

    CheckBox {
        Kirigami.FormData.label: i18n("Enabled:")
        id: enabledCheckbox
        checked: config.border.enabled
        onCheckedChanged: {
            config.border.enabled = checked
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

    SpinBox {
        Kirigami.FormData.label: i18n("Width:")
        id: borderWidth
        value: config.border.width
        from: 0
        to: 99
        Layout.row: 1
        Layout.column: 2
        onValueModified: {
            config.border.width = value
            updateConfig()
        }
        enabled: !borderCustomSidesCheckbox.checked && enabledCheckbox.checked
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Custom widths:")
        CheckBox {
            id: borderCustomSidesCheckbox
            checked: config.border.customSides
            onCheckedChanged: {
                config.border.customSides = checked
                updateConfig()
            }
        }

        GridLayout {
            columns: 3
            rows: 3
            enabled: borderCustomSidesCheckbox.checked && enabledCheckbox.checked
            SpinBox {
                id: topBorderWidth
                value: config.border.custom.widths.top
                from: 0
                to: 99
                Layout.row: 0
                Layout.column: 1
                onValueModified: {
                    config.border.custom.widths.top = value
                    updateConfig()
                }
            }
            SpinBox {
                id: bottomBorderWidth
                value: config.border.custom.widths.bottom
                from: 0
                to: 99
                Layout.row: 2
                Layout.column: 1
                onValueModified: {
                    config.border.custom.widths.bottom = value
                    updateConfig()
                }
            }
            SpinBox {
                id: leftBorderWidth
                value: config.border.custom.widths.left
                from: 0
                to: 99
                Layout.row: 1
                Layout.column: 0
                onValueModified: {
                    config.border.custom.widths.left = value
                    updateConfig()
                }
            }

            SpinBox {
                id: rightBorderWidth
                value: config.border.custom.widths.right
                from: 0
                to: 99
                Layout.row: 1
                Layout.column: 2
                onValueModified: {
                    config.border.custom.widths.right = value
                    updateConfig()
                }
            }
        }
    }
}


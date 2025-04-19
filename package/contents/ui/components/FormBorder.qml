import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: borderRoot

    // required to align with parent form
    property alias formLayout: borderRoot
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
        Kirigami.FormData.label: sectionName || i18n("Border")
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
            value: borderRoot.Kirigami.Theme.neutralTextColor
            when: !enabledCheckbox.checked
        }
    }

    RowLayout {
        SpinBoxDecimal {
            id: borderWidth

            Kirigami.FormData.label: i18n("Width:")
            value: config.width
            from: 0
            to: 99
            Layout.preferredWidth: Kirigami.Units.gridUnit * 5
            Layout.fillWidth: false
            onValueChanged: {
                config.width = value;
                updateConfig();
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
                config.customSides = checked;
                updateConfig();
            }
        }

        GridLayout {
            columns: 3
            rows: 3
            enabled: borderCustomSidesCheckbox.checked && enabledCheckbox.checked

            SpinBoxDecimal {
                id: topBorderWidth
                Layout.preferredWidth: backgroundRoot.Kirigami.Units.gridUnit * 5
                value: config.custom.widths.top
                from: 0
                to: 99
                Layout.row: 0
                Layout.column: 1
                onValueChanged: {
                    config.custom.widths.top = value;
                    updateConfig();
                }
            }

            SpinBoxDecimal {
                id: bottomBorderWidth
                Layout.preferredWidth: backgroundRoot.Kirigami.Units.gridUnit * 5
                value: config.custom.widths.bottom
                from: 0
                to: 99
                Layout.row: 2
                Layout.column: 1
                onValueChanged: {
                    config.custom.widths.bottom = value;
                    updateConfig();
                }
            }

            SpinBoxDecimal {
                id: leftBorderWidth
                Layout.preferredWidth: backgroundRoot.Kirigami.Units.gridUnit * 5
                value: config.custom.widths.left
                from: 0
                to: 99
                Layout.row: 1
                Layout.column: 0
                onValueChanged: {
                    config.custom.widths.left = value;
                    updateConfig();
                }
            }

            SpinBoxDecimal {
                id: rightBorderWidth
                Layout.preferredWidth: backgroundRoot.Kirigami.Units.gridUnit * 5
                value: config.custom.widths.right
                from: 0
                to: 99
                Layout.row: 1
                Layout.column: 2
                onValueChanged: {
                    config.custom.widths.right = value;
                    updateConfig();
                }
            }
        }
    }
}

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: root

    // required to align with parent form
    property alias formLayout: root
    property bool isSection: true
    property string sectionName
    // wether read from the string or existing config object
    property bool handleString
    // internal config objects to be sent, both string and json
    property string configString: "{}"
    property var config: handleString ? JSON.parse(configString) : undefined
    property string key

    signal updateConfigString(string configString, var config)

    function updateConfig() {
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
        checked: root.config.enabled
        onCheckedChanged: {
            root.config.enabled = checked;
            root.updateConfig();
        }
        Kirigami.Theme.inherit: false
        text: checked ? "" : i18n("Disabled")

        Binding {
            target: enabledCheckbox
            property: "Kirigami.Theme.textColor"
            value: root.Kirigami.Theme.neutralTextColor
            when: !enabledCheckbox.checked
        }
    }

    DoubleSpinBox {
        id: borderWidth
        Kirigami.FormData.label: i18n("Width:")
        value: root.config.width * multiplier
        from: 0 * multiplier
        to: 99 * multiplier
        onValueModified: {
            root.config.width = value / borderWidth.multiplier;
            root.updateConfig();
        }
        enabled: !borderCustomSidesCheckbox.checked && enabledCheckbox.checked
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Custom widths:")

        CheckBox {
            id: borderCustomSidesCheckbox

            checked: root.config.customSides
            onCheckedChanged: {
                root.config.customSides = checked;
                root.updateConfig();
            }
        }

        RowLayout {
            enabled: borderCustomSidesCheckbox.checked && enabledCheckbox.checked
            DoubleSpinBox {
                id: leftBorderWidth
                value: root.config.custom.widths.left * multiplier
                from: 0 * multiplier
                to: 99 * multiplier
                onValueModified: {
                    root.config.custom.widths.left = value / leftBorderWidth.multiplier;
                    root.updateConfig();
                }
            }

            ColumnLayout {
                DoubleSpinBox {
                    id: topBorderWidth
                    value: root.config.custom.widths.top * multiplier
                    from: 0 * multiplier
                    to: 99 * multiplier
                    onValueModified: {
                        root.config.custom.widths.top = value / topBorderWidth.multiplier;
                        root.updateConfig();
                    }
                }

                DoubleSpinBox {
                    id: bottomBorderWidth
                    value: root.config.custom.widths.bottom * multiplier
                    from: 0 * multiplier
                    to: 99 * multiplier
                    onValueModified: {
                        root.config.custom.widths.bottom = value / bottomBorderWidth.multiplier;
                        root.updateConfig();
                    }
                }
            }

            DoubleSpinBox {
                id: rightBorderWidth
                value: root.config.custom.widths.right * multiplier
                from: 0 * multiplier
                to: 99 * multiplier
                onValueModified: {
                    root.config.custom.widths.right = value / rightBorderWidth.multiplier;
                    root.updateConfig();
                }
            }
        }
    }
}

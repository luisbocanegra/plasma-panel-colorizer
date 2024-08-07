import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: root
    // required to align with parent form
    property alias formLayout: root
    twinFormLayouts: parentLayout
    Layout.fillWidth: true

    // internal config object
    property var config: JSON.parse(configString)
    // we save as string so we return as that
    property string configString: "{}"
    signal updateConfigString(newConfig: string)
    // to hide options that make no sense for panel
    property bool isPanel: false
    // wether or not show color list option
    property bool multiColor: true

    function updateConfig() {
        configString = JSON.stringify(config, null, null)
        updateConfigString(configString)
    }

    Label {
        text: "Nested Form"
    }

    RadioButton {
        Kirigami.FormData.label: i18n("Source:")
        text: i18n("Custom")
        id: singleColorRadio
        ButtonGroup.group: colorModeGroup
        property int index: 0
        checked: config.type === index
        enabled: !animatedColorMode.checked
    }

    RadioButton {
        text: i18n("System")
        id: accentColorRadio
        ButtonGroup.group: colorModeGroup
        property int index: 1
        checked: config.type === index
        enabled: !animatedColorMode.checked
    }

    RadioButton {
        id: listColorRadio
        text: i18n("Custom list")
        ButtonGroup.group: colorModeGroup
        property int index: 2
        checked: config.type === index
        visible: multiColor
    }

    RadioButton {
        id: randomColorRadio
        text: i18n("Random")
        ButtonGroup.group: colorModeGroup
        property int index: 3
        checked: config.type === index
    }

    RadioButton {
        id: followColorRadio
        text: i18n("Follow")
        ButtonGroup.group: colorModeGroup
        property int index: 4
        checked: config.type === index
    }

    ComboBox {
        id: followColorCombobox
        Kirigami.FormData.label: i18n("Element:")
        currentIndex: config.systemColorSet
        model: [
            i18n("Panel background"),
            i18n("Widget Background"),
            i18n("Widget text"),
        ]
        visible: followColorRadio.checked
        onCurrentIndexChanged: {
            config.systemColorSet = currentIndex
            updateConfig()
        }
    }


    ButtonGroup {
        id: colorModeGroup
        onCheckedButtonChanged: {
            if (checkedButton) {
                config.type = checkedButton.index
                updateConfig()
            }
        }
    }

    ColorButton {
        id: customColorBtn
        showAlphaChannel: false
        // dialogTitle: i18n("Widget background")
        color: config.custom
        visible: singleColorRadio.checked
        onAccepted: (color) => {
            console.error(color)
            config.custom = color.toString()
            updateConfig()
        }
    }

    ComboBox {
        id: colorModeThemeVariant
        Kirigami.FormData.label: i18n("Color set:")
        currentIndex: config.systemColorSet
        model: [
            i18n("View"),
            i18n("Window"),
            i18n("Button"),
            i18n("Selection"),
            i18n("Tooltip"),
            i18n("Complementary"),
            i18n("Header")
        ]
        visible: accentColorRadio.checked
        onCurrentIndexChanged: {
            config.systemColorSet = currentIndex
            updateConfig()
        }
    }

    ComboBox {
        id: colorModeTheme
        Kirigami.FormData.label: i18n("Color:")
        currentIndex: config.systemColor
        model: [
            i18n("Text"),
            i18n("Disabled Text"),
            i18n("Highlighted Text"),
            i18n("Active Text"),
            i18n("Link"),
            i18n("Visited Link"),
            i18n("Negative Text"),
            i18n("Neutral Text"),
            i18n("Positive Text"),
            i18n("Background"),
            i18n("Highlight"),
            i18n("Active Background"),
            i18n("Link Background"),
            i18n("Visited Link Background"),
            i18n("Negative Background"),
            i18n("Neutral Background"),
            i18n("Positive Background"),
            i18n("Alternate Background"),
            i18n("Focus"),
            i18n("Hover")
        ]
        visible: accentColorRadio.checked
        onCurrentIndexChanged: {
            config.systemColor = currentIndex
            updateConfig()
        }
    }

    ColorPickerList {
        visible: multiColor
        colorsList: config.list
        onColorsChanged: (colorsList) => {
            config.list = colorsList
            updateConfig()
        }
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Alpha:")
        TextField {
            placeholderText: "0-1"
            text: parseFloat(config.alpha).toFixed(validator.decimals)
            Layout.preferredWidth: Kirigami.Units.gridUnit * 5

            validator: DoubleValidator {
                bottom: 0.0
                top: 1.0
                decimals: 2
                notation: DoubleValidator.StandardNotation
            }

            onTextChanged: {
                const newVal = parseFloat(text)
                config.alpha = isNaN(newVal) ? 0 : newVal
                updateConfig()
            }

            ValueMouseControl {
                height: parent.height - 8
                width: height
                anchors.right: parent.right
                anchors.rightMargin: 4
                anchors.verticalCenter: parent.verticalCenter

                from: parent.validator.bottom
                to: parent.validator.top
                decimals: parent.validator.decimals
                stepSize: 0.05
                value: config.alpha
                onValueChanged: {
                    config.alpha = parseFloat(value)
                    updateConfig()
                }
            }
        }
    }

    Kirigami.Separator {
        Kirigami.FormData.isSection: false
        Kirigami.FormData.label: i18n("Contrast Correction")
        Layout.fillWidth: true
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Saturation:")
        CheckBox {
            id: saturationEnabled
            checked: config.saturationEnabled
            onCheckedChanged: {
                config.saturationEnabled = checked
                updateConfig()
            }
        }
        TextField {
            placeholderText: "0-1"
            text: parseFloat(config.saturationValue).toFixed(validator.decimals)
            enabled: saturationEnabled.checked
            Layout.preferredWidth: Kirigami.Units.gridUnit * 5

            validator: DoubleValidator {
                bottom: 0.0
                top: 1.0
                decimals: 2
                notation: DoubleValidator.StandardNotation
            }

            onTextChanged: {
                const newVal = parseFloat(text)
                config.saturationValue = isNaN(newVal) ? 0 : newVal
                updateConfig()
            }

            ValueMouseControl {
                height: parent.height - 8
                width: height
                anchors.right: parent.right
                anchors.rightMargin: 4
                anchors.verticalCenter: parent.verticalCenter

                from: parent.validator.bottom
                to: parent.validator.top
                decimals: parent.validator.decimals
                stepSize: 0.05
                value: config.saturationValue
                onValueChanged: {
                    config.saturationValue = parseFloat(value)
                    updateConfig()
                }
            }
        }
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Lightness:")
        CheckBox {
            id: lightnessEnabled
            checked: config.lightnessEnabled
            onCheckedChanged: {
                config.lightnessEnabled = checked
                updateConfig()
            }
        }
        TextField {
            placeholderText: "0-1"
            text: parseFloat(config.lightnessValue).toFixed(validator.decimals)
            enabled: lightnessEnabled.checked
            Layout.preferredWidth: Kirigami.Units.gridUnit * 5

            validator: DoubleValidator {
                bottom: 0.0
                top: 1.0
                decimals: 2
                notation: DoubleValidator.StandardNotation
            }

            onTextChanged: {
                const newVal = parseFloat(text)
                config.lightnessValue = isNaN(newVal) ? 0 : newVal
                updateConfig()
            }

            ValueMouseControl {
                height: parent.height - 8
                width: height
                anchors.right: parent.right
                anchors.rightMargin: 4
                anchors.verticalCenter: parent.verticalCenter

                from: parent.validator.bottom
                to: parent.validator.top
                decimals: parent.validator.decimals
                stepSize: 0.05
                value: config.lightnessValue
                onValueChanged: {
                    config.lightnessValue = parseFloat(value)
                    updateConfig()
                }
            }
        }
    }
}



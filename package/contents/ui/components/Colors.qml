import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: colorRoot
    // required to align with parent form
    property alias formLayout: colorRoot
    twinFormLayouts: parentLayout
    Layout.fillWidth: true
    property bool isSection: true
    // wether read from the string or existing config
    property bool handleString
    // internal config objects to be sent, both string and json
    property string configString: "{}"
    property var config: handleString ? JSON.parse(configString) : undefined
    signal updateConfigString(configString: string, config: var)
    // to hide options that make no sense for panel
    property bool isPanel: false
    // wether or not show color list option
    property bool multiColor: true

    function updateConfig() {
        configString = JSON.stringify(config, null, null)
        updateConfigString(configString, config)
    }

    Component.onCompleted: {
        // if (handleString) config = JSON.parse(configString)
        console.log(configString)
        console.log(JSON.stringify(config, null, null))
    }

    Kirigami.Separator {
        Kirigami.FormData.isSection: isSection
        Kirigami.FormData.label: i18n("Color")
        Layout.fillWidth: true
    }

    CheckBox {
        Kirigami.FormData.label: i18n("Animation:")
        id: animationCheckbox
        checked: config.animation.enabled
        onCheckedChanged: {
            config.animation.enabled = checked
            updateConfig()
            // ensure valid option is checked as single and accent are
            // disabled in animated mode
            if (checked && (config.sourceType <= 1 || config.sourceType >= 4)) {
                listColorRadio.checked = true
            }
        }
    }

    SpinBox {
        Kirigami.FormData.label: i18n("Interval (ms):")
        id: animationInterval
        from: 0
        to: 30000
        stepSize: 100
        value: config.animation.interval
        onValueModified: {
            config.animation.interval = value
            updateConfig()
        }
        enabled: animationCheckbox.checked
    }

    SpinBox {
        Kirigami.FormData.label: i18n("Smoothing (ms):")
        id: animationTransition
        from: 0
        to: animationInterval.value
        stepSize: 100
        value: config.animation.smoothing
        onValueModified: {
            config.animation.smoothing = value
            updateConfig()
        }
        enabled: animationCheckbox.checked
    }

    RadioButton {
        Kirigami.FormData.label: i18n("Source:")
        text: i18n("Custom")
        id: singleColorRadio
        ButtonGroup.group: colorModeGroup
        property int index: 0
        checked: config.sourceType === index
        enabled: !animationCheckbox.checked
    }

    RadioButton {
        text: i18n("System")
        id: accentColorRadio
        ButtonGroup.group: colorModeGroup
        property int index: 1
        checked: config.sourceType === index
        enabled: !animationCheckbox.checked
    }

    RadioButton {
        id: listColorRadio
        text: i18n("Custom list")
        ButtonGroup.group: colorModeGroup
        property int index: 2
        checked: config.sourceType === index
        visible: multiColor
    }

    RadioButton {
        id: randomColorRadio
        text: i18n("Random")
        ButtonGroup.group: colorModeGroup
        property int index: 3
        checked: config.sourceType === index
    }

    RadioButton {
        id: followColorRadio
        text: i18n("Follow")
        ButtonGroup.group: colorModeGroup
        property int index: 4
        checked: config.sourceType === index
        enabled: !animationCheckbox.checked
    }

    ComboBox {
        id: followColorCombobox
        Kirigami.FormData.label: i18n("Element:")
        currentIndex: config.followColor
        model: [
            i18n("Panel background"),
            i18n("Widget Background"),
            i18n("Widget text"),
        ]
        visible: followColorRadio.checked
        onCurrentIndexChanged: {
            config.followColor = currentIndex
            updateConfig()
        }
    }


    ButtonGroup {
        id: colorModeGroup
        onCheckedButtonChanged: {
            if (checkedButton) {
                config.sourceType = checkedButton.index
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



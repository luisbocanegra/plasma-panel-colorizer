import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

import "../code/utils.js" as Utils

Kirigami.FormLayout {
    id: colorRoot
    // required to align with parent form
    property alias formLayout: colorRoot
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
    // to hide options that make no sense
    property var followOptions: {
        "panel": false,
        "widget": false,
        "tray": false
    }
    property bool showFollowPanel: followOptions.panel
    property bool showFollowWidget: followOptions.widget
    property bool showFollowTray: followOptions.tray
    property bool showFollowRadio: showFollowPanel || showFollowWidget || showFollowTray
    // wether or not show color list option
    property bool multiColor: true

    ListModel {
        id: themeColorSetModel
        ListElement {
            value: "View"
            displayName: "View"
        }
        ListElement {
            value: "Window"
            displayName: "Window"
        }
        ListElement {
            value: "Button"
            displayName: "Button"
        }
        ListElement {
            value: "Selection"
            displayName: "Selection"
        }
        ListElement {
            value: "Tooltip"
            displayName: "Tooltip"
        }
        ListElement {
            value: "Complementary"
            displayName: "Complementary"
        }
        ListElement {
            value: "Header"
            displayName: "Header"
        }
    }

    ListModel {
        id: themeColorModel
        ListElement {
            value: "textColor"
            displayName: "Text Color"
        }
        ListElement {
            value: "disabledTextColor"
            displayName: "Disabled Text Color"
        }
        ListElement {
            value: "highlightedTextColor"
            displayName: "Highlighted Text Color"
        }
        ListElement {
            value: "activeTextColor"
            displayName: "Active Text Color"
        }
        ListElement {
            value: "linkColor"
            displayName: "Link Color"
        }
        ListElement {
            value: "visitedLinkColor"
            displayName: "Visited LinkColor"
        }
        ListElement {
            value: "negativeTextColor"
            displayName: "Negative Text Color"
        }
        ListElement {
            value: "neutralTextColor"
            displayName: "Neutral Text Color"
        }
        ListElement {
            value: "positiveTextColor"
            displayName: "Positive Text Color"
        }
        ListElement {
            value: "backgroundColor"
            displayName: "Background Color"
        }
        ListElement {
            value: "highlightColor"
            displayName: "Highlight Color"
        }
        ListElement {
            value: "activeBackgroundColor"
            displayName: "Active Background Color"
        }
        ListElement {
            value: "linkBackgroundColor"
            displayName: "Link Background Color"
        }
        ListElement {
            value: "visitedLinkBackgroundColor"
            displayName: "Visited Link Background Color"
        }
        ListElement {
            value: "negativeBackgroundColor"
            displayName: "Negative Background Color"
        }
        ListElement {
            value: "neutralBackgroundColor"
            displayName: "Neutral Background Color"
        }
        ListElement {
            value: "positiveBackgroundColor"
            displayName: "Positive Background Color"
        }
        ListElement {
            value: "alternateBackgroundColor"
            displayName: "Alternate Background Color"
        }
        ListElement {
            value: "focusColor"
            displayName: "Focus Color"
        }
        ListElement {
            value: "hoverColor"
            displayName: "Hover Color"
        }
    }

    function updateConfig() {
        configString = JSON.stringify(config, null, null)
        updateConfigString(configString, config)
    }

    Kirigami.Separator {
        Kirigami.FormData.isSection: isSection
        Kirigami.FormData.label: sectionName || i18n("Color")
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
        visible: showFollowRadio
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
    // >
    RadioButton {
        Kirigami.FormData.label: i18n("Element:")
        id: followPanelBgRadio
        text: i18n("Panel background")
        ButtonGroup.group: followColorGroup
        property int index: 0
        checked: config.followColor === index
        visible: followColorRadio.checked
            && showFollowPanel
    }

    RadioButton {
        id: followWidgetBgRadio
        text: i18n("Widget background")
        ButtonGroup.group: followColorGroup
        property int index: 1
        checked: config.followColor === index
        visible: followColorRadio.checked
            && showFollowWidget
    }

    RadioButton {
        id: followTrayWidgetBgRadio
        text: i18n("Tray widget background")
        ButtonGroup.group: followColorGroup
        property int index: 2
        checked: config.followColor === index
        visible: followColorRadio.checked
            && showFollowTray
    }


    ButtonGroup {
        id: followColorGroup
        onCheckedButtonChanged: {
            if (checkedButton) {
                config.followColor = checkedButton.index
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
            config.custom = color.toString()
            updateConfig()
        }
    }

    ComboBox {
        id: colorSetCombobx
        Kirigami.FormData.label: i18n("Color set:")
        model: themeColorSetModel
        textRole: "displayName"
        visible: accentColorRadio.checked
        onCurrentIndexChanged: {
            config.systemColorSet = themeColorSetModel.get(currentIndex).value
            updateConfig()
        }
        Binding {
            target: colorSetCombobx
            property: "currentIndex"
            value: {
                for (var i = 0; i < themeColorSetModel.count; i++) {
                    if (themeColorSetModel.get(i).value === config.systemColorSet) {
                        return i;
                    }
                }
                return 0; // Default to the first item if no match is found
            }
        }
    }

    ComboBox {
        id: colorThemeCombobx
        Kirigami.FormData.label: i18n("Color:")
        model: themeColorModel
        textRole: "displayName"
        visible: accentColorRadio.checked
        onCurrentIndexChanged: {
            config.systemColor = themeColorModel.get(currentIndex).value
            updateConfig()
        }
        Binding {
            target: colorThemeCombobx
            property: "currentIndex"
            value: {
                for (var i = 0; i < themeColorModel.count; i++) {
                    if (themeColorModel.get(i).value === config.systemColor) {
                        return i;
                    }
                }
                return 0; // Default to the first item if no match is found
            }
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



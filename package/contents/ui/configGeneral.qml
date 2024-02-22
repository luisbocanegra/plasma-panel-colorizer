import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import "components" as Components

KCM.SimpleKCM {
    id:root
    property bool cfg_isEnabled: isEnabled.checked
    property int cfg_mode: plasmoid.configuration.mode
    property int cfg_colorMode: plasmoid.configuration.colorMode
    property string cfg_singleColor: singleColor.text
    property string cfg_customColors: customColors.text
    property real cfg_opacity: parseFloat(bgOpacity.text)
    property int cfg_radius: bgRadius.radius
    property real cfg_rainbowSaturation: rainbowSaturation.value
    property real cfg_rainbowLightness: rainbowLightness.value
    property int cfg_rainbowInterval: rainbowInterval.value
    property int cfg_rainbowTransition: rainbowTransition.value
    property string cfg_blacklist: blacklist.text
    property string cfg_paddingRules: paddingRules.text
    property bool cfg_hideWidget: hideWidget.text

    property bool cfg_fgColorEnabled: fgColorEnabled.checked
    property string cfg_customFgColor: customFgColor.text
    property real cfg_fgOpacity: parseFloat(fgOpacity.text)

    Kirigami.FormLayout {

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("General")
        }

        CheckBox {
            Kirigami.FormData.label: i18n("Enabled:")
            id: isEnabled
            checked: cfg_isEnabled
            onCheckedChanged: cfg_isEnabled = checked
        }

        CheckBox {
            Kirigami.FormData.label: i18n("Hide widget:")
            id: hideWidget
            checked: cfg_hideWidget
            onCheckedChanged: cfg_hideWidget = checked
        }

        Label {
            text: i18n("Widget will show only in panel Edit Mode")
            opacity: 0.7
            Layout.maximumWidth: 300
            wrapMode: Text.Wrap
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: false
            Layout.preferredHeight: Kirigami.Units.gridUnit
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: false
            Kirigami.FormData.label: i18n("<strong>Text / icons</strong>")
            Layout.fillWidth: true
        }

        CheckBox {
            Kirigami.FormData.label: i18n("Custom color:")
            id: fgColorEnabled
            checked: cfg_fgColorEnabled
            onCheckedChanged: cfg_fgColorEnabled = checked
        }

        TextField {
            id: customTextColor
            Kirigami.FormData.label: i18n("Color:")
            text: cfg_customFgColor
            enabled: fgColorEnabled.checked
            onTextChanged: cfg_customFgColor = text
        }

        TextField {
            id: fgOpacity
            Kirigami.FormData.label: i18n("Opacity:")
            placeholderText: "0-1"
            horizontalAlignment: TextInput.AlignHCenter
            text: parseFloat(cfg_fgOpacity)

            validator: DoubleValidator {
                bottom: 0.0
                top: 1.0
                decimals: 2
                notation: DoubleValidator.StandardNotation
            }

            onTextChanged: {
                const newVal = parseFloat(text)
                cfg_fgOpacity = isNaN(newVal) ? 0 : newVal
            }
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: false
            Layout.preferredHeight: Kirigami.Units.gridUnit
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: false
            Kirigami.FormData.label: i18n("<strong>Background</strong>")
            Layout.fillWidth: true
        }

        TextField {
            id: bgOpacity
            Kirigami.FormData.label: i18n("Opacity:")
            placeholderText: "0-1"
            horizontalAlignment: TextInput.AlignHCenter
            text: parseFloat(cfg_opacity)

            validator: DoubleValidator {
                bottom: 0.0
                top: 1.0
                decimals: 2
                notation: DoubleValidator.StandardNotation
            }

            onTextChanged: {
                const newVal = parseFloat(text)
                cfg_opacity = isNaN(newVal) ? 0 : newVal
            }
        }

        SpinBox {
            Kirigami.FormData.label: i18n("Radius:")
            id: bgRadius
            value: cfg_radius
            from: 0
            to: 99
            onValueModified: {
                cfg_radius = value
            }
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Color mode")
        }

        RadioButton {
            text: i18n("Static")
            id: staticColorMode
            ButtonGroup.group: animationModeGroup
            property int index: 0
            checked: plasmoid.configuration.mode === index
        }
        RadioButton {
            text: i18n("Animated")
            id: animatedColorMode
            ButtonGroup.group: animationModeGroup
            property int index: 1
            checked: plasmoid.configuration.mode === index
        }

        ButtonGroup {
            id: animationModeGroup
            onCheckedButtonChanged: {
                if (checkedButton) {
                    cfg_mode = checkedButton.index

                    // ensure valid option is checked as single and accent are
                    // disabled in animated mode
                    if (animatedColorMode.checked && cfg_colorMode <= 1) {
                        listColorRadio.checked = true
                    }
                }
            }
        }

        SpinBox {
            Kirigami.FormData.label: i18n("Interval (ms):")
            id: rainbowInterval
            from: 0
            to: 30000
            value: cfg_rainbowInterval
            onValueModified: {
                cfg_rainbowInterval = value
            }
            enabled: animatedColorMode.checked
        }

        SpinBox {
            Kirigami.FormData.label: i18n("Smoothing (ms):")
            id: rainbowTransition
            from: 0
            to: rainbowInterval.value
            value: cfg_rainbowTransition
            onValueModified: {
                cfg_rainbowTransition = value
            }
            enabled: animatedColorMode.checked
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Colors")
        }

        RadioButton {
            id: singleColorRadio
            Kirigami.FormData.label: i18n("Single")
            ButtonGroup.group: colorModeGroup
            property int index: 0
            checked: plasmoid.configuration.colorMode === index
            enabled: !animatedColorMode.checked
        }
        RadioButton {
            id: accentColorRadio
            Kirigami.FormData.label: i18n("Accent")
            ButtonGroup.group: colorModeGroup
            property int index: 1
            checked: plasmoid.configuration.colorMode === index
            enabled: !animatedColorMode.checked
        }
        RadioButton {
            id: listColorRadio
            Kirigami.FormData.label: i18n("Custom list")
            ButtonGroup.group: colorModeGroup
            property int index: 2
            checked: plasmoid.configuration.colorMode === index
            // visible: !staticColorMode.checked
        }
        RadioButton {
            id: randomColorRadio
            Kirigami.FormData.label: i18n("Random")
            ButtonGroup.group: colorModeGroup
            property int index: 3
            checked: plasmoid.configuration.colorMode === index
            // visible: !staticColorMode.checked
        }

        ButtonGroup {
            id: colorModeGroup
            onCheckedButtonChanged: {
                if (checkedButton) {
                    cfg_colorMode = checkedButton.index
                }
            }
        }

        TextField {
            id: singleColor
            Kirigami.FormData.label: i18n("Color:")
            text: cfg_singleColor
            enabled: singleColorRadio.checked
            onTextChanged: cfg_singleColor = text
        }
        TextField {
            id: customColors
            Kirigami.FormData.label: i18n("Colors list")
            text: cfg_customColors
            enabled: listColorRadio.checked
            onTextChanged: cfg_customColors = text
            // Layout.minimumWidth: 300
            // Layout.maximumWidth: 300
        }

        TextField {
            id: rainbowSaturation
            Kirigami.FormData.label: i18n("Saturation:")
            placeholderText: "0-1"
            horizontalAlignment: TextInput.AlignHCenter
            text: parseFloat(cfg_rainbowSaturation)
            enabled: randomColorRadio.checked

            validator: DoubleValidator {
                bottom: 0.0
                top: 1.0
                decimals: 2
                notation: DoubleValidator.StandardNotation
            }

            onTextChanged: {
                const newVal = parseFloat(text)
                cfg_rainbowSaturation = isNaN(newVal) ? 0 : newVal
            }
        }

        TextField {
            id: rainbowLightness
            Kirigami.FormData.label: i18n("Lightness:")
            placeholderText: "0-1"
            horizontalAlignment: TextInput.AlignHCenter
            text: parseFloat(cfg_rainbowLightness)
            enabled: randomColorRadio.checked

            validator: DoubleValidator {
                bottom: 0.0
                top: 1.0
                decimals: 2
                notation: DoubleValidator.StandardNotation
            }

            onTextChanged: {
                const newVal = parseFloat(text)
                cfg_rainbowLightness = isNaN(newVal) ? 0 : newVal
            }
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: "Blacklist"
        }

        TextArea {
            Kirigami.FormData.label: i18n("Blacklisted plasmoids (one per line):")
            Layout.minimumWidth: 300
            id: blacklist
            text: cfg_blacklist
            onTextChanged: cfg_blacklist = text
        }

        Label {
            text: i18n("Widgets that contain any of the strings in the list will not be colorized")
            opacity: 0.7
            Layout.maximumWidth: 300
            wrapMode: Text.Wrap
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Background padding rules")
        }

        TextArea {
            Kirigami.FormData.label: i18n("Rules (one per line):")
            Layout.minimumWidth: 300
            id: paddingRules
            text: cfg_paddingRules
            onTextChanged: cfg_paddingRules = text
        }

        Label {
            text: i18n("Some widgets may fill or let margins around even when their elements could fit in a smaller/bigger size, making their tinted area bigger/smaller, this option allows setting height and width offset to circumvent this.")
            opacity: 0.7
            Layout.maximumWidth: 300
            wrapMode: Text.Wrap
        }
    }
}

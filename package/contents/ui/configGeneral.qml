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
    property int cfg_radius: bgRadius.value
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


    property int cfg_panelPadding: panelPadding.value
    property int cfg_enableCustomPadding: enableCustomPadding.value

    property bool cfg_panelBgEnabled: panelBgEnabled.checked
    property string cfg_panelBgColor: panelBgColor.text
    property real cfg_panelBgOpacity: parseFloat(panelBgOpacity.text)
    property int cfg_panelBgRadius: panelBgRadius.value

    property string cfg_forceRecolor: forceRecolor.text

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
            text: i18n("Widget will show in panel Edit Mode")
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
            text: parseFloat(cfg_fgOpacity).toFixed(validator.decimals)

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

            Components.ValueMouseControl {
                height: parent.height - 8
                width: height
                anchors.right: parent.right
                anchors.rightMargin: 4
                anchors.verticalCenter: parent.verticalCenter

                from: parent.validator.bottom
                to: parent.validator.top
                decimals: parent.validator.decimals
                stepSize: 0.1
                value: cfg_fgOpacity
                onValueChanged: {
                    cfg_fgOpacity = parseFloat(value)
                }
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
            text: parseFloat(cfg_opacity).toFixed(validator.decimals)

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

            Components.ValueMouseControl {
                height: parent.height - 8
                width: height
                anchors.right: parent.right
                anchors.rightMargin: 4
                anchors.verticalCenter: parent.verticalCenter

                from: parent.validator.bottom
                to: parent.validator.top
                decimals: parent.validator.decimals
                stepSize: 0.1
                value: cfg_opacity
                onValueChanged: {
                    cfg_opacity = parseFloat(value)
                }
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
            stepSize: 100
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
            stepSize: 100
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
        }

        TextField {
            id: rainbowSaturation
            Kirigami.FormData.label: i18n("Saturation:")
            placeholderText: "0-1"
            horizontalAlignment: TextInput.AlignHCenter
            text: parseFloat(cfg_rainbowSaturation).toFixed(validator.decimals)
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

            Components.ValueMouseControl {
                height: parent.height - 8
                width: height
                anchors.right: parent.right
                anchors.rightMargin: 4
                anchors.verticalCenter: parent.verticalCenter

                from: parent.validator.bottom
                to: parent.validator.top
                decimals: parent.validator.decimals
                stepSize: 0.1
                value: cfg_rainbowSaturation
                onValueChanged: {
                    cfg_rainbowSaturation = parseFloat(value)
                }
            }
        }

        TextField {
            id: rainbowLightness
            Kirigami.FormData.label: i18n("Lightness:")
            placeholderText: "0-1"
            horizontalAlignment: TextInput.AlignHCenter
            text: parseFloat(cfg_rainbowLightness).toFixed(validator.decimals)
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

            Components.ValueMouseControl {
                height: parent.height - 8
                width: height
                anchors.right: parent.right
                anchors.rightMargin: 4
                anchors.verticalCenter: parent.verticalCenter

                from: parent.validator.bottom
                to: parent.validator.top
                decimals: parent.validator.decimals
                stepSize: 0.1
                value: cfg_rainbowLightness
                onValueChanged: {
                    cfg_rainbowLightness = parseFloat(value)
                }
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

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Panel")
        }

        CheckBox {
            Kirigami.FormData.label: i18n("Custom background:")
            id: panelBgEnabled
            checked: cfg_panelBgEnabled
            onCheckedChanged: cfg_panelBgEnabled = checked
        }

        TextField {
            id: panelBgColor
            Kirigami.FormData.label: i18n("Color:")
            text: cfg_panelBgColor
            enabled: panelBgEnabled.checked
            onTextChanged: cfg_panelBgColor = text
        }

        TextField {
            id: panelBgOpacity
            Kirigami.FormData.label: i18n("Opacity:")
            placeholderText: "0-1"
            horizontalAlignment: TextInput.AlignHCenter
            text: parseFloat(cfg_panelBgOpacity).toFixed(validator.decimals)
            enabled: panelBgEnabled.checked

            validator: DoubleValidator {
                bottom: 0.0
                top: 1.0
                decimals: 2
                notation: DoubleValidator.StandardNotation
            }

            onTextChanged: {
                const newVal = parseFloat(text)
                cfg_panelBgOpacity = isNaN(newVal) ? 0 : newVal
            }

            Components.ValueMouseControl {
                height: parent.height - 8
                width: height
                anchors.right: parent.right
                anchors.rightMargin: 4
                anchors.verticalCenter: parent.verticalCenter

                from: parent.validator.bottom
                to: parent.validator.top
                decimals: parent.validator.decimals
                stepSize: 0.1
                value: cfg_panelBgOpacity
                onValueChanged: {
                    cfg_panelBgOpacity = parseFloat(value)
                }
            }
        }

        SpinBox {
            Kirigami.FormData.label: i18n("Radius:")
            id: panelBgRadius
            value: cfg_panelBgRadius
            from: 0
            to: 99
            enabled: panelBgEnabled.checked
            onValueModified: {
                cfg_panelBgRadius = value
            }
        }

        Label {
            text: i18n("Custom background is drawn above the panel background, this may change in the future if I find out how to hide the original one")
            opacity: 0.7
            Layout.maximumWidth: 300
            wrapMode: Text.Wrap
        }

        CheckBox {
            Kirigami.FormData.label: i18n("Custom fixed side padding:")
            id: enableCustomPadding
            checked: cfg_enableCustomPadding
            onCheckedChanged: cfg_enableCustomPadding = checked
        }

        SpinBox {
            Kirigami.FormData.label: i18n("Padding (px):")
            id: panelPadding
            value: cfg_panelPadding
            from: 0
            to: 99
            enabled: enableCustomPadding.checked
            onValueModified: {
                cfg_panelPadding = value
            }
        }

        Label {
            text: i18n("Changing panel visibility settings with this option enabled may cause some jankiness, specially in edit mode. Disable and restart Plasma or logout to restore the original padding.")
            opacity: 0.7
            Layout.maximumWidth: 300
            wrapMode: Text.Wrap
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Force icon color")
        }

        TextArea {
            Kirigami.FormData.label: i18n("Plasmoids (one per line):")
            Layout.minimumWidth: 300
            id: forceRecolor
            text: cfg_forceRecolor
            onTextChanged: cfg_forceRecolor = text
        }

        Label {
            text: i18n("Force Kirigami.Icon color to specific plasmoids using the isMask property. Disable and restart Plasma or logout to restore the original color for those icons.")
            opacity: 0.7
            Layout.maximumWidth: 300
            wrapMode: Text.Wrap
        }
    }
}

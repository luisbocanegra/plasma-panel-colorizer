import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import "components" as Components

KCM.SimpleKCM {
    id:root
    property bool cfg_widgetBgEnabled: widgetBgEnabled.checked
    property int cfg_mode: plasmoid.configuration.mode
    property int cfg_colorMode: plasmoid.configuration.colorMode
    property string cfg_singleColor: singleColor.color
    property string cfg_customColors: customColors.text

    property real cfg_opacity: parseFloat(bgOpacity.text)
    property int cfg_radius: bgRadius.value
    property real cfg_rainbowSaturation: rainbowSaturation.text
    property real cfg_rainbowLightness: rainbowLightness.text
    property int cfg_rainbowInterval: rainbowInterval.value
    property int cfg_rainbowTransition: rainbowTransition.value
    property string cfg_paddingRules: paddingRules.text

    property string cfg_widgetOutlineColor: widgetOutlineColor.color
    property int cfg_widgetOutlineWidth: widgetOutlineWidth.value
    property int cfg_widgetShadowSize: widgetShadowSize.value
    property string cfg_widgetShadowColor: widgetShadowColor.color
    property int cfg_widgetShadowX: widgetShadowColorX.value
    property int cfg_widgetShadowY: widgetShadowColorY.value


    property bool clearing: false

    ListModel {
        id: customColorsModel
    }

    Connections {
        target: customColorsModel
        onCountChanged: {
            if (clearing) return
            console.log("model count changed:", customColorsModel.count);
            updateString()
        }
    }

    function initModel() {
        clearing = true
        customColorsModel.clear()
        const colors = cfg_customColors.split(" ")
        for (let i in colors) {
            customColorsModel.append({"color": colors[i]})
        }
        clearing = false
    }

    function getRandomColor() {
        const h = Math.random()
        const s = Math.random()
        const l = Math.random()
        const a = 1.0
        console.log(h,s,l);
        return Qt.hsla(h,s,l,a)
    }

    function updateString() {
        console.log("updateString()");
        let colors_list = []
        for (let i = 0; i < customColorsModel.count; i++) {
            let c = customColorsModel.get(i).color
            console.log(c);
            colors_list.push(c)
        }
        cfg_customColors = colors_list.join(" ")
    }

    Component.onCompleted: {
        initModel()
    }

    Kirigami.FormLayout {

        CheckBox {
            Kirigami.FormData.label: i18n("Custom background:")
            id: widgetBgEnabled
            checked: cfg_widgetBgEnabled
            onCheckedChanged: cfg_widgetBgEnabled = checked
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
                stepSize: 0.05
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
            Kirigami.FormData.isSection: false
            Kirigami.FormData.label: i18n("Outline")
            Layout.fillWidth: true
        }

        Components.ColorButton {
            id: widgetOutlineColor
            Kirigami.FormData.label: i18n("Color:")
            showAlphaChannel: true
            dialogTitle: i18n("Widget outline")
            color: cfg_widgetOutlineColor
            onAccepted: {
                cfg_widgetOutlineColor = color
            }
        }

        SpinBox {
            Kirigami.FormData.label: i18n("Width:")
            id: widgetOutlineWidth
            value: cfg_widgetOutlineWidth
            from: 0
            to: 99
            onValueModified: {
                cfg_widgetOutlineWidth = value
            }
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: false
            Kirigami.FormData.label: i18n("Shadow")
            Layout.fillWidth: true
        }

        Components.ColorButton {
            id: widgetShadowColor
            Kirigami.FormData.label: i18n("Color:")
            showAlphaChannel: true
            dialogTitle: i18n("Widget shadow")
            color: cfg_widgetShadowColor
            onAccepted: {
                cfg_widgetShadowColor = color
            }
        }

        SpinBox {
            Kirigami.FormData.label: i18n("Size:")
            id: widgetShadowSize
            value: cfg_widgetShadowSize
            from: 0
            to: 99
            onValueModified: {
                cfg_widgetShadowSize = value
            }
        }

        SpinBox {
            Kirigami.FormData.label: i18n("X offset:")
            id: widgetShadowX
            value: cfg_widgetShadowX
            from: -99
            to: 99
            onValueModified: {
                cfg_widgetShadowX = value
            }
        }

        SpinBox {
            Kirigami.FormData.label: i18n("Y offset:")
            id: widgetShadowY
            value: cfg_widgetShadowY
            from: -99
            to: 99
            onValueModified: {
                cfg_widgetShadowY = value
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

        Components.ColorButton {
            id: singleColor
            Kirigami.FormData.label: i18n("Color:")
            showAlphaChannel: false
            dialogTitle: i18n("Widget background")
            color: cfg_singleColor
            visible: singleColorRadio.checked
            onAccepted: {
                cfg_singleColor = color
            }
        }

        
        GroupBox {
            Kirigami.FormData.label: i18n("Colors list:")
            visible: listColorRadio.checked
            ColumnLayout {
                Layout.alignment: Qt.AlignTop
                Repeater {
                    id: customColorsRepeater
                    model: customColorsModel
                    delegate : RowLayout {

                        TextMetrics {
                            id: metrics
                            text: (model.length + 1).toString()
                        }

                        Label {
                            text: (index + 1).toString() + "."
                            Layout.preferredWidth: metrics.width
                        }

                        TextMetrics {
                            id: colorMetrics
                            text: "#FFFFFF"
                        }

                        TextArea {
                            text: modelData
                            font.capitalization: Font.AllUppercase
                            Kirigami.SpellCheck.enabled: false
                            Layout.preferredWidth: colorMetrics.width * 1.4
                        }

                        Components.ColorButton {
                            showAlphaChannel: false
                            dialogTitle: i18n("Widget background") + "("+index+")"
                            color: modelData
                            showCurentColor: false
                            onAccepted: (color) => {
                                customColorsModel.set(index, {"color": color.toString()})
                                updateString()
                            }
                        }

                        Button {
                            icon.name: "randomize-symbolic"
                            onClicked: {
                                customColorsModel.set(index, {"color": getRandomColor().toString() })
                                updateString()
                            }
                        }

                        Button {
                            // text: "up"
                            icon.name: "arrow-up"
                            enabled: index>0
                            onClicked: {
                                let prevIndex = index-1
                                let prev = customColorsModel.get(prevIndex).color
                                customColorsModel.set(prevIndex, customColorsModel.get(index))
                                customColorsModel.set(index, {"color":prev})
                                updateString()
                            }
                        }

                        Button {
                            icon.name: "arrow-down"
                            // anchors.right: parent.right
                            enabled: index < customColorsModel.count - 1
                            onClicked: {
                                let nextIndex = index+1
                                let next = customColorsModel.get(nextIndex).color
                                customColorsModel.set(nextIndex, customColorsModel.get(index))
                                customColorsModel.set(index, {"color":next})
                                updateString()
                            }
                        }

                        Button {
                            // text: "Remove"
                            icon.name: "edit-delete-remove"
                            // anchors.right: parent.right
                            onClicked: {
                                customColorsModel.remove(index)
                            }
                        }

                        Button {
                            icon.name: "list-add-symbolic"
                            onClicked: {
                                customColorsModel.insert(index+1, {"color": getRandomColor().toString() })
                            }
                        }
                    }
                }

                RowLayout {
                    TextArea {
                        id: customColors
                        text: cfg_customColors
                        onTextChanged: {
                            cfg_customColors = text
                        }
                        Layout.preferredWidth: 300
                        wrapMode: TextEdit.WordWrap
                        font.capitalization: Font.AllUppercase
                        Kirigami.SpellCheck.enabled: false
                    }
                    Button {
                        id: btn
                        icon.name: "view-refresh-symbolic"
                        onClicked: initModel()
                    }
                }
            }
        }

        TextField {
            id: rainbowSaturation
            Kirigami.FormData.label: i18n("Saturation:")
            placeholderText: "0-1"
            horizontalAlignment: TextInput.AlignHCenter
            text: parseFloat(cfg_rainbowSaturation).toFixed(validator.decimals)
            visible: randomColorRadio.checked

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
                stepSize: 0.05
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
            visible: randomColorRadio.checked

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
                stepSize: 0.05
                value: cfg_rainbowLightness
                onValueChanged: {
                    cfg_rainbowLightness = parseFloat(value)
                }
            }
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

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
    property bool cfg_bgContrastFixEnabled: bgContrastFixEnabled.checked
    property bool cfg_bgSaturationEnabled: bgSaturationEnabled.checked
    property real cfg_bgSaturation: bgSaturation.text
    property real cfg_bgLightness: bgLightness.text
    property int cfg_rainbowInterval: rainbowInterval.value
    property int cfg_rainbowTransition: rainbowTransition.value

    property int cfg_widgetBgHMargin: widgetBgHMargin.value
    property int cfg_widgetBgVMargin: widgetBgHMargin.value
    property string cfg_marginRules: ""

    property string cfg_widgetOutlineColor: widgetOutlineColor.color
    property int cfg_widgetOutlineWidth: widgetOutlineWidth.value
    property int cfg_widgetShadowSize: widgetShadowSize.value
    property string cfg_widgetShadowColor: widgetShadowColor.color
    property int cfg_widgetShadowX: widgetShadowColorX.value
    property int cfg_widgetShadowY: widgetShadowColorY.value

    property bool cfg_bgLineModeEnabled: bgLineModeEnabled.checked
    property int cfg_bgLinePosition: plasmoid.configuration.bgLinePosition
    property int cfg_bgLineWidth: bgLineWidth.value
    property int cfg_bgLineXOffset: bgLineXOffset.value
    property int cfg_bgLineYOffset: bgLineYOffset.value

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

    property string cfg_panelWidgets

    ListModel {
        id: widgetsModel
    }

    function initWidgets(){
        const lines = cfg_panelWidgets.trim().split("|")
        for (let i in lines) {
            if (lines[i].length < 1) continue
            const parts = lines[i].split(",")
            const name = parts[0]
            const title = parts[1]
            const icon = parts[2]
            widgetsModel.append(
                {
                    "name": name,
                    "title": title,
                    "icon": icon,
                    "enabled": false,
                    "vExtraMargin": 0,
                    "hExtraMargin": 0
                }
            )
        }
    }

    function updateWidgetsModel(){
        let widgeList = []
        const forceRecolorList = cfg_marginRules.split("|")
        for (let i = 0; i < widgetsModel.count; i++) {
            let widget = widgetsModel.get(i)
            // if (widget.length < 1) continue
            let name = ""
            let vMargin = 0
            let hMargin = 0 
            for (let j in forceRecolorList) {
                if (forceRecolorList[j].length < 1) continue
                const parts = forceRecolorList[j].split(",")
                //console.error(widget.name, parts.join(" "));
                name = parts[0]
                if(widget.name.includes(name)) {
                    vMargin = parseInt(parts[1])
                    hMargin = parseInt(parts[2])
                    widgetsModel.set(i, {"vExtraMargin": vMargin, "hExtraMargin": hMargin})
                    break
                }
            }
        }
    }

    function updateWidgetsString(){
        var newString = ""
        for (let i = 0; i < widgetsModel.count; i++) {
            let widget = widgetsModel.get(i)
            newString += widget.name + "," + widget.vExtraMargin + "," + widget.hExtraMargin + "|"
        }
        cfg_marginRules = newString
    }

    Component.onCompleted: {
        initModel()
        initWidgets()
        updateWidgetsModel()
    }

    ColumnLayout {
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            Label {
                text: "Enabled:"
            }
            CheckBox {
                id: widgetBgEnabled
                checked: cfg_widgetBgEnabled
                onCheckedChanged: cfg_widgetBgEnabled = checked
            }
        }

    Kirigami.FormLayout {
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Shape")
        }

        RowLayout {
            TextField {
                id: bgOpacity
                Kirigami.FormData.label: i18n("Opacity:")
                placeholderText: "0-1"
                text: parseFloat(cfg_opacity).toFixed(validator.decimals)
                Layout.preferredWidth: Kirigami.Units.gridUnit * 4

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

        CheckBox {
            Kirigami.FormData.label: i18n("Line:")
            text: i18n("Enabled")
            id: bgLineModeEnabled
            checked: cfg_bgLineModeEnabled
            onCheckedChanged: cfg_bgLineModeEnabled = checked
        }

        RadioButton {
            Kirigami.FormData.label: i18n("Position:")
            text: i18n("Top")
            ButtonGroup.group: bgLinePositionGroup
            property int index: 0
            checked: plasmoid.configuration.bgLinePosition === index
            enabled: bgLineModeEnabled.checked
        }
        RadioButton {
            text: i18n("Bottom")
            ButtonGroup.group: bgLinePositionGroup
            property int index: 1
            checked: plasmoid.configuration.bgLinePosition === index
            enabled: bgLineModeEnabled.checked
        }
        RadioButton {
            text: i18n("Left")
            ButtonGroup.group: bgLinePositionGroup
            property int index: 2
            checked: plasmoid.configuration.bgLinePosition === index
            enabled: bgLineModeEnabled.checked
        }
        RadioButton {
            text: i18n("Right")
            ButtonGroup.group: bgLinePositionGroup
            property int index: 3
            checked: plasmoid.configuration.bgLinePosition === index
            enabled: bgLineModeEnabled.checked
        }
        ButtonGroup {
            id: bgLinePositionGroup
            onCheckedButtonChanged: {
                if (checkedButton) {
                    cfg_bgLinePosition = checkedButton.index
                }
            }
        }

        SpinBox {
            Kirigami.FormData.label: i18n("Width:")
            id: bgLineWidth
            value: cfg_bgLineWidth
            from: 0
            to: 99
            onValueModified: {
                cfg_bgLineWidth = value
            }
            enabled: bgLineModeEnabled.checked
        }

        SpinBox {
            Kirigami.FormData.label: i18n("X offset:")
            id: bgLineXOffset
            value: cfg_bgLineXOffset
            from: -99
            to: 99
            onValueModified: {
                cfg_bgLineXOffset = value
            }
            enabled: bgLineModeEnabled.checked
        }
        SpinBox {
            Kirigami.FormData.label: i18n("Y offset:")
            id: bgLineYOffset
            value: cfg_bgLineYOffset
            from: -99
            to: 99
            onValueModified: {
                cfg_bgLineYOffset = value
            }
            enabled: bgLineModeEnabled.checked
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

        CheckBox {
            Kirigami.FormData.label: i18n("Contrast correction:")
            id: bgContrastFixEnabled
            checked: cfg_bgContrastFixEnabled
            onCheckedChanged: cfg_bgContrastFixEnabled = checked
        }

        CheckBox {
            Kirigami.FormData.label: i18n("Saturation:")
            text: i18n("Enable")
            id: bgSaturationEnabled
            checked: cfg_bgSaturationEnabled
            onCheckedChanged: cfg_bgSaturationEnabled = checked
            enabled: bgContrastFixEnabled.checked
        }
        RowLayout {
            TextField {
                id: bgSaturation
                Kirigami.FormData.label: i18n("Saturation:")
                placeholderText: "0-1"
                text: parseFloat(cfg_bgSaturation).toFixed(validator.decimals)
                enabled: bgContrastFixEnabled.checked && bgSaturationEnabled.checked
                Layout.preferredWidth: Kirigami.Units.gridUnit * 4

                validator: DoubleValidator {
                    bottom: 0.0
                    top: 1.0
                    decimals: 2
                    notation: DoubleValidator.StandardNotation
                }

                onTextChanged: {
                    const newVal = parseFloat(text)
                    cfg_bgSaturation = isNaN(newVal) ? 0 : newVal
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
                    value: cfg_bgSaturation
                    onValueChanged: {
                        cfg_bgSaturation = parseFloat(value)
                    }
                }
            }
        }
        RowLayout {
            TextField {
                id: bgLightness
                Kirigami.FormData.label: i18n("Lightness:")
                placeholderText: "0-1"
                text: parseFloat(cfg_bgLightness).toFixed(validator.decimals)
                enabled: bgContrastFixEnabled.checked
                Layout.preferredWidth: Kirigami.Units.gridUnit * 4

                validator: DoubleValidator {
                    bottom: 0.0
                    top: 1.0
                    decimals: 2
                    notation: DoubleValidator.StandardNotation
                }

                onTextChanged: {
                    const newVal = parseFloat(text)
                    cfg_bgLightness = isNaN(newVal) ? 0 : newVal
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
                    value: cfg_bgLightness
                    onValueChanged: {
                        cfg_bgLightness = parseFloat(value)
                    }
                }
            }
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Background margin rules")
        }

        SpinBox {
            Kirigami.FormData.label: i18n("Vertical:")
            id: widgetBgVMargin
            from: 0
            to: 999
            stepSize: 1
            value: cfg_widgetBgVMargin
            onValueModified: {
                cfg_widgetBgVMargin = value
            }
        }

        SpinBox {
            Kirigami.FormData.label: i18n("Horizontal:")
            id: widgetBgHMargin
            from: 0
            to: 999
            stepSize: 1
            value: cfg_widgetBgHMargin
            onValueModified: {
                cfg_widgetBgHMargin = value
            }
        }

        Label {
            text: i18n("Extra horizontal/vertical margins per widget:")
            Layout.maximumWidth: widgetCards.width
            wrapMode: Text.Wrap
        }

        ColumnLayout {
            id: widgetCards
            Repeater {
                model: widgetsModel
                delegate: Kirigami.AbstractCard {
                    contentItem: RowLayout {
                        Kirigami.Icon {
                            width: Kirigami.Units.gridUnit
                            height: width
                            source: widgetsModel.get(index).icon
                            // active: compact.containsMouse
                        }
                        ColumnLayout {
                            // anchors.fill: parent
                            Label {
                                text: widgetsModel.get(index).title
                            }
                            Label {
                                text: widgetsModel.get(index).name
                                opacity: 0.6
                            }
                        }
                        Item {
                            Layout.fillWidth: true
                        }

                        ColumnLayout {
                            RowLayout {
                                Layout.alignment: Qt.AlignRight
                                Label {
                                    text: i18n("V:")
                                }
                                SpinBox {
                                    from: -999
                                    to: 999
                                    value: widgetsModel.get(index).vExtraMargin
                                    onValueChanged: {
                                        widgetsModel.set(index, {"vExtraMargin": value})
                                        updateWidgetsString()
                                    }
                                }
                            }
                            RowLayout {
                                Layout.alignment: Qt.AlignRight
                                Label {
                                    text: i18n("H:")
                                }
                                SpinBox {
                                    from: -999
                                    to: 999
                                    value: widgetsModel.get(index).hExtraMargin
                                    onValueChanged: {
                                        widgetsModel.set(index, {"hExtraMargin": value})
                                        updateWidgetsString()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    }
}

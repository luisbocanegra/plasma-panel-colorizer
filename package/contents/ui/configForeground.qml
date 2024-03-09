import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import "components" as Components

KCM.SimpleKCM {
    id:root

    property bool cfg_fgColorEnabled: fgColorEnabled.checked
    property int cfg_fgMode: plasmoid.configuration.fgMode
    property int cfg_fgColorMode: plasmoid.configuration.fgColorMode
    property string cfg_fgSingleColor: fgSingleColor.color
    property string cfg_fgCustomColors: fgCustomColors.text

    property int cfg_fgRainbowInterval: fgRainbowInterval.value
    property bool widgetBgEnabled: plasmoid.configuration.widgetBgEnabled
    
    property real cfg_fgOpacity: parseFloat(fgOpacity.text)
    property string cfg_forceRecolor: ""

    property bool cfg_fgBlacklistedColorEnabled: fgBlacklistedColorEnabled.checked
    property string cfg_blacklistedFgColor: blacklistedFgColor.text

    property bool cfg_fgContrastFixEnabled: fgContrastFixEnabled.checked
    property bool cfg_fgSaturationEnabled: fgSaturationEnabled.checked
    property real cfg_fgSaturation: fgSaturation.text
    property real cfg_fgLightness: fgLightness.text

    property string cfg_panelWidgetsWithTray

    property bool clearing: false

    ListModel {
        id: fgCustomColorsModel
    }

    Connections {
        target: fgCustomColorsModel
        onCountChanged: {
            if (clearing) return
            console.log("model count changed:", fgCustomColorsModel.count);
            updateString()
        }
    }

    function initModel() {
        clearing = true
        fgCustomColorsModel.clear()
        const colors = cfg_fgCustomColors.split(" ")
        for (let i in colors) {
            fgCustomColorsModel.append({"color": colors[i]})
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
        for (let i = 0; i < fgCustomColorsModel.count; i++) {
            let c = fgCustomColorsModel.get(i).color
            console.log(c);
            colors_list.push(c)
        }
        cfg_fgCustomColors = colors_list.join(" ")
    }

    ListModel {
        id: widgetsModel
    }

    function initWidgets(){
        const lines = cfg_panelWidgetsWithTray.trim().split("|")
        for (let i in lines) {
            if (lines[i].length < 1) continue
            const parts = lines[i].split(",")
            const name = parts[0]
            const title = parts[1]
            const icon = parts[2]
            widgetsModel.append({"name": name, "title": title, "icon": icon, "enabled": false})
        }
    }

    function updateWidgetsModel(){
        let widgeList = []
        const forceRecolorList = cfg_forceRecolor.trim().split("|")
        console.log(forceRecolorList.join(" "));
        for (let i = 0; i < widgetsModel.count; i++) {
            let widget = widgetsModel.get(i)
            if (forceRecolorList.includes(widget.name)) {
                widgetsModel.set(i, {"enabled": true})
            }
        }
    }

    function updateWidgetsString(){
        var newString = ""
        for (let i = 0; i < widgetsModel.count; i++) {
            let widget = widgetsModel.get(i)
            if (widget.enabled) {
                newString += widget.name + "|"
            }
        }
        cfg_forceRecolor = newString
    }

    Component.onCompleted: {
        initModel()
        initWidgets()
        updateWidgetsModel()
    }

    ColumnLayout {
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            // horizontalAlignment: TextInput.AlignHCenter
            Label {
                text: "Enabled:"
            }
            CheckBox {
                // Kirigami.FormData.label: i18n("Enabled:")
                id: fgColorEnabled
                checked: cfg_fgColorEnabled
                onCheckedChanged: cfg_fgColorEnabled = checked
            }
        }
    Kirigami.FormLayout {
        RowLayout {
            TextField {
                id: fgOpacity
                Kirigami.FormData.label: i18n("Opacity:")
                placeholderText: "0-1"
                text: parseFloat(cfg_fgOpacity).toFixed(validator.decimals)
                Layout.preferredWidth: Kirigami.Units.gridUnit * 4

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
                    stepSize: 0.05
                    value: cfg_fgOpacity
                    onValueChanged: {
                        cfg_fgOpacity = parseFloat(value)
                    }
                }
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
            checked: plasmoid.configuration.fgMode === index
        }
        RadioButton {
            text: i18n("Interval")
            id: animatedColorMode
            ButtonGroup.group: animationModeGroup
            property int index: 1
            checked: plasmoid.configuration.fgMode === index
        }

        ButtonGroup {
            id: animationModeGroup
            onCheckedButtonChanged: {
                if (checkedButton) {
                    cfg_fgMode = checkedButton.index

                    // ensure valid option is checked as single and accent are
                    // disabled in animated mode
                    if (animatedColorMode.checked && cfg_fgMode <= 1) {
                        listColorRadio.checked = true
                    }
                }
            }
        }

        
        SpinBox {
            Kirigami.FormData.label: i18n("Interval (ms):")
            id: fgRainbowInterval
            from: 0
            to: 30000
            stepSize: 100
            value: cfg_fgRainbowInterval
            onValueModified: {
                cfg_fgRainbowInterval = value
            }
            enabled: animatedColorMode.checked
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Colors")
        }

        RadioButton {
            id: fgSingleColorRadio
            Kirigami.FormData.label: i18n("Single")
            ButtonGroup.group: colorModeGroup
            property int index: 0
            checked: plasmoid.configuration.fgColorMode === index
            enabled: !animatedColorMode.checked
        }
        RadioButton {
            id: accentColorRadio
            Kirigami.FormData.label: i18n("Accent")
            ButtonGroup.group: colorModeGroup
            property int index: 1
            checked: plasmoid.configuration.fgColorMode === index
            enabled: !animatedColorMode.checked
        }
        RadioButton {
            id: followBgColorRadio
            Kirigami.FormData.label: i18n("Widget background")
            ButtonGroup.group: colorModeGroup
            property int index: 4
            checked: plasmoid.configuration.fgColorMode === index
            // visible: !staticColorMode.checked
            enabled: !animatedColorMode.checked && widgetBgEnabled
            text: !widgetBgEnabled ? "Widget background is disabled" : ""
        }
        RadioButton {
            id: listColorRadio
            Kirigami.FormData.label: i18n("Custom list")
            ButtonGroup.group: colorModeGroup
            property int index: 2
            checked: plasmoid.configuration.fgColorMode === index
            // visible: !staticColorMode.checked
        }
        RadioButton {
            id: randomColorRadio
            Kirigami.FormData.label: i18n("Random")
            ButtonGroup.group: colorModeGroup
            property int index: 3
            checked: plasmoid.configuration.fgColorMode === index
            // visible: !staticColorMode.checked
        }

        ButtonGroup {
            id: colorModeGroup
            onCheckedButtonChanged: {
                if (checkedButton) {
                    cfg_fgColorMode = checkedButton.index
                }
            }
        }

        Components.ColorButton {
            id: fgSingleColor
            Kirigami.FormData.label: i18n("Color:")
            showAlphaChannel: false
            dialogTitle: i18n("Text/icons")
            color: cfg_fgSingleColor
            visible: fgSingleColorRadio.checked
            onAccepted: {
                cfg_fgSingleColor = color
            }
        }

        
        GroupBox {
            Kirigami.FormData.label: i18n("Colors list:")
            visible: listColorRadio.checked
            ColumnLayout {
                Layout.alignment: Qt.AlignTop
                Repeater {
                    id: fgCustomColorsRepeater
                    model: fgCustomColorsModel
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
                                fgCustomColorsModel.set(index, {"color": color.toString()})
                                updateString()
                            }
                        }

                        Button {
                            icon.name: "randomize-symbolic"
                            onClicked: {
                                fgCustomColorsModel.set(index, {"color": getRandomColor().toString() })
                                updateString()
                            }
                        }

                        Button {
                            // text: "up"
                            icon.name: "arrow-up"
                            enabled: index>0
                            onClicked: {
                                let prevIndex = index-1
                                let prev = fgCustomColorsModel.get(prevIndex).color
                                fgCustomColorsModel.set(prevIndex, fgCustomColorsModel.get(index))
                                fgCustomColorsModel.set(index, {"color":prev})
                                updateString()
                            }
                        }

                        Button {
                            icon.name: "arrow-down"
                            // anchors.right: parent.right
                            enabled: index < fgCustomColorsModel.count - 1
                            onClicked: {
                                let nextIndex = index+1
                                let next = fgCustomColorsModel.get(nextIndex).color
                                fgCustomColorsModel.set(nextIndex, fgCustomColorsModel.get(index))
                                fgCustomColorsModel.set(index, {"color":next})
                                updateString()
                            }
                        }

                        Button {
                            // text: "Remove"
                            icon.name: "edit-delete-remove"
                            // anchors.right: parent.right
                            onClicked: {
                                fgCustomColorsModel.remove(index)
                            }
                        }

                        Button {
                            icon.name: "list-add-symbolic"
                            onClicked: {
                                fgCustomColorsModel.insert(index+1, {"color": getRandomColor().toString() })
                            }
                        }
                    }
                }

                RowLayout {
                    TextArea {
                        id: fgCustomColors
                        text: cfg_fgCustomColors
                        onTextChanged: {
                            cfg_fgCustomColors = text
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
            id: fgContrastFixEnabled
            checked: cfg_fgContrastFixEnabled
            onCheckedChanged: cfg_fgContrastFixEnabled = checked
            // visible: !randomColorRadio.checked
        }

        CheckBox {
            Kirigami.FormData.label: i18n("Saturation:")
            text: i18n("Enable")
            id: fgSaturationEnabled
            checked: cfg_fgSaturationEnabled
            onCheckedChanged: cfg_fgSaturationEnabled = checked
            enabled: fgContrastFixEnabled.checked
        }

        RowLayout {
            TextField {
                id: fgSaturation
                placeholderText: "0-1"
                text: parseFloat(cfg_fgSaturation).toFixed(validator.decimals)
                enabled: fgContrastFixEnabled.checked && fgSaturationEnabled.checked
                Layout.preferredWidth: Kirigami.Units.gridUnit * 4

                validator: DoubleValidator {
                    bottom: 0.0
                    top: 1.0
                    decimals: 2
                    notation: DoubleValidator.StandardNotation
                }

                onTextChanged: {
                    const newVal = parseFloat(text)
                    cfg_fgSaturation = isNaN(newVal) ? 0 : newVal
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
                    value: cfg_fgSaturation
                    onValueChanged: {
                        cfg_fgSaturation = parseFloat(value)
                    }
                }
            }
        }
        RowLayout {
            TextField {
                id: fgLightness
                Kirigami.FormData.label: i18n("Lightness:")
                placeholderText: "0-1"
                text: parseFloat(cfg_fgLightness).toFixed(validator.decimals)
                enabled: fgContrastFixEnabled.checked
                Layout.preferredWidth: Kirigami.Units.gridUnit * 4

                validator: DoubleValidator {
                    bottom: 0.0
                    top: 1.0
                    decimals: 2
                    notation: DoubleValidator.StandardNotation
                }

                onTextChanged: {
                    const newVal = parseFloat(text)
                    cfg_fgLightness = isNaN(newVal) ? 0 : newVal
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
                    value: cfg_fgLightness
                    onValueChanged: {
                        cfg_fgLightness = parseFloat(value)
                    }
                }
            }
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Blacklisted")
        }

        CheckBox {
            Kirigami.FormData.label: i18n("Blacklisted color:")
            id: fgBlacklistedColorEnabled
            checked: cfg_fgBlacklistedColorEnabled 
            onCheckedChanged: cfg_fgBlacklistedColorEnabled = checked
        }

        Components.ColorButton {
            id: blacklistedFgColor
            showAlphaChannel: false
            dialogTitle: i18n("Blacklisted text/icons")
            Kirigami.FormData.label: i18n("Color:")
            color: cfg_blacklistedFgColor
            enabled: fgBlacklistedColorEnabled.checked
            onAccepted: {
                cfg_blacklistedFgColor = color
            }
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Force icon color")
        }

        Label {
            text: i18n("Force icon color to specific plasmoids. Disable and restart Plasma or logout to restore the original color for those icons.")
            opacity: 0.7
            Layout.maximumWidth: 400
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
                        }
                        ColumnLayout {
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
                        Button {
                            checkable: true
                            checked: widgetsModel.get(index).enabled
                            icon.name: checked ? "checkmark-symbolic" : "edit-delete-remove-symbolic"
                            onCheckedChanged: {
                                widgetsModel.set(index, {"enabled": checked})
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

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
    property alias cfg_fgColorModeTheme: fgColorModeTheme.currentIndex
    property alias cfg_fgColorModeThemeVariant: fgColorModeThemeVariant.currentIndex
    property string cfg_fgSingleColor: fgSingleColor.color
    property string cfg_fgCustomColors: fgCustomColors.text

    property int cfg_fgRainbowInterval: fgRainbowInterval.value
    property bool widgetBgEnabled: plasmoid.configuration.widgetBgEnabled
    
    property real cfg_fgOpacity: parseFloat(fgOpacity.text)
    property string cfg_forceRecolor: ""

    property bool cfg_fgContrastFixEnabled: fgContrastFixEnabled.checked
    property bool cfg_fgSaturationEnabled: fgSaturationEnabled.checked
    property real cfg_fgSaturation: fgSaturation.text
    property real cfg_fgLightness: fgLightness.text

    property string cfg_panelWidgetsWithTray

    property bool clearing: false

    property bool cfg_fgShadowEnabled: fgShadowEnabled.checked
    property string cfg_fgShadowColor: fgShadowColor.color
    property int cfg_fgShadowX: fgShadowX.value
    property int cfg_fgShadowY: fgShadowY.value
    property int cfg_fgShadowRadius: fgShadowRadius.value
    property bool cfg_fixCustomBadges: fixCustomBadgesCheckbox.checked

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
        console.log("UPDATING STRING");
        console.log("current:", cfg_forceRecolor);
        var currentWidgets = new Set(cfg_forceRecolor.trim().split("|"))

        for (let i = 0; i < widgetsModel.count; i++) {
            const widget = widgetsModel.get(i)
            if (widget.enabled) {
                currentWidgets.add(widget.name)
            } else {
                currentWidgets.delete(widget.name)
            }
        }
        cfg_forceRecolor = Array.from(currentWidgets).join("|")
        console.log("new:", cfg_forceRecolor)
    }

    Component.onCompleted: {
        initModel()
        initWidgets()
        updateWidgetsModel()
    }

    header: RowLayout {
        RowLayout {
            Layout.leftMargin: Kirigami.Units.mediumSpacing
            Layout.rightMargin: Kirigami.Units.smallSpacing
            RowLayout {
                Layout.alignment: Qt.AlignRight
                Label {
                    text: i18n("Enabled:")
                }
                CheckBox {
                    id: fgColorEnabled
                    checked: cfg_fgColorEnabled
                    onCheckedChanged: cfg_fgColorEnabled = checked
                }
            }
            Item {
                Layout.fillWidth: true
            }
            RowLayout {
                Layout.alignment: Qt.AlignRight
                Label {
                    text: i18n("Last preset loaded:")
                }
                Label {
                    text: plasmoid.configuration.lastPreset || "None"
                    font.weight: Font.DemiBold
                }
            }
        }
    }

    ColumnLayout {
    Kirigami.FormLayout {
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
        
        // RowLayout {
            RadioButton {
                id: fgSingleColorRadio
                Kirigami.FormData.label: i18n("Source:")
                text: i18n("Custom")
                ButtonGroup.group: colorModeGroup
                property int index: 0
                checked: plasmoid.configuration.fgColorMode === index
                enabled: !animatedColorMode.checked
            }
        // }
        // RowLayout {
            RadioButton {
                text: i18n("System")
                id: accentColorRadio
                ButtonGroup.group: colorModeGroup
                property int index: 1
                checked: plasmoid.configuration.fgColorMode === index
                enabled: !animatedColorMode.checked
            }
        // }
        RadioButton {
            id: followBgColorRadio
            ButtonGroup.group: colorModeGroup
            property int index: 4
            checked: plasmoid.configuration.fgColorMode === index
            enabled: !animatedColorMode.checked && widgetBgEnabled
            text: !widgetBgEnabled ? i18n("Widget background is disabled") : i18n("Widget background")
        }
        RadioButton {
            id: listColorRadio
            text: i18n("Custom list")
            ButtonGroup.group: colorModeGroup
            property int index: 2
            checked: plasmoid.configuration.fgColorMode === index
            // visible: !staticColorMode.checked
        }
        RadioButton {
            id: randomColorRadio
            text: i18n("Random")
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
            showAlphaChannel: false
            dialogTitle: i18n("Text/icons")
            color: cfg_fgSingleColor
            visible: fgSingleColorRadio.checked
            onAccepted: {
                cfg_fgSingleColor = color
            }
        }

        ComboBox {
            id: fgColorModeTheme
            Kirigami.FormData.label: i18n("Color:")
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
        }

        ComboBox {
            id: fgColorModeThemeVariant
            Kirigami.FormData.label: i18n("Color set:")
            model: [i18n("View"), i18n("Window"), i18n("Button"), i18n("Selection"), i18n("Tooltip"), i18n("Complementary"), i18n("Header")]
            visible: accentColorRadio.checked
        }

        GroupBox {
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

        RowLayout {
            Kirigami.FormData.label: i18n("Opacity:")
            TextField {
                id: fgOpacity
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
            Kirigami.FormData.label: i18n("Saturation:")
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
            Kirigami.FormData.label: i18n("Lightness:")
            TextField {
                id: fgLightness
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
            Kirigami.FormData.label: i18n("Shadow")
        }

        CheckBox {
            Kirigami.FormData.label: i18n("Enabled:")
            id: fgShadowEnabled
            checked: cfg_fgShadowEnabled
            onCheckedChanged: cfg_fgShadowEnabled = checked
            enabled: fgColorEnabled.checked
        }


        Components.ColorButton {
            id: fgShadowColor
            Kirigami.FormData.label: i18n("Color:")
            showAlphaChannel: true
            dialogTitle: i18n("Panel shadow")
            color: cfg_fgShadowColor
            enabled: fgColorEnabled.checked && fgShadowEnabled.checked
            onAccepted: {
                cfg_fgShadowColor = color
            }
        }

        SpinBox {
            Kirigami.FormData.label: i18n("Strength:")
            id: fgShadowRadius
            value: cfg_fgShadowRadius
            from: 0
            to: 99
            enabled: fgColorEnabled.checked && fgShadowEnabled.checked
            onValueModified: {
                cfg_fgShadowRadius = value
            }
        }

        SpinBox {
            Kirigami.FormData.label: i18n("X offset:")
            id: fgShadowX
            value: cfg_fgShadowX
            from: -99
            to: 99
            enabled: fgColorEnabled.checked && fgShadowEnabled.checked
            onValueModified: {
                cfg_fgShadowX = value
            }
        }

        SpinBox {
            Kirigami.FormData.label: i18n("Y offset:")
            id: fgShadowY
            value: cfg_fgShadowY
            from: -99
            to: 99
            enabled: fgColorEnabled.checked && fgShadowEnabled.checked
            onValueModified: {
                cfg_fgShadowY = value
            }
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Custom badges")
        }

        CheckBox {
            Kirigami.FormData.label: i18n("Fix custom badges:")
            id: fixCustomBadgesCheckbox
            checked: cfg_fixCustomBadges
            onCheckedChanged: cfg_fixCustomBadges = checked
        }

        Label {
            text: i18n("Fix unreadable custom badges (e.g. counters) drawn by some widgets.")
            opacity: 0.7
            Layout.maximumWidth: 400
            wrapMode: Text.Wrap
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

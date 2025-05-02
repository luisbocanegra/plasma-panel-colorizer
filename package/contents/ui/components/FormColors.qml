import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
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
    // wether or not show these options
    property bool multiColor: true
    property bool supportsGradient: false
    property bool supportsImage: false
    property alias isEnabled: enabledCheckbox.checked

    signal updateConfigString(string configString, var config)

    function updateConfig() {
        configString = JSON.stringify(config, null, null);
        updateConfigString(configString, config);
    }

    twinFormLayouts: parentLayout
    Layout.fillWidth: true

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

    Kirigami.Separator {
        Kirigami.FormData.isSection: isSection
        Kirigami.FormData.label: sectionName || i18n("Color")
        Layout.fillWidth: true
    }

    CheckBox {
        id: enabledCheckbox

        Kirigami.FormData.label: i18n("Enable:")
        checked: config.enabled
        onCheckedChanged: {
            config.enabled = checked;
            updateConfig();
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

    CheckBox {
        id: animationCheckbox

        Kirigami.FormData.label: i18n("Animation:")
        checked: config.animation.enabled
        onCheckedChanged: {
            config.animation.enabled = checked;
            updateConfig();
            // ensure valid option is checked as single and accent are
            // disabled in animated mode
            if (checked && (config.sourceType <= 1 || config.sourceType >= 4))
                listColorRadio.checked = true;
        }
        enabled: isEnabled
        visible: false
    }

    SpinBox {
        id: animationInterval

        Kirigami.FormData.label: i18n("Interval (ms):")
        from: 0
        to: 30000
        stepSize: 100
        value: config.animation.interval
        onValueModified: {
            config.animation.interval = value;
            updateConfig();
        }
        enabled: animationCheckbox.checked && isEnabled
        visible: false
    }

    SpinBox {
        id: animationTransition

        Kirigami.FormData.label: i18n("Smoothing (ms):")
        from: 0
        to: animationInterval.value
        stepSize: 100
        value: config.animation.smoothing
        onValueModified: {
            config.animation.smoothing = value;
            updateConfig();
        }
        enabled: animationCheckbox.checked && isEnabled
        visible: false
    }

    RadioButton {
        id: singleColorRadio

        property int index: 0

        Kirigami.FormData.label: i18n("Source:")
        text: i18n("Custom")
        ButtonGroup.group: colorModeGroup
        checked: config.sourceType === index
        enabled: !animationCheckbox.checked && isEnabled
    }

    RadioButton {
        id: accentColorRadio

        property int index: 1

        text: i18n("System")
        ButtonGroup.group: colorModeGroup
        checked: config.sourceType === index
        enabled: !animationCheckbox.checked && isEnabled
    }

    RadioButton {
        id: listColorRadio

        property int index: 2

        text: i18n("Custom list")
        ButtonGroup.group: colorModeGroup
        checked: config.sourceType === index
        visible: multiColor
        enabled: isEnabled
    }

    RadioButton {
        id: randomColorRadio

        property int index: 3

        text: i18n("Random")
        ButtonGroup.group: colorModeGroup
        checked: config.sourceType === index
        enabled: isEnabled
    }

    RadioButton {
        id: followColorRadio

        property int index: 4

        text: i18n("Follow")
        ButtonGroup.group: colorModeGroup
        checked: config.sourceType === index
        enabled: !animationCheckbox.checked && isEnabled
        visible: showFollowRadio
    }

    RadioButton {
        id: gradientRadio
        property int index: 5
        text: i18n("Gradient")
        ButtonGroup.group: colorModeGroup
        checked: config.sourceType === index
        visible: root.supportsGradient
        enabled: isEnabled
    }

    RowLayout {
        visible: root.supportsImage
        enabled: isEnabled
        RadioButton {
            id: imageRadio
            property int index: 6
            text: i18n("Image")
            ButtonGroup.group: colorModeGroup
            checked: config.sourceType === index
        }
        Button {
            icon.name: "dialog-information-symbolic"
            ToolTip.text: i18n("High resolution images can slow down the desktop when the panel or widget size changes!")
            hoverEnabled: true
            flat: true
            ToolTip.visible: hovered
            Kirigami.Theme.inherit: false
            Kirigami.Theme.textColor: Kirigami.Theme.neutralTextColor
            Kirigami.Theme.highlightColor: Kirigami.Theme.neutralTextColor
            icon.color: Kirigami.Theme.neutralTextColor
        }
    }

    ButtonGroup {
        id: colorModeGroup

        onCheckedButtonChanged: {
            if (checkedButton) {
                config.sourceType = checkedButton.index;
                updateConfig();
            }
        }
    }
    // >

    RadioButton {
        id: followPanelBgRadio

        property int index: 0

        Kirigami.FormData.label: i18n("Element:")
        text: i18n("Panel background")
        ButtonGroup.group: followColorGroup
        checked: config.followColor === index
        visible: followColorRadio.checked && showFollowPanel
        enabled: isEnabled
    }

    RadioButton {
        id: followWidgetBgRadio

        property int index: 1

        text: i18n("Widget background")
        ButtonGroup.group: followColorGroup
        checked: config.followColor === index
        visible: followColorRadio.checked && showFollowWidget
        enabled: isEnabled
    }

    RadioButton {
        id: followTrayWidgetBgRadio

        property int index: 2

        text: i18n("Tray widget background")
        ButtonGroup.group: followColorGroup
        checked: config.followColor === index
        visible: followColorRadio.checked && showFollowTray
        enabled: isEnabled
    }

    ButtonGroup {
        id: followColorGroup

        onCheckedButtonChanged: {
            if (checkedButton) {
                config.followColor = checkedButton.index;
                updateConfig();
            }
        }
    }

    ComboBox {
        id: imageFillMode
        Kirigami.FormData.label: i18n("Positioning:")
        visible: root.supportsImage && imageRadio.checked
        model: [
            {
                'label': i18n("Stretch"),
                'fillMode': AnimatedImage.Stretch
            },
            {
                'label': i18n("Tile"),
                'fillMode': AnimatedImage.Tile
            },
            {
                'label': i18n("Scaled and Cropped"),
                'fillMode': AnimatedImage.PreserveAspectCrop
            }
        ]
        textRole: "label"
        valueRole: "fillMode"
        onActivated: {
            config.image.fillMode = currentValue;
            updateConfig();
        }
        currentIndex: indexOfValue(config.image.fillMode)
    }

    RowLayout {
        visible: root.supportsImage && imageRadio.checked
        TextField {
            id: imgTextArea
            Layout.preferredWidth: 300
            text: config.image.source
            onTextChanged: {
                if (config.image.source !== text) {
                    config.image.source = text;
                    updateConfig();
                }
            }
        }
        Button {
            icon.name: "insert-image-symbolic"
            onClicked: fileDialog.open()
        }
    }

    FileDialog {
        id: fileDialog
        fileMode: FileDialog.OpenFile
        title: i18n("Pick a image file")
        nameFilters: [i18n("Image files") + " (*.png *.jpg *.jpeg *.gif *.webp *.bmp *.svg)", i18n("All files") + " (*)"]
        onAccepted: {
            if (fileDialog.selectedFile) {
                console.log(fileDialog.selectedFile);
                imgTextArea.text = fileDialog.selectedFile;
            }
        }
    }

    ColorButton {
        id: customColorBtn

        showAlphaChannel: false
        // dialogTitle: i18n("Widget background")
        color: config.custom
        visible: singleColorRadio.checked
        onAccepted: color => {
            config.custom = color.toString();
            updateConfig();
        }
        enabled: isEnabled
    }

    ComboBox {
        id: colorSetCombobx

        Kirigami.FormData.label: i18n("Color set:")
        model: themeColorSetModel
        textRole: "displayName"
        visible: accentColorRadio.checked
        onCurrentIndexChanged: {
            config.systemColorSet = themeColorSetModel.get(currentIndex).value;
            updateConfig();
        }
        enabled: isEnabled

        Binding {
            target: colorSetCombobx
            property: "currentIndex"
            value: {
                for (var i = 0; i < themeColorSetModel.count; i++) {
                    if (themeColorSetModel.get(i).value === config.systemColorSet)
                        return i;
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
            config.systemColor = themeColorModel.get(currentIndex).value;
            updateConfig();
        }
        enabled: isEnabled

        Binding {
            target: colorThemeCombobx
            property: "currentIndex"
            value: {
                for (var i = 0; i < themeColorModel.count; i++) {
                    if (themeColorModel.get(i).value === config.systemColor)
                        return i;
                }
                return 0; // Default to the first item if no match is found
            }
        }
    }

    ColumnLayout {
        visible: multiColor && listColorRadio.checked
        enabled: isEnabled

        Loader {
            asynchronous: true
            sourceComponent: listColorRadio.checked ? pickerList : null
            onLoaded: {
                item.colorsList = config.list;
                item.onColorsChanged.connect(colorsList => {
                    config.list = colorsList;
                    updateConfig();
                });
            }
        }

        Component {
            id: pickerList

            ColorPickerList {}
        }
    }

    RadioButton {
        id: gradientHorizontalRadio
        Kirigami.FormData.label: i18n("Orientation:")
        property int index: 0
        text: i18n("Horizontal")
        ButtonGroup.group: gradientOrientationBtnGroup
        checked: config.gradient.orientation === index
        enabled: isEnabled
        visible: root.supportsGradient && gradientRadio.checked
    }

    RadioButton {
        id: gradientVerticalRadio
        property int index: 1
        text: i18n("Vertical")
        ButtonGroup.group: gradientOrientationBtnGroup
        checked: config.gradient.orientation === index
        enabled: isEnabled
        visible: root.supportsGradient && gradientRadio.checked
    }

    ButtonGroup {
        id: gradientOrientationBtnGroup

        onCheckedButtonChanged: {
            if (checkedButton) {
                config.gradient.orientation = checkedButton.index;
                updateConfig();
            }
        }
    }

    ColumnLayout {
        visible: root.supportsGradient && gradientRadio.checked
        enabled: isEnabled

        Loader {
            asynchronous: true
            sourceComponent: gradientRadio.checked ? pickerGradientList : null
            onLoaded: {
                item.stopsList = config.gradient.stops;
                item.onColorsChanged.connect(stopsList => {
                    config.gradient.stops = stopsList;
                    updateConfig();
                });
            }
        }

        Component {
            id: pickerGradientList

            ColorPickerGradientList {}
        }
    }

    RowLayout {
        enabled: isEnabled
        Kirigami.FormData.label: i18n("Alpha:")
        visible: colorModeGroup.checkedButton.index < 5

        SpinBoxDecimal {
            Layout.preferredWidth: root.Kirigami.Units.gridUnit * 5
            from: 0
            to: 1
            value: config.alpha ?? 0
            onValueChanged: {
                config.alpha = value;
                updateConfig();
            }
        }
    }

    Kirigami.Separator {
        Kirigami.FormData.isSection: false
        Kirigami.FormData.label: i18n("Contrast Correction")
        Layout.fillWidth: true
        visible: colorModeGroup.checkedButton.index < 5
    }

    RowLayout {
        enabled: isEnabled
        Kirigami.FormData.label: i18n("Saturation:")
        visible: colorModeGroup.checkedButton.index < 5

        CheckBox {
            id: saturationEnabled

            checked: config.saturationEnabled
            onCheckedChanged: {
                config.saturationEnabled = checked;
                updateConfig();
            }
        }

        SpinBoxDecimal {
            Layout.preferredWidth: root.Kirigami.Units.gridUnit * 5
            from: 0
            to: 1
            value: config.saturationValue ?? 0
            onValueChanged: {
                config.saturationValue = value;
                updateConfig();
            }
        }
    }

    RowLayout {
        enabled: isEnabled
        Kirigami.FormData.label: i18n("Lightness:")
        visible: colorModeGroup.checkedButton.index < 5

        CheckBox {
            id: lightnessEnabled

            checked: config.lightnessEnabled
            onCheckedChanged: {
                config.lightnessEnabled = checked;
                updateConfig();
            }
        }

        SpinBoxDecimal {
            Layout.preferredWidth: root.Kirigami.Units.gridUnit * 5
            from: 0
            to: 1
            value: config.lightnessValue ?? 0
            onValueChanged: {
                config.lightnessValue = value;
                updateConfig();
            }
        }
    }
}

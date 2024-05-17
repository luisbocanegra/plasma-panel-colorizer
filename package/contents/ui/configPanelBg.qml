import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import "components" as Components

KCM.SimpleKCM {
    id:root
    property bool cfg_panelBgEnabled: panelBgEnabled.checked
    property int cfg_panelBgColorMode: plasmoid.configuration.panelBgColorMode
    property alias cfg_panelBgColorModeTheme: colorModeTheme.currentIndex
    property alias cfg_panelBgColorModeThemeVariant: colorModeThemeVariant.currentIndex
    property string cfg_panelBgColor: panelBgColor.color
    property bool cfg_hideRealPanelBg: hideRealPanelBg.checked
    property real cfg_panelBgOpacity: parseFloat(panelBgOpacity.text)
    property int cfg_panelBgRadius: panelBgRadius.value
    property real cfg_panelRealBgOpacity: parseFloat(panelRealBgOpacity.text)
    property bool cfg_enableCustomPadding: enableCustomPadding.checked
    property int cfg_panelPadding: panelPadding.value

    property int cfg_panelOutlineColorMode: plasmoid.configuration.panelOutlineColorMode
    property alias cfg_panelOutlineColorModeTheme: panelOutlineColorModeTheme.currentIndex
    property alias cfg_panelOutlineColorModeThemeVariant: panelOutlineColorModeThemeVariant.currentIndex
    property string cfg_panelOutlineColor: panelOutlineColor.color
    property int cfg_panelOutlineWidth: panelOutlineWidth.value
    property real cfg_panelOutlineOpacity: panelOutlineOpacity.text
    property int cfg_panelShadowSize: panelShadowSize.value
    property string cfg_panelShadowColor: panelShadowColor.color
    property int cfg_panelShadowX: panelShadowColorX.value
    property int cfg_panelShadowY: panelShadowColorY.value

    header: RowLayout {
        RowLayout {
            Layout.leftMargin: Kirigami.Units.mediumSpacing
            Layout.rightMargin: Kirigami.Units.smallSpacing
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

    Kirigami.FormLayout {

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Original background")
        }

        CheckBox {
            Kirigami.FormData.label: i18n("Hide:")
            id: hideRealPanelBg
            checked: cfg_hideRealPanelBg
            onCheckedChanged: cfg_hideRealPanelBg = checked
        }
        RowLayout {
            Kirigami.FormData.label: i18n("Opacity:")
            TextField {
                id: panelRealBgOpacity
                placeholderText: "0-1"
                text: parseFloat(cfg_panelRealBgOpacity).toFixed(validator.decimals)
                enabled: !hideRealPanelBg.checked
                Layout.preferredWidth: Kirigami.Units.gridUnit * 4

                validator: DoubleValidator {
                    bottom: 0.0
                    top: 1.0
                    decimals: 2
                    notation: DoubleValidator.StandardNotation
                }

                onTextChanged: {
                    const newVal = parseFloat(text)
                    cfg_panelRealBgOpacity = isNaN(newVal) ? 0 : newVal
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
                    value: cfg_panelRealBgOpacity
                    onValueChanged: {
                        cfg_panelRealBgOpacity = parseFloat(value)
                    }
                }
            }
        }

        Label {
            text: i18n("Hiding the background also removes the contrast and blur. Changing just the opacity does not.")
            opacity: 0.7
            Layout.maximumWidth: 400
            wrapMode: Text.Wrap
        }

        CheckBox {
            Kirigami.FormData.label: i18n("Fixed side padding:")
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
            text: i18n("This option makes the widgets always stay at the same distance from the sides of the floating panel. Changing panel settings with this option enabled may cause some jankiness, specially in edit mode and vertical panels. Disable and restart Plasma or logout to restore the original behavior.")
            opacity: 0.7
            Layout.maximumWidth: 400
            wrapMode: Text.Wrap
        }


        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Custom background")
        }

        CheckBox {
            Kirigami.FormData.label: i18n("Enabled:")
            id: panelBgEnabled
            checked: cfg_panelBgEnabled
            onCheckedChanged: cfg_panelBgEnabled = checked
        }

        RadioButton {
            Kirigami.FormData.label: i18n("Color source:")
            text: i18n("Custom")
            id: singleColorRadio
            ButtonGroup.group: colorModeGroup
            property int index: 0
            checked: plasmoid.configuration.panelBgColorMode === index
            enabled: panelBgEnabled.checked
        }
        RadioButton {
            text: i18n("System")
            id: accentColorRadio
            ButtonGroup.group: colorModeGroup
            property int index: 1
            checked: plasmoid.configuration.panelBgColorMode === index
            enabled: panelBgEnabled.checked
        }

        ButtonGroup {
            id: colorModeGroup
            onCheckedButtonChanged: {
                if (checkedButton) {
                    cfg_panelBgColorMode = checkedButton.index
                }
            }
        }

        Components.ColorButton {
            id: panelBgColor
            showAlphaChannel: false
            dialogTitle: i18n("Panel background")
            // Kirigami.FormData.label: i18n("Color:")
            color: cfg_panelBgColor
            visible: singleColorRadio.checked
            onAccepted: {
                cfg_panelBgColor = color
            }
            enabled: panelBgEnabled.checked
        }

        ComboBox {
            id: colorModeTheme
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
            enabled: panelBgEnabled.checked
        }

        ComboBox {
            id: colorModeThemeVariant
            Kirigami.FormData.label: i18n("Color set:")
            model: [i18n("View"), i18n("Window"), i18n("Button"), i18n("Selection"), i18n("Tooltip"), i18n("Complementary"), i18n("Header")]
            visible: accentColorRadio.checked
            enabled: panelBgEnabled.checked
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Opacity:")
            TextField {
                id: panelBgOpacity
                placeholderText: "0-1"
                text: parseFloat(cfg_panelBgOpacity).toFixed(validator.decimals)
                enabled: panelBgEnabled.checked
                Layout.preferredWidth: Kirigami.Units.gridUnit * 4

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
                    stepSize: 0.05
                    value: cfg_panelBgOpacity
                    onValueChanged: {
                        cfg_panelBgOpacity = parseFloat(value)
                    }
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

        Kirigami.Separator {
            Kirigami.FormData.isSection: false
            Kirigami.FormData.label: i18n("Outline")
            Layout.fillWidth: true
        }

        RadioButton {
            Kirigami.FormData.label: i18n("Color source:")
            text: i18n("Custom")
            id: singleOutlineColorRadio
            ButtonGroup.group: outlineColorModeGroup
            property int index: 0
            checked: plasmoid.configuration.panelOutlineColorMode === index
            enabled: panelBgEnabled.checked
        }
        RadioButton {
            text: i18n("System")
            id: accentOutlineColorRadio
            ButtonGroup.group: outlineColorModeGroup
            property int index: 1
            checked: plasmoid.configuration.panelOutlineColorMode === index
            enabled: panelBgEnabled.checked
        }

        ButtonGroup {
            id: outlineColorModeGroup
            onCheckedButtonChanged: {
                if (checkedButton) {
                    cfg_panelOutlineColorMode = checkedButton.index
                }
            }
        }

        Components.ColorButton {
            id: panelOutlineColor
            showAlphaChannel: false
            dialogTitle: i18n("Panel outline")
            color: cfg_panelOutlineColor
            visible: singleOutlineColorRadio.checked
            onAccepted: {
                console.error(color);
                cfg_panelOutlineColor = color
            }
            enabled: panelBgEnabled.checked
        }

        ComboBox {
            id: panelOutlineColorModeTheme
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
            visible: accentOutlineColorRadio.checked
            enabled: panelBgEnabled.checked
        }

        ComboBox {
            id: panelOutlineColorModeThemeVariant
            Kirigami.FormData.label: i18n("Color set:")
            model: [i18n("View"), i18n("Window"), i18n("Button"), i18n("Selection"), i18n("Tooltip"), i18n("Complementary"), i18n("Header")]
            visible: accentOutlineColorRadio.checked
            enabled: panelBgEnabled.checked
        }


        RowLayout {
            Kirigami.FormData.label: i18n("Opacity:")
            TextField {
                id: panelOutlineOpacity
                placeholderText: "0-1"
                text: parseFloat(cfg_panelOutlineOpacity).toFixed(validator.decimals)
                enabled: panelBgEnabled.checked
                Layout.preferredWidth: Kirigami.Units.gridUnit * 4

                validator: DoubleValidator {
                    bottom: 0.0
                    top: 1.0
                    decimals: 2
                    notation: DoubleValidator.StandardNotation
                }

                onTextChanged: {
                    const newVal = parseFloat(text)
                    cfg_panelOutlineOpacity = isNaN(newVal) ? 0 : newVal
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
                    value: cfg_panelOutlineOpacity
                    onValueChanged: {
                        cfg_panelOutlineOpacity = parseFloat(value)
                    }
                }
            }
        }

        SpinBox {
            Kirigami.FormData.label: i18n("Width:")
            id: panelOutlineWidth
            value: cfg_panelOutlineWidth
            from: 0
            to: 99
            enabled: panelBgEnabled.checked
            onValueModified: {
                cfg_panelOutlineWidth = value
            }
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: false
            Kirigami.FormData.label: i18n("Shadow")
            Layout.fillWidth: true
        }

        Components.ColorButton {
            id: panelShadowColor
            Kirigami.FormData.label: i18n("Color:")
            showAlphaChannel: true
            dialogTitle: i18n("Panel shadow")
            color: cfg_panelShadowColor
            enabled: panelBgEnabled.checked
            onAccepted: {
                cfg_panelShadowColor = color
            }
        }

        SpinBox {
            Kirigami.FormData.label: i18n("Size:")
            id: panelShadowSize
            value: cfg_panelShadowSize
            from: 0
            to: 99
            enabled: panelBgEnabled.checked
            onValueModified: {
                cfg_panelShadowSize = value
            }
        }

        SpinBox {
            Kirigami.FormData.label: i18n("X offset:")
            id: panelShadowX
            value: cfg_panelShadowX
            from: -99
            to: 99
            enabled: panelBgEnabled.checked
            onValueModified: {
                cfg_panelShadowX = value
            }
        }

        SpinBox {
            Kirigami.FormData.label: i18n("Y offset:")
            id: panelShadowY
            value: cfg_panelShadowY
            from: -99
            to: 99
            enabled: panelBgEnabled.checked
            onValueModified: {
                cfg_panelShadowY = value
            }
        }
    }
}

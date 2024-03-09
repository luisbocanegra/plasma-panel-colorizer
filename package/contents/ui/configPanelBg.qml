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
    property string cfg_panelBgColor: panelBgColor.color
    property bool cfg_hideRealPanelBg: hideRealPanelBg.checked
    property real cfg_panelBgOpacity: parseFloat(panelBgOpacity.text)
    property int cfg_panelBgRadius: panelBgRadius.value
    property real cfg_panelRealBgOpacity: parseFloat(panelRealBgOpacity.text)
    property bool cfg_enableCustomPadding: enableCustomPadding.checked
    property int cfg_panelPadding: panelPadding.value

    property string cfg_panelOutlineColor: panelOutlineColor.color
    property int cfg_panelOutlineWidth: panelOutlineWidth.value
    property int cfg_panelShadowSize: panelShadowSize.value
    property string cfg_panelShadowColor: panelShadowColor.color
    property int cfg_panelShadowX: panelShadowColorX.value
    property int cfg_panelShadowY: panelShadowColorY.value

    Kirigami.FormLayout {

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Original background")
        }

        CheckBox {
            Kirigami.FormData.label: i18n("Hide")
            id: hideRealPanelBg
            checked: cfg_hideRealPanelBg
            onCheckedChanged: cfg_hideRealPanelBg = checked
        }
        RowLayout {
            TextField {
                id: panelRealBgOpacity
                Kirigami.FormData.label: i18n("Opacity:")
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
            text: i18n("Hiding the background also removes the contrast and blur, just changing the opacity does not.")
            opacity: 0.7
            Layout.maximumWidth: 400
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
            text: i18n("This option makes the widgets always stay at the same distance from the sides of the panel. Changing panel settings with this option enabled may cause some jankiness, specially in edit mode and vertical panels. Disable and restart Plasma or logout to restore the original behavior.")
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

        Components.ColorButton {
            id: panelBgColor
            showAlphaChannel: false
            dialogTitle: i18n("Panel background")
            Kirigami.FormData.label: i18n("Color:")
            color: cfg_panelBgColor
            enabled: panelBgEnabled.checked
            onAccepted: {
                cfg_panelBgColor = color
            }
        }
        RowLayout {
            TextField {
                id: panelBgOpacity
                Kirigami.FormData.label: i18n("Opacity:")
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

        Components.ColorButton {
            id: panelOutlineColor
            Kirigami.FormData.label: i18n("Color:")
            showAlphaChannel: true
            dialogTitle: i18n("Panel outline")
            color: cfg_panelOutlineColor
            enabled: panelBgEnabled.checked
            onAccepted: {
                cfg_panelOutlineColor = color
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

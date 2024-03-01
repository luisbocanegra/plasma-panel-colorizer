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
    property real cfg_panelBgOpacity: parseFloat(panelBgOpacity.text)
    property int cfg_panelBgRadius: panelBgRadius.value
    property real cfg_panelRealBgOpacity: parseFloat(panelRealBgOpacity.text)
    property int cfg_enableCustomPadding: enableCustomPadding.value
    property int cfg_panelPadding: panelPadding.value

    Kirigami.FormLayout {

        CheckBox {
            Kirigami.FormData.label: i18n("Custom background:")
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
                stepSize: 0.05
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

        TextField {
            id: panelRealBgOpacity
            Kirigami.FormData.label: i18n("Real background opacity:")
            placeholderText: "0-1"
            horizontalAlignment: TextInput.AlignHCenter
            text: parseFloat(cfg_panelRealBgOpacity).toFixed(validator.decimals)
            enabled: panelBgEnabled.checked

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

        Label {
            text: i18n("Note: Even when the real panel background is fully transparent, contrast and blur will still be drawn behind the panel")
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
            text: i18n("This option makes the widgets always stay at the same distance from borders in floating mode. Changing panel visibility settings with this option enabled may cause some jankiness, specially in edit mode. Disable and restart Plasma or logout to restore the original behavior.")
            opacity: 0.7
            Layout.maximumWidth: 300
            wrapMode: Text.Wrap
        }
    }
}

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
    property string cfg_customFgColor: customFgColor.color
    property real cfg_fgOpacity: parseFloat(fgOpacity.text)
    property string cfg_forceRecolor: forceRecolor.text

    property bool cfg_fgBlacklistedColorEnabled: fgBlacklistedColorEnabled.checked
    property string cfg_blacklistedFgColor: blacklistedFgColor.text

    Kirigami.FormLayout {

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

        CheckBox {
            Kirigami.FormData.label: i18n("Custom color:")
            id: fgColorEnabled
            checked: cfg_fgColorEnabled
            onCheckedChanged: cfg_fgColorEnabled = checked
        }

        Components.ColorButton {
            id: customFgColor
            showAlphaChannel: false
            dialogTitle: i18n("Text/icons")
            color: cfg_customFgColor
            enabled: fgColorEnabled.checked
            onAccepted: {
                cfg_customFgColor = color
            }
        }

        CheckBox {
            Kirigami.FormData.label: i18n("Custom blacklisted color:")
            id: fgBlacklistedColorEnabled
            checked: cfg_fgBlacklistedColorEnabled 
            onCheckedChanged: cfg_fgBlacklistedColorEnabled = checked
        }

        Components.ColorButton {
            id: blacklistedFgColor
            showAlphaChannel: false
            dialogTitle: i18n("Blacklisted text/icons")
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

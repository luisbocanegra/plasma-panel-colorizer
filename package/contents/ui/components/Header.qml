import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami

RowLayout {
    property alias isEnabled: isEnabledCheckbox.checked
    RowLayout {
        Layout.alignment: Qt.AlignRight
        Label {
            text: i18n("Enable:")
        }
        CheckBox {
            id: isEnabledCheckbox
            Binding {
                target: isEnabledCheckbox
                property: "Kirigami.Theme.textColor"
                value: Kirigami.Theme.neutralTextColor
                when: !isEnabledCheckbox.checked
            }
            Kirigami.Theme.inherit: false
            text: checked ? "" : i18n("Disabled")
        }
    }
    Item {
        Layout.fillWidth: true
    }
    RowLayout {
        Layout.alignment: Qt.AlignRight
        Layout.rightMargin: Kirigami.Units.gridUnit
        Label {
            text: i18n("Last preset loaded:")
        }
        Label {
            text: plasmoid.configuration.lastPreset || "None"
            font.weight: Font.DemiBold
        }
    }
}

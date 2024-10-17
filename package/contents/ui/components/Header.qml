import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami

RowLayout {
    id: root
    property alias isEnabled: isEnabledCheckbox.checked
    property string lastPresetDir: plasmoid.configuration.lastPreset
    property string lastPresetName: {
        let name = lastPresetDir.split("/")
        return name[name.length-1] || "None"
    }

    RowLayout {
        Layout.alignment: Qt.AlignRight
        Label {
            text: i18n("Enable Panel Colorizer:")
        }
        CheckBox {
            id: isEnabledCheckbox
            Binding {
                target: isEnabledCheckbox
                property: "Kirigami.Theme.textColor"
                value: root.Kirigami.Theme.neutralTextColor
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
            text: lastPresetName
            font.weight: Font.DemiBold
        }
    }
}

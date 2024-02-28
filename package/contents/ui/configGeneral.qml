import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid

KCM.SimpleKCM {
    id:root
    property bool cfg_isEnabled: isEnabled.checked
    property bool cfg_hideWidget: hideWidget.checked

    Kirigami.FormLayout {

        CheckBox {
            Kirigami.FormData.label: i18n("Enabled:")
            id: isEnabled
            checked: cfg_isEnabled
            onCheckedChanged: cfg_isEnabled = checked
        }

        CheckBox {
            Kirigami.FormData.label: i18n("Hide widget:")
            id: hideWidget
            checked: cfg_hideWidget
            onCheckedChanged: cfg_hideWidget = checked
        }

        Label {
            text: i18n("Widget will show in panel Edit Mode")
            opacity: 0.7
            Layout.maximumWidth: 300
            wrapMode: Text.Wrap
        }
    }
}

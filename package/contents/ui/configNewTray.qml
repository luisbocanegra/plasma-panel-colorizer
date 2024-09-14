import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import org.kde.plasma.plasma5support as P5Support
import "components" as Components

KCM.SimpleKCM {
    id:root
    property alias cfg_trayWidgetSettings: backgroundComp.configString

    ColumnLayout {
        Kirigami.FormLayout {
            id: parentLayout
            Layout.fillWidth: true
            CheckBox {
                Kirigami.FormData.label: i18n("Dummy:")
                text: "(parent form)"
            }
        }
        Components.Background {
            id: backgroundComp
            onUpdateConfigString: (newString, config) => {
                cfg_trayWidgetSettings = newString
            }
        }
    }
}

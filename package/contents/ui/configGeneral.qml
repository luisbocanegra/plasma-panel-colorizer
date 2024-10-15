import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import org.kde.plasma.plasma5support as P5Support

import "components" as Components
import "code/utils.js" as Utils
import "code/globals.js" as Globals

KCM.SimpleKCM {
    id:root
    property bool cfg_hideWidget: hideWidget.checked
    property alias cfg_isEnabled: headerComponent.isEnabled
    property alias cfg_enableDebug: enableDebug.checked

    header: ColumnLayout {
        Components.Header {
            id: headerComponent
            Layout.leftMargin: Kirigami.Units.mediumSpacing
            Layout.rightMargin: Kirigami.Units.mediumSpacing
        }
    }

    ColumnLayout {
        Kirigami.FormLayout {
            CheckBox {
                Kirigami.FormData.label: i18n("Hide widget:")
                id: hideWidget
                checked: cfg_hideWidget
                onCheckedChanged: cfg_hideWidget = checked
                text: i18n("visible in Panel Edit Mode")
            }
            CheckBox {
                Kirigami.FormData.label: i18n("Debug mode:")
                id: enableDebug
                checked: cfg_enableDebug
                onCheckedChanged: cfg_enableDebug = checked
                text: i18n("Show debugging information")
            }
        }
    }
}

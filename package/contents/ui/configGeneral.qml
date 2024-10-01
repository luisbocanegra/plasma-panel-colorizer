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

    header: ColumnLayout {
        Components.Header {
            id: headerComponent
            Layout.leftMargin: Kirigami.Units.mediumSpacing
            Layout.rightMargin: Kirigami.Units.mediumSpacing
        }
    }

    ColumnLayout {
        Kirigami.FormLayout {
            RowLayout {
                Kirigami.FormData.label: i18n("Hide widget:")
                Kirigami.FormData.labelAlignment: Qt.AlignTop
                RowLayout {
                CheckBox {
                    Layout.alignment: Qt.AlignTop
                    id: hideWidget
                    checked: cfg_hideWidget
                    onCheckedChanged: cfg_hideWidget = checked
                }
                Label {
                    Layout.alignment: Qt.AlignTop
                    text: i18n("Widget will show when configuring or panel Edit Mode")
                    opacity: 0.7
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: 300
                }
                }
            }
        }
    }
}

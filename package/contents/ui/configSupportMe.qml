import QtQuick
import QtQuick.Layouts
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami
import "components" as Components

KCM.SimpleKCM {
    id: root

    ColumnLayout {
        Components.SupportMe {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: Kirigami.Units.gridUnit
        }
    }
}

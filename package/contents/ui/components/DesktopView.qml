import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

Item {
    property var main
    Layout.minimumWidth: Kirigami.Units.gridUnit * 10
    Layout.minimumHeight: Kirigami.Units.gridUnit * 10
    Layout.maximumWidth: Kirigami.Units.gridUnit * 10
    Layout.maximumHeight: Kirigami.Units.gridUnit * 10

    ColumnLayout {
        id: column
        anchors.fill: parent
        Kirigami.Icon {
            Layout.fillWidth: true
            Layout.preferredHeight: 64
            source: main.icon
            isMask: true
            color: Kirigami.Theme.negativeTextColor
        }
        PlasmaComponents.Label {
            text: "<font color='" + Kirigami.Theme.neutralTextColor + "'>" + i18n("Panel not found, this widget must be placed on a panel to work") + "</font>"
            Layout.fillWidth: true
            wrapMode: Text.Wrap
        }
    }
}

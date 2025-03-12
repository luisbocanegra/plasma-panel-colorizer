import QtQuick
import "components" as Components
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore

MouseArea {
    id: compact

    property bool isPanelVertical: plasmoid.formFactor === PlasmaCore.Types.Vertical
    property real itemSize: Math.min(compact.height, compact.width)
    property string icon

    signal widgetClicked

    anchors.fill: parent
    hoverEnabled: true
    onClicked: {
        widgetClicked();
    }

    Item {
        id: container

        height: compact.itemSize
        width: compact.width
        anchors.centerIn: parent

        Components.PlasmoidIcon {
            id: plasmoidIcon

            height: Kirigami.Units.iconSizes.roundedIconSize(Math.min(parent.width, parent.height))
            width: height
            source: icon
        }
    }
}

import QtQuick 2.5
import QtQuick.Layouts 1.1
import org.kde.kirigami 2.10 as Kirigami
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0
import "components" as Components

MouseArea {
    id: compact
    anchors.fill: parent
    property bool isPanelVertical: plasmoid.formFactor === PlasmaCore.Types.Vertical
    property real itemSize: Math.min(compact.height, compact.width)

    property string icon
    property bool onDesktop
    property bool isEnabled: main.enabled
    hoverEnabled: true
    onClicked: {
        main.enabled = !main.enabled
        console.log("AAAAA");
    }


    Item {
        id: container
        height: compact.itemSize
        width: compact.width
        anchors.centerIn: parent

        Components.PlasmoidIcon {
            id: plasmoidIcon
            height: PlasmaCore.Units.roundToIconSize(Math.min(parent.width, parent.height))
            width: height
            source: icon
        }
    }

}

import QtQuick 2.5
import org.kde.kirigami 2.10 as Kirigami
import org.kde.plasma.core 2.0 as PlasmaCore
import QtQuick.Controls 2.15
import "."

Item {
    id: root
    anchors.centerIn: parent
    property var source
    anchors.fill: parent

    PlasmaCore.SvgItem {
        id: svgItem
        width: Math.min(parent.height, parent.width)
        height: width
        property int sourceIndex: 0
        anchors.centerIn: parent
        smooth: true
        opacity: compact.isEnabled ? 1 : 0.5
        svg: PlasmaCore.Svg {
            id: svg
            colorGroup: PlasmaCore.ColorScope.colorGroup
            imagePath: source
        }
    }
    Label {
        text:"1"
    }
}

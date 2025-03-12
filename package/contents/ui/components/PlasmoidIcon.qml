import "."
import QtQuick
import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg

Item {
    id: root

    property var source

    anchors.centerIn: parent
    anchors.fill: parent

    Kirigami.Icon {
        anchors.centerIn: parent
        width: Math.min(parent.height, parent.width)
        height: width
        source: root.source
        active: compact.containsMouse
        isMask: true
        color: compact.onDesktop ? Kirigami.Theme.negativeTextColor : Kirigami.Theme.textColor
        opacity: plasmoid.configuration.isEnabled ? 1 : 0.5
    }
}

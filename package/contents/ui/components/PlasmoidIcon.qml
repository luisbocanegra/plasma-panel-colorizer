import QtQuick
import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg
import "."

Item {
    id: root
    anchors.centerIn: parent
    property var source
    anchors.fill: parent

    Kirigami.Icon {
        anchors.centerIn: parent
        width: Math.min(parent.height, parent.width)
        height: width
        source: root.source
        active: compact.containsMouse
        isMask: true
        color: compact.onDesktop ? Kirigami.Theme.negativeTextColor : Kirigami.Theme.textColor
        opacity: compact.isEnabled ? 1 : 0.5
    }
}

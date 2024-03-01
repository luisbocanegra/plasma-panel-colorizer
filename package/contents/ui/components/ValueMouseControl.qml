import QtQuick
import QtQuick.Controls
import org.kde.kirigami as Kirigami

Item {
    id: root
    property real from: 0
    property real to: 1
    property int decimals: 2
    property real stepSize: 0.1
    property real value: 0

    Rectangle {
        anchors.fill: parent
        Kirigami.Theme.colorSet: Kirigami.Theme.Button
        Kirigami.Theme.inherit: false
        color: Kirigami.Theme.backgroundColor
        opacity: 1
        radius: 2
    }

    Kirigami.Icon {
        source: "arrow-up"
        height: parent.height / 2
        width: height
        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Kirigami.Icon {
        source: "arrow-down"
        height: parent.height / 2
        width: height
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.horizontalCenter: parent.horizontalCenter
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.SizeVerCursor
        hoverEnabled: false
        onEntered: {}
        onExited: {}
        onWheel: {
            if(wheel.angleDelta.y > 0 && value < to) {
                value += stepSize
            } else if (wheel.angleDelta.y < 0 && value > from) {
                value -= stepSize
            }
            value = Math.max(0, Math.min(1, value)).toFixed(decimals)
        }
        onClicked: {
            root.parent.forceActiveFocus()
        }
    }
}

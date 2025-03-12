import QtQuick
import org.kde.kirigami as Kirigami

Item {
    id: root

    property real from: 0
    property real to: 1
    property int decimals: 2
    property real stepSize: 0.1
    property real value: 0

    function up() {
        if (value < to)
            value += stepSize;

        value = Math.max(from, Math.min(to, value)).toFixed(decimals);
    }

    function down() {
        if (value > from)
            value -= stepSize;

        value = Math.max(from, Math.min(to, value)).toFixed(decimals);
    }

    Rectangle {
        anchors.fill: parent
        Kirigami.Theme.colorSet: root.Kirigami.Theme.Button
        Kirigami.Theme.inherit: false
        color: Kirigami.Theme.backgroundColor
        opacity: 1
        radius: 2
    }

    Kirigami.Icon {
        source: "arrow-up"
        height: parent.height / 2
        width: parent.width
        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.horizontalCenter: parent.horizontalCenter
        color: upMouse.containsMouse ? Kirigami.Theme.highlightColor : Kirigami.Theme.textColor

        MouseArea {
            id: upMouse

            anchors.fill: parent
            hoverEnabled: true
            onPressed: {
                timerUp.start();
            }
            onReleased: {
                timerUp.stop();
            }
        }

        Timer {
            id: timerUp

            interval: 150
            repeat: true
            triggeredOnStart: true
            running: false
            onTriggered: {
                up();
            }
        }
    }

    Kirigami.Icon {
        source: "arrow-down"
        height: parent.height / 2
        width: parent.width
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.horizontalCenter: parent.horizontalCenter
        color: downMouse.containsMouse ? Kirigami.Theme.highlightColor : Kirigami.Theme.textColor

        MouseArea {
            id: downMouse

            anchors.fill: parent
            hoverEnabled: true
            onPressed: {
                timerDown.start();
            }
            onReleased: {
                timerDown.stop();
            }
        }

        Timer {
            id: timerDown

            interval: 150
            repeat: true
            triggeredOnStart: true
            running: false
            onTriggered: {
                down();
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        propagateComposedEvents: true
        acceptedButtons: Qt.MiddleButton
        onWheel: wheel => {
            root.parent.forceActiveFocus();
            if (wheel.angleDelta.y > 0 && value < to)
                value += stepSize;
            else if (wheel.angleDelta.y < 0 && value > from)
                value -= stepSize;
            value = Math.max(from, Math.min(to, value)).toFixed(decimals);
        }
    }
}

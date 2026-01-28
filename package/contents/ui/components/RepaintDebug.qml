import QtQuick

Rectangle {
    // quickly flash a small rectangle for items that have been updated
    id: speedDebugItem
    color: "cyan"
    height: 4
    width: 4
    anchors.top: parent.top
    anchors.left: parent.left
    Timer {
        id: deleteThisTimer
        interval: 100
        onTriggered: {
            speedDebugItem.destroy();
        }
    }
    Component.onCompleted: {
        deleteThisTimer.start();
    }
}

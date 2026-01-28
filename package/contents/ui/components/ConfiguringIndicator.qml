pragma ComponentBehavior: Bound
import QtQuick 2.15
import org.kde.kirigami as Kirigami

Item {
    id: root
    anchors.fill: parent
    Rectangle {
        anchors.centerIn: parent
        color: "#7f000000"
        height: Math.min(parent.height, parent.width) * 0.75
        width: height
        radius: height / 2

        Kirigami.Icon {
            anchors.centerIn: parent
            source: "configure"
            width: Math.min(parent.height, parent.width)
            height: width
            smooth: true
            color: "#fafafa"
            roundToIconSize: false
            isMask: true
            NumberAnimation on rotation {
                from: 0
                to: 360
                running: true
                loops: Animation.Infinite
                duration: 3000
            }
        }
    }

    Component.onCompleted: console.log("grid created in", root.parent)
}

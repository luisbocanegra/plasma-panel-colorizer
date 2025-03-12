pragma ComponentBehavior: Bound
import QtQuick 2.15

Item {
    id: root
    anchors.fill: parent
    property color backgroundColor: "#dd00ffff"
    property real backgroundOpacity: 0.8
    property int spacing: 4
    property color minorLineColor: "black"
    property real minorLineOpacity: .3
    property color majorLineColor: "black"
    property real majorLineOpacity: .6
    property int majorLineEvery: 2
    property int verticalCount: root.width / spacing
    property int horizontalCount: root.height / spacing

    Rectangle {
        anchors.fill: parent
        color: root.backgroundColor
        opacity: root.backgroundOpacity
    }

    // Vertical lines
    Repeater {
        model: root.verticalCount
        Rectangle {
            width: 1
            height: root.height
            color: isMajor ? root.majorLineColor : root.minorLineColor
            opacity: isMajor ? root.majorLineOpacity : root.minorLineOpacity
            required property int index
            property bool isMajor: index !== 0 && (index % root.majorLineEvery === 0)
            x: index * (root.width / (root.verticalCount))
        }
    }
    // Horizontal lines
    Repeater {
        model: root.horizontalCount
        Rectangle {
            width: root.width
            height: 1
            color: isMajor ? root.majorLineColor : root.minorLineColor
            opacity: isMajor ? root.majorLineOpacity : root.minorLineOpacity
            required property int index
            property bool isMajor: index !== 0 && (index % root.majorLineEvery === 0)
            y: index * (root.height / (root.horizontalCount))
        }
    }

    Component.onCompleted: console.log("grid created in", root.parent)
}

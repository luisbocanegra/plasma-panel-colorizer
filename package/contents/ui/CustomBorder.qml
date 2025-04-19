pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Effects
import org.kde.kirigami as Kirigami

Rectangle {
    id: root
    anchors.fill: parent
    color: "transparent"
    property var cfgBorder
    Kirigami.Theme.colorSet: Kirigami.Theme[cfgBorder.color.systemColorSet]
    property color borderColor
    property var corners: {
        "topLeftRadius": 0,
        "topRightRadius": 0,
        "bottomLeftRadius": 0,
        "bottomRightRadius": 0
    }
    property bool horizontal: false
    property int unifyBgType: 0

    Rectangle {
        id: customBorderTop
        width: parent.width
        visible: root.cfgBorder.customSides && root.cfgBorder.custom.widths.top
        height: root.cfgBorder.custom.widths.top
        color: root.borderColor
        anchors.top: parent.top
        antialiasing: true
    }
    Rectangle {
        id: customBorderBottom
        width: parent.width
        visible: root.cfgBorder.customSides && root.cfgBorder.custom.widths.bottom
        height: root.cfgBorder.custom.widths.bottom
        color: root.borderColor
        anchors.bottom: parent.bottom
        antialiasing: true
    }

    Rectangle {
        id: customBorderLeft
        height: parent.height
        visible: root.cfgBorder.customSides && root.cfgBorder.custom.widths.left
        width: root.cfgBorder.custom.widths.left
        color: root.borderColor
        anchors.left: parent.left
        antialiasing: true
    }
    Rectangle {
        id: customBorderRight
        height: parent.height
        visible: root.cfgBorder.customSides && root.cfgBorder.custom.widths.right
        width: root.cfgBorder.custom.widths.right
        color: root.borderColor
        anchors.right: parent.right
        antialiasing: true
    }

    Kirigami.ShadowedRectangle {
        id: normalBorder
        anchors.fill: parent
        color: "transparent"
        // the mask source needs to be hidden by default
        visible: false
        border {
            color: root.borderColor
            width: !root.cfgBorder.customSides ? root.cfgBorder.width || -1 : 0
        }
        corners {
            topLeftRadius: root.corners.topLeftRadius
            topRightRadius: root.corners.topRightRadius
            bottomLeftRadius: root.corners.bottomLeftRadius
            bottomRightRadius: root.corners.bottomRightRadius
        }
    }

    // Mask to hide one or two borders for unified backgrounds
    MultiEffect {
        source: normalBorder
        anchors.fill: normalBorder
        maskEnabled: true
        maskSource: unifiedBorderMask
        maskInverted: true
    }
    Item {
        id: unifiedBorderMask
        layer.enabled: true
        visible: false
        width: root.width
        height: root.height
        Rectangle {
            id: rect1
            width: root.horizontal ? root.cfgBorder.width : root.width - (root.cfgBorder.width * 2)
            height: root.horizontal ? root.height - (root.cfgBorder.width * 2) : root.cfgBorder.width
            color: (root.unifyBgType === 1 || root.unifyBgType === 2) ? "black" : "transparent"
            anchors.right: root.horizontal ? parent.right : undefined
            anchors.bottom: !root.horizontal ? parent.bottom : undefined
            anchors.verticalCenter: root.horizontal ? parent.verticalCenter : undefined
            anchors.horizontalCenter: !root.horizontal ? parent.horizontalCenter : undefined
            antialiasing: true
        }
        Rectangle {
            id: rect2
            width: root.horizontal ? root.cfgBorder.width : root.width - (root.cfgBorder.width * 2)
            height: root.horizontal ? root.height - (root.cfgBorder.width * 2) : root.cfgBorder.width
            color: (root.unifyBgType === 2 || root.unifyBgType === 3) ? "black" : "transparent"
            anchors.left: root.horizontal ? parent.left : undefined
            anchors.top: !root.horizontal ? parent.top : undefined
            anchors.verticalCenter: root.horizontal ? parent.verticalCenter : undefined
            anchors.horizontalCenter: !root.horizontal ? parent.horizontalCenter : undefined
            antialiasing: true
        }
    }
}

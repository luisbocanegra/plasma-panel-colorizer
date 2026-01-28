pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Effects
import org.kde.kirigami as Kirigami

Rectangle {
    id: root
    anchors.fill: parent
    color: "transparent"
    property bool panelTouchingTop: false
    property bool panelTouchingBottom: false
    property bool panelTouchingLeft: false
    property bool panelTouchingRight: false
    // when true, hide the border touching the screen edge
    property bool flattenPanelBordersOnEdge: false
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

    Rectangle {
        id: normalBorder
        anchors.fill: parent
        color: "transparent"
        // the mask source needs to be hidden by default
        visible: false
        border {
            color: root.borderColor
            width: !root.cfgBorder.customSides ? root.cfgBorder.width || -1 : 0
            pixelAligned: false
        }
        topLeftRadius: root.corners.topLeftRadius
        topRightRadius: root.corners.topRightRadius
        bottomLeftRadius: root.corners.bottomLeftRadius
        bottomRightRadius: root.corners.bottomRightRadius
        antialiasing: true
    }

    // Mask to hide one (start/end) or two (middle) borders between widgets inside an island
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
        // island widget mask right/bottom
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
            anchors.alignWhenCentered: false
        }
        // island widget mask left/top
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
            anchors.alignWhenCentered: false
        }
        // mask the border touching the screen edge
        Rectangle {
            id: edgeMaskTop
            width: parent.width - (root.cfgBorder.width * 2)
            height: root.cfgBorder.width
            anchors.top: parent.top
            color: (root.flattenPanelBordersOnEdge && root.panelTouchingTop) ? "black" : "transparent"
            antialiasing: true
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Rectangle {
            id: edgeMaskBottom
            width: parent.width - (root.cfgBorder.width * 2)
            height: root.cfgBorder.width
            anchors.bottom: parent.bottom
            color: (root.flattenPanelBordersOnEdge && root.panelTouchingBottom) ? "black" : "transparent"
            antialiasing: true
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Rectangle {
            id: edgeMaskLeft
            width: root.cfgBorder.width
            height: parent.height - (root.cfgBorder.width * 2)
            anchors.left: parent.left
            color: (root.flattenPanelBordersOnEdge && root.panelTouchingLeft) ? "black" : "transparent"
            antialiasing: true
            anchors.verticalCenter: parent.verticalCenter
        }
        Rectangle {
            id: edgeMaskRight
            width: root.cfgBorder.width
            height: parent.height - (root.cfgBorder.width * 2)
            anchors.right: parent.right
            color: (root.flattenPanelBordersOnEdge && root.panelTouchingRight) ? "black" : "transparent"
            antialiasing: true
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}

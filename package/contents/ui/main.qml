import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.plasma5support as P5Support
import org.kde.plasma.workspace.components as WorkspaceComponents
import org.kde.taskmanager 0.1 as TaskManager
import QtQuick.Effects

import "components" as Components
import "code/utils.js" as Utils

PlasmoidItem {
    id: main
    preferredRepresentation: fullRepresentation
    property int panelLayoutCount: panelLayout?.children?.length || 0
    property int trayGridViewCount: trayGridView?.count || 0
    property int trayGridViewCountOld: 0
    property var panelPrefixes: ["north","south","west","east"]
    property bool horizontal: Plasmoid.formFactor === PlasmaCore.Types.Horizontal
    property bool fixedSidePaddingEnabled: Object.values(panelSettings.padding).some(value => value !== 0)
    property bool isEnabled: true
    property bool nativePanelBackgroundEnabled: cfg.nativePanelBackground.enabled
    property real nativePanelBackgroundOpacity: cfg.nativePanelBackground.opacity
    property var panelWidgets: []
    property int panelWidgetsCount: 0
    property real trayItemThikness: 20
    property bool separateTray: trayWidgetSettings.enabled
    property var cfg: {
        try {
            return JSON.parse(plasmoid.configuration.allSettings)
        } catch (e) {
            console.error(e, e.stack)
            return {}
        }
    }
    property var widgetSettings: cfg.widgets
    property var panelSettings: cfg.panel
    property var trayWidgetSettings: cfg.trayWidgets
    property var forceRecolorList: cfg.forceForegroundColor
    property int forceRecolorCount: Object.keys(forceRecolorList).length
    signal recolorNeeded()

    onForceRecolorCountChanged: {
        console.error("onForceRecolorCountChanged ->", forceRecolorCount)
        recolorNeeded()
    }

    function getColor(colorCfg, targetIndex) {
        let newColor = "transparent"
        switch (colorCfg.sourceType) {
            case 0:
                newColor = Utils.rgbToQtColor(Utils.hexToRgb(colorCfg.custom))
            break
            case 1:
                newColor = Kirigami.Theme[colorCfg.systemColor]
            break
            case 2:
                const nextIndex = targetIndex % colorCfg.list.length
                newColor = Utils.rgbToQtColor(Utils.hexToRgb(colorCfg.list[nextIndex]))
            break
            case 3:
                newColor = Utils.getRandomColor()
            break
            case 4:
                newColor = colorCfg.custom
            break
            default:
                newColor = "transparent"
        }
        if (colorCfg.saturationEnabled) {
            newColor = Utils.scaleSaturation(newColor, colorCfg.saturationValue)
        }
        if (colorCfg.lightnessEnabled) {
            newColor = Utils.scaleLightness(newColor, colorCfg.lightnessValue)
        }
        if (colorCfg.alpha !== 1) {
            newColor = Qt.hsla(newColor.hslHue, newColor.hslSaturation, newColor.hslLightness, colorCfg.alpha)
        }
        return newColor
    }

    function applyFgColor(element, newColor, fgColorCfg, depth, forceMask, forceEffect) {
        let count = 0;
        let maxDepth = depth
        let widgetName = Utils.getWidgetName(element)
        if (widgetName === "org.kde.plasma.systemtray" && separateTray) return
        if (widgetName && widgetName in forceRecolorList) {
            forceMask = forceRecolorList[widgetName].method.mask
            forceEffect = forceRecolorList[widgetName].method.multiEffect
        }
        for (var i = 0; i < element.visibleChildren.length; i++) {
            var child = element.visibleChildren[i]
            if (child.Kirigami?.Theme) {
                child.Kirigami.Theme.textColor = newColor
                child.Kirigami.Theme.colorSet = Kirigami.Theme[fgColorCfg.systemColorSet]
                child.Kirigami.Theme.inherit = fgColorCfg.sourceType === 1
            }
            if ([Text,ToolButton,Label,Canvas,Kirigami.Icon].some(function (type) {return child instanceof type})) {
                if (child.color) {
                    child.color = newColor
                }
                if (child.hasOwnProperty("isMask") && forceMask) {
                    child.isMask = true
                }

                if (forceEffect) {
                    const effectItem = Utils.getEffectItem(child)
                    if (!effectItem) {
                        colorEffectComoponent.createObject(child, {"target": child, "colorizationColor": newColor})
                    } else {
                        effectItem.colorizationColor = newColor
                    }
                }
                count++
                // repaintDebugComponent.createObject(child)
            }
            if (child.visibleChildren?.length ?? 0 > 0) {
                const result = applyFgColor(child, newColor, fgColorCfg, depth + 1, forceMask, forceEffect)
                count += result.count
                if (result.depth > maxDepth) {
                    maxDepth = result.depth
                }
            }
        }
        return {"count": count, "depth": maxDepth}
    }

    property Component repaintDebugComponent: Rectangle {
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
                speedDebugItem.destroy()
            }
        }
        Component.onCompleted: {
            deleteThisTimer.start()
        }
    }

    property Component colorEffectComoponent: MultiEffect {
        // a not very effective way to recolor things that can't be recolored
        // the usual way
        id: effectRect
        property bool luisbocanegraPanelColorizerEffectManaged: true
        property Item target
        height: target.height
        width: target.width
        source: target
        colorization: 1
        autoPaddingEnabled: false
    }

    property Component backgroundComponent: Kirigami.ShadowedRectangle {
        id: rect
        property Item target
        property int targetIndex
        property int itemType
        property bool luisbocanegraPanelColorizerBgManaged: true
        // mask and color effect do
        property bool requiresRefresh: false
        property string widgetName: Utils.getWidgetName(target)
        property var cfg: {
            return Utils.getItemCfg(itemType, null) //TODO widget name here
        }
        property var bgColorCfg: cfg.backgroundColor
        property var fgColorCfg: cfg.foregroundColor
        property string fgColor: fgColorHolder.color
        property int itemCount: 0
        property int maxDepth: 0
        visible: cfg.enabled
        Rectangle {
            id: fgColorHolder
            height: 4
            width: 4
            visible: false
            radius: height / 2
            color: separateTray ? getColor(rect.fgColorCfg, targetIndex) : getColor(widgetSettings.foregroundColor, targetIndex)
            Kirigami.Theme.colorSet: Kirigami.Theme[fgColorCfg.systemColorSet]
            Kirigami.Theme.inherit: fgColorCfg.sourceType === 1
        }
        // Label {
        //     id: debugLabel
        //     text: targetIndex //maxDepth+","+itemCount
        //     font.pixelSize: 8
        // }
        corners {
            topLeftRadius: cfg.radius.topLeft
            topRightRadius: cfg.radius.topRight
            bottomLeftRadius: cfg.radius.bottomLeft
            bottomRightRadius: cfg.radius.bottomRight
        }
        Kirigami.Theme.colorSet: Kirigami.Theme[bgColorCfg.systemColorSet]
        Kirigami.Theme.inherit: bgColorCfg.sourceType === 1
        color: {
            return getColor(bgColorCfg, targetIndex)
        }
        Timer {
            id: recolorTimer
            interval: 250
            repeat: requiresRefresh
            onTriggered: {
                if (!(rect.itemType === Enums.ItemType.PanelBgItem)) {
                    const result = applyFgColor(target, fgColor, fgColorCfg, 0, false, false)
                    if (result) {
                        itemCount = result.count
                        maxDepth = result.depth
                    }
                }
            }
        }

        property int targetChildren: target.children.length
        onTargetChildrenChanged: {
            // console.error("CHILDREN CHANGED", targetChildren, target)
            recolorTimer.start()
        }
        property int targetVisibleChildren: target.visibleChildren.length
        onTargetVisibleChildrenChanged: {
            // console.error("CHILDREN CHANGED", targetVisibleChildren, target)
            recolorTimer.start()
        }
        property int targetCount: target.count || 0
        onTargetCountChanged: {
            // console.error("COUNT CHANGED", targetCount, target)
            recolorTimer.start()
        }

        onFgColorChanged: {
            // console.error("FG COLOR CHANGED", fgColor, target)
            recolorTimer.start()
        }
        function recolor() {
            recolorTimer.start()
        }
        Component.onCompleted: {
            main.recolorNeeded.connect(rect.recolor)
            recolorTimer.start()
            if (widgetName && widgetName in forceRecolorList) {
                requiresRefresh = true
            }
        }

        height: itemType === Enums.ItemType.TrayItem ? target.height : parent.height
        width: itemType === Enums.ItemType.TrayItem ? target.width : parent.width
        anchors.centerIn: (itemType === Enums.ItemType.TrayItem || itemType === Enums.ItemType.TrayArrow) ? parent : undefined
        anchors.fill: (itemType === Enums.ItemType.PanelBgItem||itemType === Enums.ItemType.TrayItem || itemType === Enums.ItemType.TrayArrow) ? parent : undefined

        property bool addMargin: Object.values(cfg.margin).some(value => value !== 0) || itemType === Enums.ItemType.PanelBgItem
        property int marginLeft: cfg.margin.left
        property int marginRight: cfg.margin.right
        property int horizontalWidth: marginLeft + marginRight

        property int marginTop: cfg.margin.top
        property int marginBottom: cfg.margin.bottom
        property int verticalWidth: marginTop + marginBottom

        Binding {
            target: rect
            property: "x"
            value: -marginLeft
            when: addMargin && itemType === Enums.ItemType.WidgetItem && horizontal
        }

        Binding {
            target: rect
            property: "y"
            value: -marginTop
            when: addMargin && itemType === Enums.ItemType.WidgetItem && !horizontal
        }

        Binding {
            target: rect
            property: "width"
            value: parent.width + horizontalWidth
            when: addMargin && itemType === Enums.ItemType.WidgetItem && horizontal
        }

        Binding {
            target: rect
            property: "height"
            value: parent.height + verticalWidth
            when: addMargin && itemType === Enums.ItemType.WidgetItem && !horizontal
        }

        Binding {
            target: rect.target
            property: "Layout.leftMargin"
            value: marginLeft
            when: addMargin && itemType === Enums.ItemType.WidgetItem
        }

        Binding {
            target: rect.target
            property: "Layout.rightMargin"
            value: marginRight
            when: addMargin && itemType === Enums.ItemType.WidgetItem
        }

        Binding {
            target: rect.target
            property: "Layout.topMargin"
            value: marginTop
            when: addMargin && itemType === Enums.ItemType.WidgetItem
        }

        Binding {
            target: rect.target
            property: "Layout.bottomMargin"
            value: marginBottom
            when: addMargin && itemType === Enums.ItemType.WidgetItem
        }

        // Panel background, we actually change the panel margin so everything moves with it

        Binding {
            target: rect.target
            property: "anchors.leftMargin"
            value: marginLeft
            when: addMargin && itemType === Enums.ItemType.PanelBgItem
        }

        Binding {
            target: rect.target
            property: "anchors.rightMargin"
            value: marginRight
            when: addMargin && itemType === Enums.ItemType.PanelBgItem
        }

        Binding {
            target: rect.target
            property: "anchors.topMargin"
            value: marginTop
            when: addMargin && itemType === Enums.ItemType.PanelBgItem
        }

        Binding {
            target: rect.target
            property: "anchors.bottomMargin"
            value: marginBottom
            when: addMargin && itemType === Enums.ItemType.PanelBgItem
        }

        // Tray item / arrow

        Binding {
            target: rect
            property: "anchors.leftMargin"
            value: marginLeft
            when: addMargin && (itemType === Enums.ItemType.TrayArrow || itemType === Enums.ItemType.TrayItem)
        }

        Binding {
            target: rect
            property: "anchors.rightMargin"
            value: marginRight
            when: addMargin && (itemType === Enums.ItemType.TrayArrow || itemType === Enums.ItemType.TrayItem)
        }

        Binding {
            target: rect
            property: "anchors.topMargin"
            value: marginTop
            when: addMargin && (itemType === Enums.ItemType.TrayArrow || itemType === Enums.ItemType.TrayItem)
        }

        Binding {
            target: rect
            property: "anchors.bottomMargin"
            value: marginBottom
            when: addMargin && (itemType === Enums.ItemType.TrayArrow || itemType === Enums.ItemType.TrayItem)
        }

        // fix tray weird margin
        Binding {
            target: rect.target
            property: "Layout.leftMargin"
            value: -2
            when: addMargin && itemType === Enums.ItemType.TrayArrow && horizontal
        }

        Binding {
            target: rect.target
            property: "Layout.rightMargin"
            value: 2
            when: addMargin && itemType === Enums.ItemType.TrayArrow && horizontal
        }

        Binding {
            target: rect.target
            property: "Layout.topMargin"
            value: -2
            when: addMargin && itemType === Enums.ItemType.TrayArrow && !horizontal
        }

        Binding {
            target: rect.target
            property: "Layout.bottomMargin"
            value: 2
            when: addMargin && itemType === Enums.ItemType.TrayArrow && !horizontal
        }

        Rectangle {
            id: borderRec
            anchors.fill: parent
            color: "transparent"

            property var borderColorCfg: cfg.border.color
            Kirigami.Theme.colorSet: Kirigami.Theme[borderColorCfg.systemColorSet]
            Kirigami.Theme.inherit: borderColorCfg.sourceType === 1
            property color borderColor: {
                return getColor(borderColorCfg, targetIndex)
            }

            Rectangle {
                id: customBorderTop
                width: parent.width
                visible: cfg.border.customSides && cfg.border.custom.widths.top
                height: cfg.border.custom.widths.top
                color: borderRec.borderColor
                anchors.top: parent.top
            }
            Rectangle {
                id: customBorderBottom
                width: parent.width
                visible: cfg.border.customSides && cfg.border.custom.widths.bottom
                height: cfg.border.custom.widths.bottom
                color: borderRec.borderColor
                anchors.bottom: parent.bottom
            }

            Rectangle {
                id: customBorderLeft
                height: parent.height
                visible: cfg.border.customSides && cfg.border.custom.widths.left
                width: cfg.border.custom.widths.left
                color: borderRec.borderColor
                anchors.left: parent.left
            }
            Rectangle {
                id: customBorderRight
                height: parent.height
                visible: cfg.border.customSides && cfg.border.custom.widths.right
                width: cfg.border.custom.widths.right
                color: borderRec.borderColor
                anchors.right: parent.right
            }

            Kirigami.ShadowedRectangle {
                anchors.fill: parent
                color: "transparent"
                visible: !cfg.border.customSides
                border {
                    color: borderRec.borderColor
                    width: cfg.border.width
                }
                corners {
                    topLeftRadius: cfg.radius.topLeft
                    topRightRadius: cfg.radius.topRight
                    bottomLeftRadius: cfg.radius.bottomLeft
                    bottomRightRadius: cfg.radius.bottomRight
                }
            }

            layer.enabled: true
            layer.effect: MultiEffect {
                maskEnabled: true
                maskSpreadAtMax: 1
                maskSpreadAtMin: 1
                maskThresholdMin: 0.5
                maskSource: ShaderEffectSource {
                    sourceItem: Kirigami.ShadowedRectangle {
                        width: rect.width
                        height: rect.height
                        corners {
                            topLeftRadius: cfg.radius.topLeft
                            topRightRadius: cfg.radius.topRight
                            bottomLeftRadius: cfg.radius.bottomLeft
                            bottomRightRadius: cfg.radius.bottomRight
                        }
                    }
                }
            }
        }

        shadow {
            property var shadowColorCfg: cfg.shadow.color
            Kirigami.Theme.colorSet: Kirigami.Theme[shadowColorCfg.systemColorSet]
            Kirigami.Theme.inherit: shadowColorCfg.sourceType === 1
            size: cfg.shadow.size
            color: {
                return getColor(shadowColorCfg, targetIndex)
            }
            xOffset: cfg.shadow.xOffset
            yOffset: cfg.shadow.yOffset
        }
    }

    fullRepresentation: RowLayout {
        Label {
            text: panelLayoutCount+","+trayGridViewCount
        }
    }

    // Search the actual gridLayout of the panel
    property GridLayout panelLayout: {
        let candidate = main.parent;
        while (candidate) {
            if (candidate instanceof GridLayout) {
                candidate.rowSpacing = widgetSettings.spacing
                candidate.columnSpacing = widgetSettings.spacing
                return candidate;
            }
            candidate = candidate.parent;
        }
        return null
    }

    property Item panelLayoutContainer: {
        if (!panelLayout) return null
        return panelLayout.parent
    }

    Binding {
        target: panelLayoutContainer
        property: "anchors.leftMargin"
        value: panelSettings.padding.left
        when: fixedSidePaddingEnabled
    }

    Binding {
        target: panelLayoutContainer
        property: "anchors.rightMargin"
        value: panelSettings.padding.right
        when: fixedSidePaddingEnabled
    }

    Binding {
        target: panelLayoutContainer
        property: "anchors.topMargin"
        value: panelSettings.padding.top
        when: fixedSidePaddingEnabled
    }

    Binding {
        target: panelLayoutContainer
        property: "anchors.bottomMargin"
        value: panelSettings.padding.bottom
        when: fixedSidePaddingEnabled
    }

    property Item panelBg: {
        if (!panelLayoutContainer) return null
        return panelLayoutContainer.parent
    }

    property GridView trayGridView: {
        if (!panelLayout?.children) return null
        for (let i in panelLayout.children) {
            const child = panelLayout.children[i];
            // name may not be available while gragging into the panel and
            // other situations
            if (!child.applet?.plasmoid?.pluginName) continue
            const name = child.applet.plasmoid.pluginName
            if (name === "org.kde.plasma.systemtray") {
                return Utils.findTrayGridView(child)
            }
        }
        return null;
    }

    property Item trayExpandArrow: {
        if (trayGridView?.parent) {
            return Utils.findTrayExpandArrow(trayGridView.parent)
        }
        return null
    }

    Connections {
        target: trayGridView
        onWidthChanged: {
            if (horizontal) {
                trayExpandArrow.iconSize = trayGridView.cellWidth
            } else {
                trayExpandArrow.iconSize = trayGridView.cellHeight
            }
        }
        onHeightChanged: {
            if (horizontal) {
                trayExpandArrow.iconSize = trayGridView.cellWidth
            } else {
                trayExpandArrow.iconSize = trayGridView.cellHeight
            }
        }
    }

    // Search for the element containing the panel background
    property var panelElement: {
        let candidate = main.parent;
        while (candidate) {
            if (candidate.hasOwnProperty("floating")) {
                return candidate;
            }
            candidate = candidate.parent;
        }
        return null
    }

    property ContainmentItem containmentItem: {
        let candidate = main.parent;
        while (candidate) {
            if (candidate.toString().indexOf("ContainmentItem_QML") > -1 ) {
                return candidate;
            }
            candidate = candidate.parent;
        }
        return null
    }

    onPanelElementChanged: {
        if(!panelElement) return
        Utils.panelOpacity(panelElement, isEnabled, nativePanelBackgroundOpacity)
    }

    onNativePanelBackgroundOpacityChanged: {
        if(!panelElement) return
        Utils.panelOpacity(panelElement, isEnabled, nativePanelBackgroundOpacity)
    }

    onContainmentItemChanged: {
        if(!containmentItem) return
        Utils.toggleTransparency(containmentItem, nativePanelBackgroundEnabled)
    }

    onNativePanelBackgroundEnabledChanged: {
        if(!containmentItem) return
        Utils.toggleTransparency(containmentItem, nativePanelBackgroundEnabled)
    }

    onPanelLayoutCountChanged: {
        if (panelLayoutCount === 0) return
        trayInitTimer.restart()
        showWidgets(panelLayout)
        updateCurrentWidgets()
        showPanelBg(panelBg)
    }

    onTrayGridViewCountChanged: {
        if (trayGridViewCount === 0) return
        // console.error(trayGridViewCount);
        trayInitTimer.restart()
    }

    Timer {
        id: trayInitTimer
        interval: 100
        onTriggered: {
            if (trayGridView && trayGridViewCount !== 0) {
                showTrayAreas(trayGridView)
                showTrayAreas(trayGridView.parent)
            }
            updateCurrentWidgets()
        }
    }

    function updateCurrentWidgets() {
        panelWidgets = []
        panelWidgets = Utils.findWidgets(panelLayout, panelWidgets)
        if (!trayGridView) return
        panelWidgets = Utils.findWidgetsTray(trayGridView, panelWidgets)
        panelWidgets = Utils.findWidgetsTray(trayGridView.parent, panelWidgets)
    }

    function showTrayAreas(grid) {
        if (grid instanceof GridView) {
            let index = 0
            for (let i = 0; i < grid.count; i++) {
                const item = grid.itemAtIndex(i);
                if (Utils.isBgManaged(item)) continue
                // Utils.dumpProps(item)
                backgroundComponent.createObject(item,
                    { "z":-1, "target": item, "itemType": Enums.ItemType.TrayItem, "targetIndex": index }
                )
                if (item.visible) {
                    index++
                }
            }

            for (let i in grid.parent.children) {
                const item = grid.parent.children[i]
                if (!(item instanceof GridView)) {
                    if (Utils.isBgManaged(item)) continue
                    item.iconSize = horizontal ? trayGridView.cellWidth : trayGridView.cellHeight
                    // item.Layout.leftMargin = -2
                    // item.Layout.rightMargin = 2
                    backgroundComponent.createObject(item,
                        { "z":-1, "target": item, "itemType": Enums.ItemType.TrayArrow, "targetIndex": index}
                    )
                }
            }
        }
    }

    function showWidgets(panelLayout) {
        for (var i in panelLayout.children) {
            const child = panelLayout.children[i];
            // name may not be available while gragging into the panel and
            // other situations
            if (!child.applet?.plasmoid?.pluginName) continue
            if (Utils.isBgManaged(child)) continue
            // console.error(child.applet?.plasmoid?.pluginName)
            // Utils.dumpProps(child)
            backgroundComponent.createObject(child,
                { "z":-1, "target":child, "itemType": Enums.ItemType.WidgetItem , "targetIndex": i }
            );
        }
    }

    function showPanelBg(panelBg) {
        // Utils.dumpProps(panelBg)
        backgroundComponent.createObject(panelBg,
            { "z":-1, "target": panelBg, "itemType": Enums.ItemType.PanelBgItem })
    }

    onPanelWidgetsCountChanged: {
        // console.error( panelWidgetsCount ,JSON.stringify(panelWidgets, null, null))
        plasmoid.configuration.panelWidgets = ""
        plasmoid.configuration.panelWidgets = JSON.stringify(panelWidgets, null, null)
    }

    Timer {
        running: true
        repeat: true
        interval: 1000
        onTriggered: {
            let tmp = panelWidgets.length
            if (tmp !== panelWidgetsCount) {
                panelWidgetsCount = tmp
            }
        }
    }
}

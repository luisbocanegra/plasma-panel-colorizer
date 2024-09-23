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
import "code/globals.js" as Globals

PlasmoidItem {
    id: main
    preferredRepresentation: fullRepresentation
    property int panelLayoutCount: panelLayout?.children?.length || 0
    property int trayGridViewCount: trayGridView?.count || 0
    property int trayGridViewCountOld: 0
    property var panelPrefixes: ["north","south","west","east"]
    property bool horizontal: Plasmoid.formFactor === PlasmaCore.Types.Horizontal
    property bool fixedSidePaddingEnabled: panelSettings.padding.enabled
    property bool isEnabled: true
    property bool nativePanelBackgroundEnabled: cfg.nativePanelBackground.enabled
    property real nativePanelBackgroundOpacity: cfg.nativePanelBackground.opacity
    property var panelWidgets: []
    property int panelWidgetsCount: panelWidgets?.length || 0
    property real trayItemThikness: 20
    property bool separateTray: trayWidgetSettings.enabled
    // items inside the tray need to know the tray index to take
    // the same foreground when we're not coloring them separately
    property int trayIndex: 0
    // keep track of these to allow others to follow their color
    property Item panelBgItem
    property Item trayWidgetBgItem
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
    property var forceRecolorList: cfg.forceForegroundColor?.widgets ?? {}
    property int forceRecolorInterval: cfg.forceForegroundColor?.reloadInterval ?? 0
    property int forceRecolorCount: Object.keys(forceRecolorList).length
    property bool requiresRefresh: Object.values(forceRecolorList).some(w => w.reload)
    property var configurationOverrides: cfg.configurationOverrides
    signal recolorCountChanged()
    signal refreshNeeded()

    onForceRecolorCountChanged: {
        console.error("onForceRecolorCountChanged ->", forceRecolorCount)
        recolorCountChanged()
    }

    function getColor(colorCfg, targetIndex, parentColor, itemType) {
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
                if (colorCfg.followColor === 0) {
                    newColor = panelBgItem.color
                } else if (colorCfg.followColor === 1) {
                    newColor = itemType === Enums.ItemType.TrayItem || itemType === Enums.ItemType.TrayArrow
                        ? trayWidgetBgItem.color
                        : parentColor
                } else if (colorCfg.followColor === 2) {
                    newColor = parentColor
                }

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

    function applyFgColor(element, newColor, fgColorCfg, depth, forceMask, forceEffect, itemType) {
        let count = 0;
        let maxDepth = depth
        const isTrayArrow = itemType === Enums.ItemType.TrayArrow
        let widgetName = isTrayArrow ? "org.kde.plasma.systemtray.expand" : Utils.getWidgetName(element)
        if (widgetName === "org.kde.plasma.systemtray" && separateTray) return
        if (widgetName && widgetName in forceRecolorList) {
            forceMask = forceRecolorList[widgetName].method.mask
            forceEffect = forceRecolorList[widgetName].method.multiEffect
        }
        for (var i = 0; i < element.visibleChildren.length; i++) {
            var child = element.visibleChildren[i]
            if ([Text,ToolButton,Label,Canvas,Kirigami.Icon].some(function (type) {return child instanceof type})) {
                if (child.Kirigami?.Theme) {
                    child.Kirigami.Theme.textColor = newColor
                    child.Kirigami.Theme.colorSet = Kirigami.Theme[fgColorCfg.systemColorSet]
            }
            }
            if ([Text,ToolButton,Label,Canvas,Kirigami.Icon].some(function (type) {return child instanceof type})) {
                }
            if ([Text,ToolButton,Label,Canvas,Kirigami.Icon].some(function (type) {return child instanceof type})) {
                if (child.color) {
                    child.color = newColor
                }
                if (child.hasOwnProperty("isMask") && forceMask) {
                    child.isMask = true
                }

                if (
                    forceEffect
                    && [Canvas,Kirigami.Icon].some(function (type) {return child instanceof type})
                ) {
                    const effectItem = Utils.getEffectItem(child.parent)
                    if (!effectItem) {
                        colorEffectComoponent.createObject(child.parent, {"target": child, "colorizationColor": newColor})
                    } else {
                        effectItem.source = null
                        effectItem.colorizationColor = newColor
                        effectItem.source = child
                    }
                }
                count++
                // repaintDebugComponent.createObject(child)
            }
            if (child.visibleChildren?.length ?? 0 > 0) {
                const result = applyFgColor(child, newColor, fgColorCfg, depth + 1, forceMask, forceEffect, itemType)
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
        anchors.centerIn: parent
        source: target
        colorization: 1
        autoPaddingEnabled: false
    }

    property Component backgroundComponent: Kirigami.ShadowedRectangle {
        id: rect
        property Item target
        property int targetIndex
        property int itemType
        property bool isPanel: itemType === Enums.ItemType.PanelBgItem
        property bool isWidget: itemType === Enums.ItemType.WidgetItem
        property bool isTray: itemType === Enums.ItemType.TrayItem
        property bool isTrayArrow: itemType === Enums.ItemType.TrayArrow
        property bool inTray: isTray || isTrayArrow
        property bool luisbocanegraPanelColorizerBgManaged: true
        property string widgetName: isTrayArrow ? "org.kde.plasma.systemtray.expand" : Utils.getWidgetName(target)
        property bool requiresRefresh: forceRecolorList[widgetName]?.reload ?? false
        property var itemConfig: Utils.getItemCfg(itemType, widgetName, main.cfg)
        property var cfg: itemConfig.settings
        property bool cfgOverride: itemConfig.override
        property var bgColorCfg: cfg.backgroundColor
        property var fgColorCfg: cfg.foregroundColor
        property string fgColor: fgColorHolder.color
        property int itemCount: 0
        property int maxDepth: 0
        visible: cfg.enabled
        property bool bgEnabled: bgColorCfg.enabled
        property bool fgEnabled: fgColorCfg.enabled
        property bool radiusEnabled: cfg.radius.enabled
        property bool marginEnabled: cfg.margin.enabled
        property bool borderEnabled: cfg.border.enabled
        property bool shadowEnabled: cfg.shadow.enabled
        Rectangle {
            id: fgColorHolder
            height: 6
            width: height
            visible: false
            radius: height / 2
            property var newColor: {
                if (separateTray || cfgOverride) {
                    return getColor(rect.fgColorCfg, targetIndex, rect.color, itemType)
                } else if (inTray) {
                    return getColor(widgetSettings.foregroundColor, trayIndex, rect.color, itemType)
                } else {
                    return getColor(widgetSettings.foregroundColor, targetIndex, rect.color, itemType)
                }
            }
            Binding {
                target: fgColorHolder
                property: "color"
                value: fgEnabled ? fgColorHolder.newColor : Kirigami.Theme.textColor
                when: cfg.enabled || !separateTray
            }
            Binding {
                target: fgColorHolder
                property: "Kirigami.Theme.colorSet"
                value: Kirigami.Theme[fgColorCfg.systemColorSet]
                when: cfg.enabled
            }
            Binding {
                target: fgColorHolder
                property: "Kirigami.Theme.inherit"
                value: fgColorCfg.sourceType === 1
                when: cfg.enabled
            }
        }
        // Label {
        //     id: debugLabel
        //     text: targetIndex+","+trayIndex //maxDepth+","+itemCount
        //     font.pixelSize: 8
        // }
        corners {
            topLeftRadius: radiusEnabled ? cfg.radius.corner.topLeft : 0
            topRightRadius: radiusEnabled ? cfg.radius.corner.topRight : 0
            bottomLeftRadius: radiusEnabled ? cfg.radius.corner.bottomLeft : 0
            bottomRightRadius: radiusEnabled ? cfg.radius.corner.bottomRight : 0
        }
        Kirigami.Theme.colorSet: Kirigami.Theme[bgColorCfg.systemColorSet]
        Kirigami.Theme.inherit: bgColorCfg.sourceType === 1
        color: {
            if (bgEnabled) {
                return getColor(bgColorCfg, targetIndex, null, itemType)
            } else {
                return "transparent"
            }
        }

        property int targetChildren: target.children.length
        onTargetChildrenChanged: {
            // console.error("CHILDREN CHANGED", targetChildren, target)
            recolorTimer.restart()
        }
        property int targetVisibleChildren: target.visibleChildren.length
        onTargetVisibleChildrenChanged: {
            // console.error("CHILDREN CHANGED", targetVisibleChildren, target)
            recolorTimer.restart()
        }
        property int targetCount: target.count || 0
        onTargetCountChanged: {
            // console.error("COUNT CHANGED", targetCount, target)
            recolorTimer.restart()
        }

        onFgColorChanged: {
            // console.error("FG COLOR CHANGED", fgColor, target)
            recolorTimer.restart()
        }

        Timer {
            id: recolorTimer
            interval: 10
            onTriggered: {
                if (isPanel) return
                const result = applyFgColor(target, fgColor, fgColorCfg, 0, false, false, itemType)
                if (result) {
                    itemCount = result.count
                    maxDepth = result.depth
                }
            }
        }

        function recolor() {
            recolorTimer.restart()
        }

        onRequiresRefreshChanged: {
            if (requiresRefresh) {
                main.refreshNeeded.connect(rect.recolor)
            } else {
                main.refreshNeeded.disconnect(rect.recolor)
            }
        }

        Component.onCompleted: {
            main.recolorCountChanged.connect(rect.recolor)
            recolorTimer.start()
        }

        height: isTray ? target.height : parent.height
        width: isTray ? target.width : parent.width
        anchors.centerIn: (isTray || isTrayArrow) ? parent : undefined
        anchors.fill: (isPanel ||isTray || isTrayArrow) ? parent : undefined

        property bool addMargin: cfg.enabled
            && marginEnabled && (Object.values(cfg.margin.side).some(value => value !== 0) || isPanel)
        property int marginLeft: cfg.margin.side.left
        property int marginRight: cfg.margin.side.right
        property int horizontalWidth: marginLeft + marginRight

        property int marginTop: cfg.margin.side.top
        property int marginBottom: cfg.margin.side.bottom
        property int verticalWidth: marginTop + marginBottom

        Binding {
            target: rect
            property: "x"
            value: -marginLeft
            when: addMargin && isWidget && horizontal
        }

        Binding {
            target: rect
            property: "y"
            value: -marginTop
            when: addMargin && isWidget && !horizontal
        }

        Binding {
            target: rect
            property: "width"
            value: parent.width + horizontalWidth
            when: addMargin && isWidget && horizontal
        }

        Binding {
            target: rect
            property: "height"
            value: parent.height + verticalWidth
            when: addMargin && isWidget && !horizontal
        }

        Binding {
            target: rect.target
            property: "Layout.leftMargin"
            value: marginLeft
            when: addMargin && isWidget
        }

        Binding {
            target: rect.target
            property: "Layout.rightMargin"
            value: marginRight
            when: addMargin && isWidget
        }

        Binding {
            target: rect.target
            property: "Layout.topMargin"
            value: marginTop
            when: addMargin && isWidget
        }

        Binding {
            target: rect.target
            property: "Layout.bottomMargin"
            value: marginBottom
            when: addMargin && isWidget
        }

        // Panel background, we actually change the panel margin so everything moves with it

        Binding {
            target: rect.target
            property: "anchors.leftMargin"
            value: marginLeft
            when: addMargin && isPanel
        }

        Binding {
            target: rect.target
            property: "anchors.rightMargin"
            value: marginRight
            when: addMargin && isPanel
        }

        Binding {
            target: rect.target
            property: "anchors.topMargin"
            value: marginTop
            when: addMargin && isPanel
        }

        Binding {
            target: rect.target
            property: "anchors.bottomMargin"
            value: marginBottom
            when: addMargin && isPanel
        }

        // Tray item / arrow

        Binding {
            target: rect
            property: "anchors.leftMargin"
            value: marginLeft
            when: addMargin && (isTrayArrow || isTray)
        }

        Binding {
            target: rect
            property: "anchors.rightMargin"
            value: marginRight
            when: addMargin && (isTrayArrow || isTray)
        }

        Binding {
            target: rect
            property: "anchors.topMargin"
            value: marginTop
            when: addMargin && (isTrayArrow || isTray)
        }

        Binding {
            target: rect
            property: "anchors.bottomMargin"
            value: marginBottom
            when: addMargin && (isTrayArrow || isTray)
        }

        // fix tray weird margin
        Binding {
            target: rect.target
            property: "Layout.leftMargin"
            value: -2
            when: addMargin && isTrayArrow && horizontal
        }

        Binding {
            target: rect.target
            property: "Layout.rightMargin"
            value: 2
            when: addMargin && isTrayArrow && horizontal
        }

        Binding {
            target: rect.target
            property: "Layout.topMargin"
            value: -2
            when: addMargin && isTrayArrow && !horizontal
        }

        Binding {
            target: rect.target
            property: "Layout.bottomMargin"
            value: 2
            when: addMargin && isTrayArrow && !horizontal
        }

        Rectangle {
            id: borderRec
            anchors.fill: parent
            color: "transparent"
            visible: borderEnabled
            property var borderColorCfg: cfg.border.color
            Kirigami.Theme.colorSet: Kirigami.Theme[borderColorCfg.systemColorSet]
            Kirigami.Theme.inherit: borderColorCfg.sourceType === 1
            property color borderColor: {
                return getColor(borderColorCfg, targetIndex, rect.color, itemType)
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
                    width: cfg.border.width || -1
                }
                corners {
                    topLeftRadius: radiusEnabled ? cfg.radius.corner.topLeft : 0
                    topRightRadius: radiusEnabled ? cfg.radius.corner.topRight : 0
                    bottomLeftRadius: radiusEnabled ? cfg.radius.corner.bottomLeft : 0
                    bottomRightRadius: radiusEnabled ? cfg.radius.corner.bottomRight : 0
                }
            }

            layer.enabled: cfg.border.customSides
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
                            topLeftRadius: radiusEnabled ? cfg.radius.corner.topLeft : 0
                            topRightRadius: radiusEnabled ? cfg.radius.corner.topRight : 0
                            bottomLeftRadius: radiusEnabled ? cfg.radius.corner.bottomLeft : 0
                            bottomRightRadius: radiusEnabled ? cfg.radius.corner.bottomRight : 0
                        }
                    }
                }
            }
        }

        shadow {
            property var shadowColorCfg: cfg.shadow.color
            Kirigami.Theme.colorSet: Kirigami.Theme[shadowColorCfg.systemColorSet]
            Kirigami.Theme.inherit: shadowColorCfg.sourceType === 1
            size: shadowEnabled ? cfg.shadow.size : 0
            color: {
                return getColor(shadowColorCfg, targetIndex, rect.color, itemType)
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
        value: panelSettings.padding.side.left
        when: fixedSidePaddingEnabled
    }

    Binding {
        target: panelLayoutContainer
        property: "anchors.rightMargin"
        value: panelSettings.padding.side.right
        when: fixedSidePaddingEnabled
    }

    Binding {
        target: panelLayoutContainer
        property: "anchors.topMargin"
        value: panelSettings.padding.side.top
        when: fixedSidePaddingEnabled
    }

    Binding {
        target: panelLayoutContainer
        property: "anchors.bottomMargin"
        value: panelSettings.padding.side.bottom
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
        console.error("onPanelLayoutCountChanged")
        Qt.callLater(function() {
            trayInitTimer.restart()
            showWidgets(panelLayout)
            updateCurrentWidgets()
            showPanelBg(panelBg)
        })
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
                if (!item.visible) continue
                const bgItem = Utils.getBgManaged(item)
                if (!bgItem) {
                    backgroundComponent.createObject(item,
                        { "z":-1, "target": item, "itemType": Enums.ItemType.TrayItem, "targetIndex": index }
                    )
                } else {
                    bgItem.targetIndex = index
                }
                if (item.visible) {
                    index++
                }
            }

            for (let i in grid.parent.children) {
                const item = grid.parent.children[i]
                if (!(item instanceof GridView)) {
                    if (!item.visible) continue
                    const bgItem = Utils.getBgManaged(item)
                    if (!bgItem) {
                        backgroundComponent.createObject(item,
                            { "z":-1, "target": item, "itemType": Enums.ItemType.TrayArrow, "targetIndex": index}
                        )
                    } else {
                        bgItem.targetIndex = index
                    }
                    item.iconSize = horizontal ? trayGridView.cellWidth : trayGridView.cellHeight
                }
            }
        }
    }

    function showWidgets(panelLayout) {
        console.error("showWidgets()")
        for (var i in panelLayout.children) {
            const child = panelLayout.children[i];
            // name may not be available while gragging into the panel and
            // other situations
            if (!child.applet?.plasmoid?.pluginName) continue
            // if (Utils.getBgManaged(child)) continue
            // console.error(child.applet?.plasmoid?.pluginName)
            // Utils.dumpProps(child)
            const isTray = child.applet.plasmoid.pluginName === "org.kde.plasma.systemtray"
            if (isTray) trayIndex = i
            const bgItem = Utils.getBgManaged(child)
            if (!bgItem) {
                const comp = backgroundComponent.createObject(child,
                    { "z":-1, "target":child, "itemType": Enums.ItemType.WidgetItem , "targetIndex": i }
                )
                if (isTray) trayWidgetBgItem = comp
            } else {
                bgItem.targetIndex = i
            }
        }
    }

    function showPanelBg(panelBg) {
        // Utils.dumpProps(panelBg)
        panelBgItem = backgroundComponent.createObject(panelBg,
            { "z":-1, "target": panelBg, "itemType": Enums.ItemType.PanelBgItem })
    }

    onPanelWidgetsCountChanged: {
        // console.error( panelWidgetsCount ,JSON.stringify(panelWidgets, null, null))
        plasmoid.configuration.panelWidgets = ""
        plasmoid.configuration.panelWidgets = JSON.stringify(panelWidgets, null, null)
    }

    Component.onCompleted: {
        Qt.callLater(function() {
            const config = Utils.mergeConfigs(Globals.defaultConfig, cfg)
            plasmoid.configuration.allSettings = Utils.stringify(config)
        })
    }

    Timer {
        running: requiresRefresh
        repeat: true
        interval: forceRecolorInterval
        onTriggered: {
            refreshNeeded()
        }
    }
}

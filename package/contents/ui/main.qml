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
import Qt5Compat.GraphicalEffects

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
    property bool fixedSidePaddingEnabled: isEnabled && panelSettings.padding.enabled
    property bool isEnabled: plasmoid.configuration.isEnabled
    property bool nativePanelBackgroundEnabled: isEnabled ? cfg.nativePanelBackground.enabled : enabled
    property real nativePanelBackgroundOpacity: isEnabled ? cfg.nativePanelBackground.opacity : 1.0
    property var panelWidgets: []
    property int panelWidgetsCount: panelWidgets?.length || 0
    property real trayItemThikness: 20
    property bool widgetEnabled: widgetSettings.enabled && isEnabled
    property bool separateTray: trayWidgetSettings.enabled
    // items inside the tray need to know the tray index to take
    // the same foreground when we're not coloring them separately
    property int trayIndex: 0
    // keep track of these to allow others to follow their color
    property Item panelBgItem
    property Item trayWidgetBgItem
    property string lastPreset
    property string presetsDir: StandardPaths.writableLocation(
                    StandardPaths.HomeLocation).toString().substring(7) + "/.config/panel-colorizer/"
    property var presetContent: ""
    property var panelState: {
        "maximized": tasksModel.maximizedExists,
        "touchingWindow": !panelElement ? false : Boolean(panelElement.touchingWindow),
        "floating": !panelElement ? false : Boolean(panelElement.floatingness)
    }
    property var cfg: {
        try {
            return JSON.parse(plasmoid.configuration.allSettings)
        } catch (e) {
            console.error(e, e.stack)
            return Globals.defaultConfig
        }
    }
    property var presetAutoloading: {
        try {
            return JSON.parse(plasmoid.configuration.presetAutoloading)
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
    property var panelColorizer: null
    property var blurMask: panelColorizer?.mask ?? null
    property var floatigness: panelElement?.floatingness ?? 0
    property bool debug: false
    signal recolorCountChanged()
    signal refreshNeeded()

    onForceRecolorCountChanged: {
        // console.error("onForceRecolorCountChanged ->", forceRecolorCount)
        recolorCountChanged()
    }

    Rectangle {
        id: colorHolder
        height: 0
        width: 0
        visible: false
        Kirigami.Theme.inherit: false
    }

    function getColor(colorCfg, targetIndex, parentColor, itemType) {
        let newColor = "transparent"
        switch (colorCfg.sourceType) {
            case 0:
                newColor = Utils.rgbToQtColor(Utils.hexToRgb(colorCfg.custom))
            break
            case 1:
                colorHolder.Kirigami.Theme.colorSet = Kirigami.Theme[colorCfg.systemColorSet]
                newColor = colorHolder.Kirigami.Theme[colorCfg.systemColor]
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

    function applyFgColor(element, newColor, fgColorCfg, depth, forceMask, forceEffect, itemType, widgetName) {
        let count = 0;
        let maxDepth = depth
        const isTrayArrow = itemType === Enums.ItemType.TrayArrow
        if (widgetName === "org.kde.plasma.systemtray" && separateTray) return
        if (widgetName in forceRecolorList) {
            forceMask = forceRecolorList[widgetName].method.mask
            forceEffect = forceRecolorList[widgetName].method.multiEffect
        }

        for (var i = 0; i < element.visibleChildren.length; i++) {
            var child = element.visibleChildren[i]
            let targetTypes = [Text,ToolButton,Label,Canvas,Kirigami.Icon]
            if (targetTypes.some(function (type) {return child instanceof type})) {
                if (child.color) {
                    child.color = newColor
                }
                if (child.Kirigami?.Theme) {
                    child.Kirigami.Theme.textColor = newColor
                    child.Kirigami.Theme.colorSet = Kirigami.Theme[fgColorCfg.systemColorSet]
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
                const result = applyFgColor(child, newColor, fgColorCfg, depth + 1, forceMask, forceEffect, itemType, widgetName)
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
        // we need an exra id so we can track the items in tray
        property int maskIndex: inTray ? (panelLayoutCount -1 + targetIndex) : targetIndex
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
        property int itemCount: 0
        property int maxDepth: 0
        visible: cfgEnabled
        property bool cfgEnabled: cfg.enabled && isEnabled
        property bool bgEnabled: cfgEnabled ? bgColorCfg.enabled : false
        property bool fgEnabled: fgColorCfg.enabled && cfgEnabled
        property bool radiusEnabled: cfg.radius.enabled && cfgEnabled
        property bool marginEnabled: cfg.margin.enabled && cfgEnabled
        property bool borderEnabled: cfg.border.enabled && cfgEnabled
        property bool bgShadowEnabled: cfg.shadow.background.enabled && cfgEnabled
        property var bgShadow: cfg.shadow.background
        property bool fgShadowEnabled: cfg.shadow.foreground.enabled && cfgEnabled
        property var fgShadow: cfg.shadow.foreground
        property bool blurBehind: {
            return isPanel || (isWidget && !panelBgItem?.blurBehind)
                || (inTray && !panelBgItem?.blurBehind && !trayWidgetBgItem?.blurBehind)
                ? cfg.blurBehind
                : false
        }
        property string fgColor: {
            if (!fgEnabled && !inTray) {
                return Kirigami.Theme.textColor
            } else if ((!fgEnabled && inTray && widgetEnabled)) {
                return trayWidgetBgItem.fgColor
            } else if (separateTray || cfgOverride) {
                return getColor(rect.fgColorCfg, targetIndex, rect.color, itemType)
            } else if (inTray) {
                return getColor(widgetSettings.foregroundColor, trayIndex, rect.color, itemType)
            } else {
                return getColor(widgetSettings.foregroundColor, targetIndex, rect.color, itemType)
            }
        }
        Rectangle {
            id: fgColorHolder
            height: 6
            width: height
            visible: debug
            radius: height / 2
            color: fgColor
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
                const result = applyFgColor(target, fgColor, fgColorCfg, 0, false, false, itemType, widgetName)
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
            when: marginEnabled && isWidget && horizontal
            delayed: true
        }

        Binding {
            target: rect
            property: "y"
            value: -marginTop
            when: marginEnabled && isWidget && !horizontal
            delayed: true
        }

        Binding {
            target: rect
            property: "width"
            value: parent.width + horizontalWidth
            when: marginEnabled && isWidget && horizontal
            delayed: true
        }

        Binding {
            target: rect
            property: "height"
            value: parent.height + verticalWidth
            when: marginEnabled && isWidget && !horizontal
            delayed: true
        }

        Binding {
            target: rect.target
            property: "Layout.leftMargin"
            value: marginLeft
            when: marginEnabled && isWidget
            delayed: true
        }

        Binding {
            target: rect.target
            property: "Layout.rightMargin"
            value: marginRight
            when: marginEnabled && isWidget
            delayed: true
        }

        Binding {
            target: rect.target
            property: "Layout.topMargin"
            value: marginTop
            when: marginEnabled && isWidget
            delayed: true
        }

        Binding {
            target: rect.target
            property: "Layout.bottomMargin"
            value: marginBottom
            when: marginEnabled && isWidget
            delayed: true
        }

        // Panel background, we actually change the panel margin so everything moves with it

        Binding {
            target: rect.target
            property: "anchors.leftMargin"
            value: marginEnabled ? marginLeft : 0
            when: isPanel
            delayed: true
        }

        Binding {
            target: rect.target
            property: "anchors.rightMargin"
            value: marginEnabled ? marginRight : 0
            when: isPanel
            delayed: true
        }

        Binding {
            target: rect.target
            property: "anchors.topMargin"
            value: marginEnabled ? marginTop : 0
            when: isPanel
            delayed: true
        }

        Binding {
            target: rect.target
            property: "anchors.bottomMargin"
            value: marginEnabled ? marginBottom : 0
            when: isPanel
            delayed: true
        }

        // Tray item / arrow

        Binding {
            target: rect
            property: "anchors.leftMargin"
            value: marginLeft
            when: marginEnabled && (isTrayArrow || isTray)
            delayed: true
        }

        Binding {
            target: rect
            property: "anchors.rightMargin"
            value: marginRight
            when: marginEnabled && (isTrayArrow || isTray)
            delayed: true
        }

        Binding {
            target: rect
            property: "anchors.topMargin"
            value: marginTop
            when: marginEnabled && (isTrayArrow || isTray)
            delayed: true
        }

        Binding {
            target: rect
            property: "anchors.bottomMargin"
            value: marginBottom
            when: marginEnabled && (isTrayArrow || isTray)
            delayed: true
        }

        // fix tray weird margin
        Binding {
            target: rect.target
            property: "Layout.leftMargin"
            value: -2
            when: marginEnabled && isTrayArrow && horizontal
            delayed: true
        }

        Binding {
            target: rect.target
            property: "Layout.rightMargin"
            value: 2
            when: marginEnabled && isTrayArrow && horizontal
            delayed: true
        }

        Binding {
            target: rect.target
            property: "Layout.topMargin"
            value: -2
            when: marginEnabled && isTrayArrow && !horizontal
            delayed: true
        }

        Binding {
            target: rect.target
            property: "Layout.bottomMargin"
            value: 2
            when: marginEnabled && isTrayArrow && !horizontal
            delayed: true
        }

        Rectangle {
            id: borderRec
            anchors.fill: parent
            color: "transparent"
            visible: borderEnabled
            property var borderColorCfg: cfg.border.color
            Kirigami.Theme.colorSet: Kirigami.Theme[borderColorCfg.systemColorSet]
            Kirigami.Theme.inherit: !(borderColorCfg.sourceType === 1)
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
            property var shadowColorCfg: bgShadow.color
            Kirigami.Theme.colorSet: Kirigami.Theme[shadowColorCfg.systemColorSet]
            size: bgShadowEnabled ? bgShadow.size : 0
            color: {
                return getColor(shadowColorCfg, targetIndex, rect.color, itemType)
            }
            xOffset: bgShadow.xOffset
            yOffset: bgShadow.yOffset
        }

        DropShadow {
            height: target.height
            width: target.width
            anchors.centerIn: parent
            property var shadowColorCfg: fgShadow.color
            Kirigami.Theme.colorSet: Kirigami.Theme[shadowColorCfg.systemColorSet]
            horizontalOffset: fgShadow.xOffset
            verticalOffset: fgShadow.yOffset
            radius: fgShadowEnabled ? fgShadow.size : 0
            samples: radius * 2 + 1
            spread: 0.35
            color: {
                return getColor(shadowColorCfg, targetIndex, rect.color, itemType)
            }
            source: target.applet
            visible: fgShadowEnabled
        }

        property real blurMaskX: {
            const marginLeft = rect.marginEnabled ? rect.marginLeft : 0
            if (panelElement.floating && horizontal) {
                if (floatigness > 0) {
                    return marginLeft
                } else {
                    return (panelElement.width - rect.width) / 2
                }
            } else {
                return marginLeft
            }
        }

        property real blurMaskY: {
            const marginTop = rect.marginEnabled ? rect.marginTop : 0
            if (panelElement.floating && !horizontal) {
                if (floatigness > 0) {
                    return marginTop
                } else {
                    return (panelElement.height - rect.height) / 2
                }
            } else {
                return marginTop
            }
        }

        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: {
                position = Utils.getGlobalPosition(rect, panelElement)
            }
        }

        property var position: Utils.getGlobalPosition(rect, panelElement)
        property var positionX: position.x
        property var positionY: position.y
        property var fl: floatigness

        ColumnLayout {
            spacing: 0
            anchors.bottom: isPanel ? parent.bottom : undefined
            visible: debug
            Label {
                text: maskIndex
                font.pixelSize: 8
                Rectangle {
                    anchors.fill: parent
                    color: "black"
                    z:-1
                }
            }
            Label {
                text: parseInt(position.x)+","+parseInt(position.y)
                font.pixelSize: 8
                Rectangle {
                    anchors.fill: parent
                    color: "black"
                    z:-1
                }
            }
        }

        Label {
            text: parseInt(rect.width)+"x"+parseInt(rect.height)
            font.pixelSize: 8
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            visible: debug
            Rectangle {
                anchors.fill: parent
                color: "black"
                z:-1
            }
        }

        onXChanged: {
            updateMask()
        }

        onYChanged: {
            updateMask()
        }

        onWidthChanged: {
            updateMask()
        }

        onHeightChanged: {
            updateMask()
        }

        onBlurMaskXChanged: {
            updateMask()
        }

        onBlurMaskYChanged: {
            updateMask()
        }

        onFlChanged: {
            position = Utils.getGlobalPosition(rect, panelElement)
        }

        onPositionXChanged: {
            updateMask()
        }

        onPositionYChanged: {
            updateMask()
        }

        // TODO find where does 16 and 8 come from instead of blindly hardcoding them
        property real moveX: {
            let m = horizontal ? 0 : (panelState.floating ? 16 : 0)
            return floatigness > 0 ? 8 : m
        }

        property real moveY: {
            let m = horizontal ? (panelState.floating ? 16 : 0) : 0
            return floatigness > 0 ? 8 : m
        }

        // TODO: per corner radius
        function updateMask() {
            Qt.callLater(function() {
                if (panelColorizer === null || !blurBehind) return
                panelColorizer.updatePanelMask(
                    maskIndex,
                    rect,
                    radiusEnabled ? cfg.radius.corner.topLeft : 0,
                    Qt.point(rect.position.x-moveX, rect.position.y-moveY)
                )
            })
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
        delayed: true
    }

    Binding {
        target: panelLayoutContainer
        property: "anchors.rightMargin"
        value: panelSettings.padding.side.right
        when: fixedSidePaddingEnabled
        delayed: true
    }

    Binding {
        target: panelLayoutContainer
        property: "anchors.topMargin"
        value: panelSettings.padding.side.top
        when: fixedSidePaddingEnabled
        delayed: true
    }

    Binding {
        target: panelLayoutContainer
        property: "anchors.bottomMargin"
        value: panelSettings.padding.side.bottom
        when: fixedSidePaddingEnabled
        delayed: true
    }

    // TODO: should I just remove option for blur from per-widget settings?
    // IMO doesn't make much sense to have only some widgets blurred...
    Binding {
        target: panelElement
        property: "panelMask"
        value: blurMask
        when: (panelColorizer !== null && blurMask && panelColorizer?.hasRegions
                && (panelBgItem?.blurBehind || widgetSettings?.blurBehind || trayWidgetSettings?.blurBehind)
            )
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

    function switchPreset() {
        let nextPreset = Utils.getPresetName(panelState, presetAutoloading)
        if (!nextPreset) return
        applyPreset(nextPreset)
    }

    function applyPreset(presetName) {
        console.log("Reading preset:", presetName);
        lastPreset = presetName
        runCommand.run("cat '" + presetsDir + presetName+"'")
    }

    onPanelStateChanged: {
        if (!isEnabled) return
        switchPreset()
    }

    onPresetAutoloadingChanged: {
        if (!isEnabled) return
        switchPreset()
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
        try {
            panelColorizer = Qt.createQmlObject("import org.kde.plasma.panelcolorizer 1.0; PanelColorizer { id: panelColorizer }", main)
            console.error("QML Plugin org.kde.plasma.panelcolorizer loaded");
        } catch (err) {
            console.error("QML Plugin org.kde.plasma.panelcolorizer not found");
        }
    }

    TasksModel {
        id: tasksModel
        screenGeometry: Plasmoid.containment.screenGeometry
    }

    RunCommand {
        id: runCommand
    }

    Connections {
        target: runCommand
        function onExited(cmd, exitCode, exitStatus, stdout, stderr, liveUpdate) {
            if (exitCode!==0) return
            presetContent = stdout.trim().split("\n")
            Utils.loadPreset(presetContent, plasmoid.configuration, Globals.ignoredConfigs, Globals.defaultConfig, true)
            plasmoid.configuration.lastPreset = lastPreset
            plasmoid.configuration.writeConfig();
        }
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

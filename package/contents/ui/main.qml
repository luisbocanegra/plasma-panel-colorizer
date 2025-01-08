import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
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
    property int panelLayoutCount: panelLayout?.children?.length || 0
    property int trayGridViewCount: trayGridView?.count || 0
    property int trayGridViewCountOld: 0
    property var panelPrefixes: ["north","south","west","east"]
    property var panelPosition: {
        var location
        var screen = main.screen
        switch (plasmoid.location) {
            case PlasmaCore.Types.TopEdge:
            location = "top"
            break
            case PlasmaCore.Types.BottomEdge:
            location = "bottom"
            break
            case PlasmaCore.Types.LeftEdge:
            location = "left"
            break
            case PlasmaCore.Types.RightEdge:
            location = "right"
            break
        }
        return { "screen": screen, "location": location }
    }
    property bool horizontal: Plasmoid.formFactor === PlasmaCore.Types.Horizontal
    property bool editMode: Plasmoid.containment.corona?.editMode ?? false
    property bool onDesktop: plasmoid.location === PlasmaCore.Types.Floating
    property string iconName: !onDesktop ? "icon" : "error"
    property string icon: Qt.resolvedUrl("../icons/" + iconName + ".svg").toString().replace("file://", "")
    property bool hideWidget: plasmoid.configuration.hideWidget
    property bool fixedSidePaddingEnabled: isEnabled && panelSettings.padding.enabled
    property bool isEnabled: plasmoid.configuration.isEnabled
    property bool nativePanelBackgroundEnabled: (isEnabled ? cfg.nativePanelBackground.enabled : true) || doPanelClickFix
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
                    StandardPaths.HomeLocation).toString().substring(7) + "/.config/panel-colorizer/presets/"
    property var presetContent: ""
    property var panelState: {
        "maximized": tasksModel.maximizedExists,
        "touchingWindow": !panelElement ? false : Boolean(panelElement.touchingWindow),
        "floating": !panelElement ? false : Boolean(panelElement.floatingness)
    }
    property var widgetsDoingBlur: ({})
    property var trayItemsDoingBlur: ({})

    property var anyWidgetDoingBlur: {
        return Object.values(widgetsDoingBlur).some(state => state)
    }
    property var anyTrayItemDoingBlur: {
        return Object.values(trayItemsDoingBlur).some(state => state)
    }

    property var unifiedBackgroundTracker: []
    property bool doPanelClickFix: false
    property bool doPanelLengthFix: false

    property var cfg: {
        try {
            return JSON.parse(plasmoid.configuration.globalSettings)
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
    property var configurationOverrides: {
        try {
            return JSON.parse(plasmoid.configuration.configurationOverrides)
        } catch (e) {
            console.error(e, e.stack)
            return {}
        }
    }
    property var forceForegroundColor: {
        try {
            return JSON.parse(plasmoid.configuration.forceForegroundColor)
        } catch (e) {
            console.error(e, e.stack)
            return {}
        }
    }
    property var widgetSettings: cfg.widgets
    property var widgetsSpacing: {
        if (true) {
            return Utils.makeEven(widgetSettings?.spacing ?? 4)
        } else {
            return widgetSettings?.spacing ?? 4
        }
    }
    property var panelSettings: cfg.panel
    property var stockPanelSettings: cfg.stockPanelSettings
    property var trayWidgetSettings: cfg.trayWidgets
    property var unifiedBackgroundSettings: Utils.clearOldWidgetConfig(cfg.unifiedBackground)
    property var forceRecolorList: Utils.clearOldWidgetConfig(forceForegroundColor?.widgets ?? [])
    property int forceRecolorInterval: forceForegroundColor?.reloadInterval ?? 0
    property int forceRecolorCount: forceRecolorList.length
    property bool requiresRefresh: forceRecolorList.some(w => w.reload)
    property var panelColorizer: null
    property var blurMask: panelColorizer?.mask ?? null
    property var floatigness: panelElement?.floatingness ?? 0
    property var panelWidth: panelElement?.width ?? 0
    property var panelHeight: panelElement?.height ?? 0
    property bool debug: plasmoid.configuration.enableDebug
    signal recolorCountChanged()
    signal refreshNeeded()
    signal updateUnified()
    signal updateMasks()

    onStockPanelSettingsChanged: {
        Qt.callLater(function() {
            console.error(JSON.stringify(stockPanelSettings))
            let script = Utils.setPanelModeScript(panelPosition, stockPanelSettings)
            Utils.evaluateScript(script)
        })
    }

    onForceRecolorCountChanged: {
        // console.error("onForceRecolorCountChanged ->", forceRecolorCount)
        recolorCountChanged()
    }

    // HACK: temporary enable panel mask on geometry change
    // to fix broken clickable area
    // https://github.com/luisbocanegra/plasma-panel-colorizer/issues/100
    // maybe also related to https://bugs.kde.org/show_bug.cgi?id=489086

    function runPanelClickFix() {
        doPanelClickFix = true
        doPanelClickFix = false
    }

    onPanelWidthChanged: {
        runPanelClickFix()
        updateMasks()
    }

    onPanelHeightChanged: {
        runPanelClickFix()
        updateMasks()
    }

    onFloatignessChanged: {
        updateMasks()
    }

    function getColor(colorCfg, targetIndex, parentColor, itemType, kirigamiColorItem) {
        let newColor = "transparent"
        switch (colorCfg.sourceType) {
            case 0:
                newColor = Utils.rgbToQtColor(Utils.hexToRgb(colorCfg.custom))
            break
            case 1:
                newColor = kirigamiColorItem.Kirigami.Theme[colorCfg.systemColor]
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

    function applyFgColor(element, newColor, fgColorCfg, depth, wRecolorCfg) {
        let count = 0;
        let maxDepth = depth
        const forceMask = wRecolorCfg?.method?.mask ?? false
        const forceEffect = wRecolorCfg?.method?.multiEffect ?? false

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
                const result = applyFgColor(child, newColor, fgColorCfg, depth + 1, wRecolorCfg)
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
        // use an exra id so we can track the panel and items in tray separately
        property int maskIndex: {
            if (isPanel) return 0
            else {
                return (inTray ? (panelLayoutCount -1 + targetIndex) : targetIndex) +1
            }
        }
        property int itemType
        property bool isPanel: itemType === Enums.ItemType.PanelBgItem
        property bool isWidget: itemType === Enums.ItemType.WidgetItem
        property bool isTray: itemType === Enums.ItemType.TrayItem
        property bool isTrayArrow: itemType === Enums.ItemType.TrayArrow
        property bool inTray: isTray || isTrayArrow
        property bool luisbocanegraPanelColorizerBgManaged: true
        property var widgetProperties: isTrayArrow ? { "id":-1, "name": "org.kde.plasma.systemtray.expand" } :
            Utils.getWidgetNameAndId(target)
        property string widgetName: widgetProperties.name
        property int widgetId: widgetProperties.id
        property var wRecolorCfg: Utils.getForceFgWidgetConfig(widgetId, widgetName, forceRecolorList)
        property bool requiresRefresh: wRecolorCfg?.reload ?? false
        // 0: default | 1: start | 2: end
        property var wUnifyCfg: Utils.getForceFgWidgetConfig(widgetId, widgetName, unifiedBackgroundSettings)
        property int unifySection: wUnifyCfg?.unifyBgType ?? 0

        // 0: default | 1: start | 2: middle | 3: end
        property int unifyBgType: 0
        onUnifySectionChanged: {
            Qt.callLater(function () {
                main.updateUnified()
            })
        }

        function updateUnifyType() {
            if (inTray) return
            unifiedBackgroundTracker[targetIndex] = unifySection
            // FIXME: dragging a widget on the panel will trigger the following, but why??
            // Error: Invalid write to global property "unifyBgType"
            try {
                unifyBgType = Utils.getUnifyBgType(unifiedBackgroundTracker, targetIndex)
            } catch(e) {
                // hmmm
            }
        }

        property var itemConfig: Utils.getItemCfg(itemType, widgetName, widgetId, main.cfg, configurationOverrides)
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
        property int topLeftRadius: !radiusEnabled || unifyBgType === 2 || unifyBgType === 3
            ? 0
            : cfg.radius.corner.topLeft ?? 0
        property int topRightRadius: !radiusEnabled ||
            (horizontal && (unifyBgType === 1 || unifyBgType === 2)) ||
            (!horizontal && (unifyBgType === 2 || unifyBgType === 3))
            ? 0
            : cfg.radius.corner.topRight ?? 0

        property int bottomLeftRadius: !radiusEnabled ||
            (horizontal && (unifyBgType === 2 || unifyBgType === 3)) ||
            (!horizontal && (unifyBgType === 1 || unifyBgType === 2))
            ? 0
            : cfg.radius.corner.bottomLeft ?? 0

        property int bottomRightRadius: !radiusEnabled ||
            unifyBgType === 1 || unifyBgType === 2 ||
            (!horizontal && (unifyBgType === 1 || unifyBgType === 2))
            ? 0
            : cfg.radius.corner.bottomRight ?? 0

        property bool marginEnabled: cfg.margin.enabled && cfgEnabled
        property bool borderEnabled: cfg.border.enabled && cfgEnabled
        property bool bgShadowEnabled: cfg.shadow.background.enabled && cfgEnabled
        property var bgShadow: cfg.shadow.background
        property bool fgShadowEnabled: cfg.shadow.foreground.enabled && cfgEnabled
        property var fgShadow: cfg.shadow.foreground
        property bool blurBehind: {
            return (isPanel && !anyWidgetDoingBlur && !anyTrayItemDoingBlur)
                || (isWidget)
                || (inTray && !trayWidgetBgItem?.blurBehind)
                ? cfg.blurBehind
                : false
        }
        property string fgColor: {
            if (!fgEnabled && !inTray) {
                return Kirigami.Theme.textColor
            } else if ((!fgEnabled && inTray && widgetEnabled)) {
                return trayWidgetBgItem.fgColor
            } else if (separateTray || cfgOverride) {
                return getColor(rect.fgColorCfg, targetIndex, rect.color, itemType, fgColorHolder)
            } else if (inTray) {
                return getColor(widgetSettings.foregroundColor, trayIndex, rect.color, itemType, fgColorHolder)
            } else {
                return getColor(widgetSettings.foregroundColor, targetIndex, rect.color, itemType, fgColorHolder)
            }
        }
        Rectangle {
            id: fgColorHolder
            height: 6
            width: height
            visible: false
            radius: height / 2
            color: fgColor
            anchors.right: parent.right
            Kirigami.Theme.colorSet: Kirigami.Theme[fgColorCfg.systemColorSet]
        }
        Rectangle {
            id: bgColorHolder
            height: 6
            width: height
            visible: false
            radius: height / 2
            color: fgColor
            anchors.right: parent.right
            Kirigami.Theme.colorSet: Kirigami.Theme[bgColorCfg.systemColorSet]
        }
        // Label {
        //     id: debugLabel
        //     text: targetIndex+","+trayIndex //maxDepth+","+itemCount
        //     font.pixelSize: 8
        // }
        corners {
            topLeftRadius: topLeftRadius
            topRightRadius: topRightRadius
            bottomLeftRadius: bottomLeftRadius
            bottomRightRadius: bottomRightRadius
        }

        color: {
            if (bgEnabled) {
                return getColor(bgColorCfg, targetIndex, null, itemType, bgColorHolder)
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
                if (!fgEnabled) return
                if (widgetName === "org.kde.plasma.systemtray" && separateTray) return
                const result = applyFgColor(target, fgColor, fgColorCfg, 0, wRecolorCfg)
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
            main.updateUnified.connect(updateUnifyType)
            main.updateMasks.connect(updateMask)
            recolorTimer.start()
        }

        height: isTray ? target.height : parent.height
        width: isTray ? target.width : parent.width
        anchors.centerIn: (isTray || isTrayArrow) ? parent : undefined
        anchors.fill: (isPanel ||isTray || isTrayArrow) ? parent : undefined

        property int extraLSpacing: ((unifyBgType === 2 || unifyBgType === 3) && horizontal ? widgetsSpacing : 0) / 2
        property int extraRSpacing: ((unifyBgType === 1 || unifyBgType === 2) && horizontal ? widgetsSpacing : 0) / 2
        property int extraTSpacing: ((unifyBgType === 2 || unifyBgType === 3) && !horizontal ? widgetsSpacing : 0) / 2
        property int extraBSpacing: ((unifyBgType === 1 || unifyBgType === 2) && !horizontal ? widgetsSpacing : 0) / 2

        property int marginLeft: (marginEnabled ? cfg.margin.side.left : 0)
            + extraLSpacing
        property int marginRight: (marginEnabled ? cfg.margin.side.right : 0)
            + extraRSpacing
        property int horizontalWidth: marginLeft + marginRight

        property int marginTop: (marginEnabled ? cfg.margin.side.top : 0)
            + extraTSpacing
        property int marginBottom: (marginEnabled ? cfg.margin.side.bottom : 0)
            + extraBSpacing
        property int verticalWidth: marginTop + marginBottom

        Binding {
            target: rect
            property: "x"
            value: -marginLeft
            when: isWidget && horizontal
            delayed: true
        }

        Binding {
            target: rect
            property: "y"
            value: -marginTop
            when: isWidget && !horizontal
            delayed: true
        }

        Binding {
            target: rect
            property: "width"
            value: parent.width + horizontalWidth
            when: isWidget
            delayed: true
        }

        Binding {
            target: rect
            property: "height"
            value: parent.height + verticalWidth
            when: isWidget && !horizontal
            delayed: true
        }

        Binding {
            target: rect.target
            property: "Layout.leftMargin"
            value: marginLeft - extraLSpacing
            when: isWidget && (marginEnabled || extraLSpacing !== 0)
            delayed: true
        }

        Binding {
            target: rect.target
            property: "Layout.rightMargin"
            value: marginRight - extraRSpacing
            when: isWidget && (marginEnabled || extraRSpacing !== 0)
            delayed: true
        }

        Binding {
            target: rect.target
            property: "Layout.topMargin"
            value: marginTop - extraTSpacing
            when: isWidget && (marginEnabled || extraTSpacing !== 0)
            delayed: true
        }

        Binding {
            target: rect.target
            property: "Layout.bottomMargin"
            value: marginBottom - extraBSpacing
            when: isWidget && (marginEnabled || extraBSpacing !== 0)
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
            visible: borderEnabled && Math.min(rect.height, rect.width) > 1
            property var borderColorCfg: cfg.border.color
            Kirigami.Theme.colorSet: Kirigami.Theme[borderColorCfg.systemColorSet]
            property color borderColor: {
                return getColor(borderColorCfg, targetIndex, rect.color, itemType, borderRec)
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
                id: normalBorder
                anchors.fill: parent
                color: "transparent"
                // the mask source needs to be hidden by default
                visible: false
                border {
                    color: borderRec.borderColor
                    width: !cfg.border.customSides ? cfg.border.width || -1 : 0
                }
                corners {
                    topLeftRadius: topLeftRadius
                    topRightRadius: topRightRadius
                    bottomLeftRadius: bottomLeftRadius
                    bottomRightRadius: bottomRightRadius
                }
            }

            // Mask to hide one or two borders for unified backgrounds
            MultiEffect {
                source: normalBorder
                anchors.fill: normalBorder
                maskEnabled: true
                maskSource: rightBorderMask
                maskInverted: true
            }
            Item {
                id: rightBorderMask
                layer.enabled: true
                visible: false
                width: borderRec.width
                height: borderRec.height
                Rectangle {
                    id: rect1
                    width: horizontal ? cfg.border.width : borderRec.width - (cfg.border.width * 2)
                    height: horizontal ? borderRec.height - (cfg.border.width * 2) : cfg.border.width
                    color: (unifyBgType === 1 || unifyBgType === 2) ? "black" : "transparent"
                    anchors.right: horizontal ? parent.right : undefined
                    anchors.bottom: !horizontal ? parent.bottom : undefined
                    anchors.verticalCenter: horizontal ? parent.verticalCenter : undefined
                    anchors.horizontalCenter: !horizontal ? parent.horizontalCenter : undefined

                }
                Rectangle {
                    id: rect2
                    width: horizontal ? cfg.border.width : borderRec.width - (cfg.border.width * 2)
                    height: horizontal ? borderRec.height - (cfg.border.width * 2) : cfg.border.width
                    color: (unifyBgType === 2 || unifyBgType === 3) ? "black" : "transparent"
                    anchors.left: horizontal ? parent.left : undefined
                    anchors.top: !horizontal ? parent.top : undefined
                    anchors.verticalCenter: horizontal ? parent.verticalCenter : undefined
                    anchors.horizontalCenter: !horizontal ? parent.horizontalCenter : undefined
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
                            topLeftRadius: topLeftRadius
                            topRightRadius: topRightRadius
                            bottomLeftRadius: bottomLeftRadius
                            bottomRightRadius: bottomRightRadius
                        }
                    }
                }
            }
        }

        shadow {
            property var shadowColorCfg: bgShadow.color
            Kirigami.Theme.colorSet: Kirigami.Theme[shadowColorCfg.systemColorSet]
            size: (bgShadowEnabled && Math.min(rect.height, rect.width) > 1) ? bgShadow.size : 0
            color: {
                return getColor(shadowColorCfg, targetIndex, rect.color, itemType, rect.shadow)
            }
            xOffset: bgShadow.xOffset
            yOffset: bgShadow.yOffset
        }

        // paddingRect to hide the shadow in one or two sides Qt.rect(left,top,right,bottom)
        layer.enabled: bgShadowEnabled && unifyBgType !== 0
        // how much padding are we hiding
        property int ps: Math.max(bgShadow.size, bgShadow.xOffset, bgShadow.yOffset)
        layer.effect: MultiEffect {
            autoPaddingEnabled: true
            paddingRect: {
                if (unifyBgType === 1) {
                    return horizontal ? Qt.rect(ps,ps,0,ps) : Qt.rect(ps,ps,ps,0)
                }
                if (unifyBgType === 2) {
                    return horizontal ? Qt.rect(0,ps,0,ps) : Qt.rect(ps,0,ps,0)
                }
                if (unifyBgType === 3) {
                    return horizontal ? Qt.rect(0,ps,ps,ps) : Qt.rect(ps,0,ps,ps)
                }
            }
        }

        DropShadow {
            anchors.fill: parent
            // we need to compensate because we now space widgets with margins
            // instead of the layout spacing for the unified background feature
            // can't anchor to center because we can also add different margin
            // on each side, the shadow position is off otherwise
            anchors.leftMargin: horizontal ? rect.marginLeft : undefined
            anchors.rightMargin: horizontal ? rect.marginRight : undefined
            anchors.topMargin: horizontal ? undefined : rect.marginTop
            anchors.bottomMargin: horizontal ? undefined : rect.marginBottom
            id: dropShadow
            property var shadowColorCfg: fgShadow.color
            Kirigami.Theme.colorSet: Kirigami.Theme[shadowColorCfg.systemColorSet]
            horizontalOffset: fgShadow.xOffset
            verticalOffset: fgShadow.yOffset
            radius: fgShadowEnabled ? fgShadow.size : 0
            samples: radius * 2 + 1
            spread: 0.35
            color: {
                return getColor(shadowColorCfg, targetIndex, rect.color, itemType, dropShadow)
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
                    return (panelElement.width - borderRec.width) / 2
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
                    return (panelElement.height - borderRec.height) / 2
                }
            } else {
                return marginTop
            }
        }

        property var position: Qt.point(0,0)
        property var positionX: position.x
        property var positionY: position.y

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
                    opacity: 0.5
                }
            }
            Label {
                text: unifySection+","+unifyBgType//blurBehind+","+anyWidgetDoingBlur //parseInt(position.x)+","+parseInt(position.y)
                font.pixelSize: 8
                Rectangle {
                    anchors.fill: parent
                    color: "black"
                    z:-1
                    opacity: 0.5
                }
            }
        }

        Label {
            text: parseInt(borderRec.width)+"x"+parseInt(borderRec.height)
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
            // console.error("onXChanged()")
            updateMask()
        }

        onYChanged: {
            // console.error("onYChanged()")
            updateMask()
        }

        onWidthChanged: {
            // console.error("onWidthChanged()")
            main.updateMasks()
        }

        onHeightChanged: {
            // console.error("onHeightChanged()")
            main.updateMasks()
        }

        onBlurMaskXChanged: {
            // console.error("onBlurMaskXChanged()")
            updateMask()
        }

        onBlurMaskYChanged: {
            // console.error("onBlurMaskYChanged()")
            updateMask()
        }

        // TODO find where does 16 and 8 come from instead of blindly hardcoding them
        property real moveX: {
            let m = horizontal ? 0 : (panelElement?.floating && plasmoid.location === PlasmaCore.Types.RightEdge ? 16 : 0)
            return floatigness > 0 ? 8 : m
        }

        property real moveY: {
            let m = horizontal ? (panelElement?.floating && plasmoid.location === PlasmaCore.Types.BottomEdge ? 16 : 0) : 0
            return floatigness > 0 ? 8 : m
        }

        onVisibleChanged: {
            main.updateUnified()
            updateMask()
        }

        onBlurBehindChanged: {
            if (isWidget) {
                widgetsDoingBlur[maskIndex] = blurBehind
                anyWidgetDoingBlur = Object.values(widgetsDoingBlur).some(state => state)
            } else if (inTray) {
                trayItemsDoingBlur[maskIndex] = blurBehind
                anyTrayItemDoingBlur = Object.values(trayItemsDoingBlur).some(state => state)
            }
            updateMask()
        }

        function updateMask() {
            if (panelColorizer === null || !borderRec) return
            // console.error("updateMask()", widgetName)
            position = Utils.getGlobalPosition(borderRec, panelElement)
            panelColorizer.updatePanelMask(
                maskIndex,
                borderRec,
                rect.corners.topLeftRadius,
                rect.corners.topRightRadius,
                rect.corners.bottomLeftRadius,
                rect.corners.bottomRightRadius,
                Qt.point(rect.positionX-moveX, rect.positionY-moveY),
                5,
                visible && blurBehind
            )
        }
    }

    // Search the actual gridLayout of the panel
    property GridLayout panelLayout: {
        let candidate = main.parent;
        while (candidate) {
            if (candidate instanceof GridLayout) {
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

    // TODO: should we remove option for blur from per-widget settings?
    // IMO doesn't make much sense to have only some widgets blurred...
    Binding {
        target: panelElement
        property: "panelMask"
        value: blurMask
        when: (panelColorizer !== null && blurMask && panelColorizer?.hasRegions
                && (panelSettings.blurBehind || anyWidgetDoingBlur || anyTrayItemDoingBlur)
            )
    }

    // The panel doesn't like having its spacings set to 0
    // while adding/dragging widgets in edit mode, so temporary restore them
    Binding {
        target: panelLayout
        property: "columnSpacing"
        value: widgetsSpacing
        when: !editMode
    }

    Binding {
        target: panelLayout
        property: "rowSpacing"
        value: widgetsSpacing
        when: !editMode
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

    // HACK: change panelLayout spacing on startup to trigger a length reload
    // BUG: https://bugs.kde.org/show_bug.cgi?id=489086
    // https://github.com/luisbocanegra/plasma-panel-colorizer/issues/100

    onPanelLayoutChanged: {
        if (!panelLayout) return
        panelFixTimer.start()
    }

    Timer {
        id: panelFixTimer
        repeat: false
        interval: 1000
        onTriggered: {
            doPanelLengthFix = true
            doPanelLengthFix = false
        }
    }

    Binding {
        target: panelLayout
        property: "columnSpacing"
        value: 0
        when: doPanelLengthFix
    }

    Binding {
        target: panelLayout
        property: "rowSpacing"
        value: 0
        when: doPanelLengthFix
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
        let nextPresetDir = Utils.getPresetName(panelState, presetAutoloading)
        if (!nextPresetDir) return
        applyPreset(nextPresetDir)
    }

    function applyPreset(presetDir) {
        console.log("Reading preset:", presetDir);
        lastPreset = presetDir
        runCommand.run("cat '" + presetDir + "/settings.json'")
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

    PlasmaCore.Action {
        id: configureAction
        text: plasmoid.internalAction("configure").text
        icon.name: 'configure'
        onTriggered: plasmoid.internalAction("configure").trigger()
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
            if (child.applet.plasmoid.pluginName !== "luisbocanegra.panel.colorizer") {
                child.applet.plasmoid.contextualActions.push(configureAction)
            }
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
            plasmoid.configuration.globalSettings = Utils.stringify(config)
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
        filterByActive: presetAutoloading.maximizedFilterByActive ?? false
    }

    RunCommand {
        id: runCommand
    }

    Connections {
        target: runCommand
        function onExited(cmd, exitCode, exitStatus, stdout, stderr, liveUpdate) {
            if (exitCode!==0) return
            try {
                presetContent = JSON.parse(stdout.trim())
            } catch (e) {
                return
            }
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

    compactRepresentation: CompactRepresentation {
        icon: main.icon
    }

    fullRepresentation: Item {
        Layout.minimumWidth: main.Kirigami.Units.gridUnit * 10
        Layout.minimumHeight: main.Kirigami.Units.gridUnit * 10
        Layout.maximumWidth: main.Kirigami.Units.gridUnit * 10
        Layout.maximumHeight: main.Kirigami.Units.gridUnit * 10

        ColumnLayout {
            id: column
            anchors.fill: parent
            Kirigami.Icon {
                Layout.fillWidth: true
                Layout.preferredHeight: 64
                source: main.icon
                isMask: true
                color: Kirigami.Theme.negativeTextColor
            }
            PlasmaComponents.Label {
                text: "<font color='"+Kirigami.Theme.neutralTextColor+"'>Panel not found, this widget must be child of a panel</font>"
                Layout.fillWidth: true
                wrapMode: Text.Wrap
            }
        }
    }

    toolTipSubText: onDesktop ? "<font color='"+Kirigami.Theme.neutralTextColor+"'>Panel not found, this widget must be child of a panel</font>" : Plasmoid.metaData.description
    toolTipTextFormat: Text.RichText

    Plasmoid.status: (editMode || !hideWidget) ?
        PlasmaCore.Types.ActiveStatus :
        PlasmaCore.Types.HiddenStatus

    Plasmoid.contextualActions: [
        PlasmaCore.Action {
            text: i18n("Hide widget (visible in panel Edit Mode)")
            checkable: true
            icon.name: "visibility-symbolic"
            checked: Plasmoid.configuration.hideWidget
            onTriggered: checked => {
                plasmoid.configuration.hideWidget = checked;
                plasmoid.configuration.writeConfig();
            }
        }
    ]
}

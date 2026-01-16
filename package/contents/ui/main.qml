pragma ComponentBehavior: Bound

import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.plasmoid
import org.kde.taskmanager as TaskManager
import QtQuick.Effects
import Qt5Compat.GraphicalEffects

import "code/utils.js" as Utils
import "code/globals.js" as Globals
import "code/enum.js" as Enum
import "code/version.js" as VersionUtil
import "code/statusNotifierItemIconRules.js" as SNIIconRules

PlasmoidItem {
    id: main
    property int panelLayoutCount: panelLayout?.children?.length || 0
    property int trayGridViewCount: trayGridView?.count || 0
    property int trayGridViewCountOld: 0
    property var panelPosition: {
        var location;
        var screen = main.screen;
        switch (plasmoid.location) {
        case PlasmaCore.Types.TopEdge:
            location = "top";
            break;
        case PlasmaCore.Types.BottomEdge:
            location = "bottom";
            break;
        case PlasmaCore.Types.LeftEdge:
            location = "left";
            break;
        case PlasmaCore.Types.RightEdge:
            location = "right";
            break;
        }
        return {
            screen,
            location
        };
    }
    property bool horizontal: Plasmoid.formFactor === PlasmaCore.Types.Horizontal
    property bool editMode: Plasmoid.containment.corona?.editMode ?? false
    property bool onDesktop: plasmoid.location === PlasmaCore.Types.Floating
    property bool isWayland: Qt.platform.pluginName.includes("wayland")
    property string iconName: (onDesktop || !runningLatest) ? "error" : "icon"
    property string icon: Qt.resolvedUrl("../icons/" + iconName + ".svg").toString().replace("file://", "")
    property bool hideWidget: plasmoid.configuration.hideWidget
    property bool fixedSidePaddingEnabled: isEnabled && panelBgItem !== null && panelBgItem.cfg.padding.enabled
    property bool floatingDialogs: main.isEnabled ? cfg.nativePanel.floatingDialogs : false
    property bool floatingDialogsAllowOverride: main.isEnabled ? cfg.nativePanel.floatingDialogsAllowOverride : false
    property bool fillAreaOnDeFloat: main.isEnabled ? cfg.nativePanel.fillAreaOnDeFloat : false
    property bool isEnabled: plasmoid.configuration.isEnabled
    property bool nativePanelBackgroundEnabled: (isEnabled ? cfg.nativePanel.background.enabled : true) || doPanelClickFix
    property real nativePanelBackgroundOpacity: isEnabled ? cfg.nativePanel.background.opacity : 1.0
    property bool nativePanelBackgroundShadowEnabled: isEnabled ? cfg.nativePanel.background.shadow : true
    property bool configureFromAllWidgets: Plasmoid.configuration.configureFromAllWidgets
    property var panelWidgets: []
    property real trayItemThikness: 20
    // keep track of these to allow others to follow their color
    property QtObject panelBgItem
    property QtObject trayWidgetBgItem
    property string lastPreset
    property var presetContent: ""
    property bool animatePropertyChanges: plasmoid.configuration.animatePropertyChanges
    property int animationDuration: plasmoid.configuration.animationDuration
    property int animationEasingType: Easing.OutCubic
    property var panelState: {
        "fullscreenWindow": tasksModel.fullscreenExists,
        "maximized": tasksModel.maximizedExists,
        "visibleWindows": tasksModel.visibleExists,
        "touchingWindow": panelElement && panelElement.touchingWindow,
        "floating": panelElement && panelElement.floatingness > 0,
        "activity": activityInfo.currentActivity
    }
    property var widgetsDoingBlur: ({})
    property var trayItemsDoingBlur: ({})

    property var anyWidgetDoingBlur: {
        return Object.values(widgetsDoingBlur).some(state => state);
    }
    property var anyTrayItemDoingBlur: {
        return Object.values(trayItemsDoingBlur).some(state => state);
    }

    property var unifiedBackgroundTracker: []
    property var unifiedBackgroundFinal: []
    property bool doPanelClickFix: false
    property bool doPanelLengthFix: false

    property var cfg: {
        let globalSettings;
        try {
            globalSettings = JSON.parse(plasmoid.configuration.globalSettings);
        } catch (e) {
            console.error(e, e.stack);
            globalSettings = Globals.defaultConfig;
        }

        Utils.fixGlobalSettingsV3(globalSettings);
        const config = Utils.mergeConfigs(Globals.defaultConfig, globalSettings);
        const configStr = JSON.stringify(config);
        if (plasmoid.configuration.globalSettings !== configStr) {
            plasmoid.configuration.globalSettings = configStr;
            plasmoid.configuration.writeConfig();
        }
        return config;
    }
    property var presetAutoloading: {
        try {
            return JSON.parse(plasmoid.configuration.presetAutoloading);
        } catch (e) {
            console.error(e, e.stack);
            return {};
        }
    }
    property var configurationOverrides: {
        let globalOverrides = {};
        try {
            globalOverrides = JSON.parse(plasmoid.configuration.configurationOverrides);
        } catch (e) {
            console.error(e, e.stack);
        }
        if (!("overrides" in globalOverrides)) {
            globalOverrides.overrides = {};
        }
        Utils.fixConfigurationOverridesV3(globalOverrides.overrides);
        globalOverrides = Utils.mergeConfigs(Globals.defaultConfig.configurationOverrides, globalOverrides);
        const configStr = JSON.stringify(globalOverrides);
        if (plasmoid.configuration.configurationOverrides !== configStr) {
            plasmoid.configuration.configurationOverrides = configStr;
            plasmoid.configuration.writeConfig();
        }
        return globalOverrides;
    }
    property var forceForegroundColor: {
        try {
            return JSON.parse(plasmoid.configuration.forceForegroundColor);
        } catch (e) {
            console.error(e, e.stack);
            return {};
        }
    }
    property var panelSettings: cfg.panel
    property var widgetSettings: cfg.widgets
    property var trayWidgetSettings: cfg.trayWidgets
    property var stockPanelSettings: cfg.stockPanelSettings
    property var widgetsSpacing: {
        if (true) {
            return Utils.makeEven(widgetSettings?.normal?.spacing ?? 4);
        } else {
            return widgetSettings?.normal?.spacing ?? 4;
        }
    }
    property var unifiedBackgroundSettings: Utils.fixV2UnifiedWidgetConfig(Utils.clearOldWidgetConfig(cfg.unifiedBackground))
    onUnifiedBackgroundSettingsChanged: {
        // fix config from v2
        if (plasmoid.configuration.globalSettings !== JSON.stringify(cfg)) {
            plasmoid.configuration.globalSettings = JSON.stringify(cfg);
            plasmoid.configuration.writeConfig();
        }
    }
    property var forceRecolorList: Utils.clearOldWidgetConfig(forceForegroundColor?.widgets ?? [])
    property int forceRecolorInterval: forceForegroundColor?.reloadInterval ?? 0
    property int forceRecolorCount: forceRecolorList.length
    property bool requiresRefresh: forceRecolorList.some(w => w.reload)
    property var panelColorizer: null
    property var blurMask: panelColorizer?.mask ?? null
    property var floatigness: panelElement?.floatingness ?? 0
    property bool panelIsFloating: (panelElement?.floating ?? false) && (floatigness !== 0)
    property var panelWidth: panelElement?.width ?? 0
    property var panelHeight: panelElement?.height ?? 0
    property bool debug: plasmoid.configuration.enableDebug
    property var plasmaVersion: new VersionUtil.Version("999.999.999") // to assume latest
    property var editModeGrid: JSON.parse(plasmoid.configuration.editModeGridSettings)
    property bool showEditingGrid: (editModeGrid?.enabled ?? false) && Plasmoid.userConfiguring
    property bool logSystemTrayIconChanges: plasmoid.configuration.logSystemTrayIconChanges
    property bool systemTrayIconsReplacementEnabled: plasmoid.configuration.systemTrayIconsReplacementEnabled
    property var systemTrayIconUserReplacements: {
        let replacements = [];
        try {
            replacements = JSON.parse(plasmoid.configuration.systemTrayIconUserReplacements);
        } catch (e) {
            console.error(e.message, "\n", e.stack);
        }
        return replacements;
    }
    signal recolorCountChanged
    signal refreshNeeded
    signal updateUnified
    signal updateMasks

    property var switchPresets: JSON.parse(plasmoid.configuration.switchPresets)
    property QtObject panelView: null

    property var cfg_hiddenWidgets: Plasmoid.configuration.hiddenWidgets
    property var hiddenWidgets: {
        try {
            return JSON.parse(cfg_hiddenWidgets);
        } catch (e) {
            console.error(e, e.stack);
            return {
                widgets: []
            };
        }
    }

    function applyStockPanelSettings() {
        let script = Utils.setPanelModeScript(Plasmoid.containment.id, stockPanelSettings);
        if (stockPanelSettings.visible.enabled) {
            panelView.visible = stockPanelSettings.visible.value;
        } else {
            panelView.visible = true;
        }
        dbusEvaluateScript.arguments = [script.toString().replace(/\n/g, ' ').trim()];
        dbusEvaluateScript.call(() => {
            Utils.delay(250, () => {
                reconfigure();
            }, main);
        });
    }

    onStockPanelSettingsChanged: {
        Qt.callLater(applyStockPanelSettings);
    }

    onForceRecolorCountChanged: {
        // console.error("onForceRecolorCountChanged ->", forceRecolorCount)
        recolorCountChanged();
    }

    // HACK: temporary enable panel mask on geometry change
    // to fix broken clickable area
    // https://github.com/luisbocanegra/plasma-panel-colorizer/issues/100
    // maybe also related to https://bugs.kde.org/show_bug.cgi?id=489086

    function runPanelClickFix() {
        doPanelClickFix = true;
        doPanelClickFix = false;
    }

    onPanelWidthChanged: {
        runPanelClickFix();
        updateMasks();
    }

    onPanelHeightChanged: {
        runPanelClickFix();
        updateMasks();
    }

    onFloatignessChanged: {
        updateMasks();
        // fixes the mask getting stuck a couple of pixels off for some reason
        if ((main.floatigness === 1 || main.floatigness === 0) && !editMode) {
            Utils.delay(10, () => {
                updateMasks();
            // TODO this forces hidden panels to be always visible and is unclear
            // if it actually helps
            // activatePlasmoidCycle();
            }, main);
        }
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
                speedDebugItem.destroy();
            }
        }
        Component.onCompleted: {
            deleteThisTimer.start();
        }
    }

    property Component colorEffectComponent: MultiEffect {
        // a not very effective way to recolor things that can't be recolored
        // the usual way
        id: effectRect
        property bool luisbocanegraPanelColorizerEffectManaged: true
        property QtObject target
        height: target?.height ?? 0
        width: target?.width ?? 0
        anchors.centerIn: parent
        source: target
        colorization: 1
        autoPaddingEnabled: false
    }

    property Component backgroundComponent: Rectangle {
        id: rect
        property QtObject target
        property int targetIndex
        // use an extra id so we can track the panel and items in tray separately
        // e.g panel[0, widget[1] widget[2] trayWidget[3 [widget[5], widget[6], widget[7]]] widget[4]]
        property int maskIndex: {
            if (isPanel) {
                return 0;
            } else {
                return (inTray ? (panelLayoutCount - 1 + targetIndex) : targetIndex + 1);
            }
        }
        property int itemType
        property bool isPanel: itemType === Enums.ItemType.PanelBgItem
        property bool isWidget: itemType === Enums.ItemType.WidgetItem
        property bool isTray: widgetName === "org.kde.plasma.systemtray"
        property bool isTrayArrow: itemType === Enums.ItemType.TrayArrow
        property bool inTray: itemType === Enums.ItemType.TrayItem || isTrayArrow
        property bool luisbocanegraPanelColorizerBgManaged: true
        property var widgetProperties: {
            if (isTrayArrow) {
                const systemTrayState = Utils.getSystemTrayState(trayWidgetBgItem?.target?.applet, main.plasmaVersion);
                return {
                    "id": -1,
                    "name": "org.kde.plasma.systemtray.expand",
                    "hovered": hovered,
                    "expanded": (systemTrayState?.expanded) && systemTrayState?.activeApplet === null,
                    "needsAttention": false,
                    "busy": false,
                    "trayIconHash": "",
                    "title": ""
                };
            } else {
                return Utils.getWidgetProperties(target, PlasmaCore.Types, hovered, main.plasmaVersion, inTray, main.panelColorizer, main.logSystemTrayIconChanges && rect.hovered);
            }
        }
        property string widgetName: widgetProperties.name
        property string widgetTitle: widgetProperties.title
        property int widgetId: widgetProperties.id
        property string trayIconHash: widgetProperties.trayIconHash
        onTrayIconHashChanged: {
            if (main.logSystemTrayIconChanges) {
                console.log("Tray icon changed, title:", rect.widgetTitle, "name:", rect.widgetName, "\nSHA1:", rect.trayIconHash, "\nReplacement:", rect.customIcon);
            }
        }

        property string customIcon: {
            if (!main.systemTrayIconsReplacementEnabled || !main.isEnabled) {
                return "";
            }
            let icon = "";
            if (Plasmoid.configuration.systemTrayIconBuiltinReplacementsEnabled) {
                icon = Utils.getTrayIconFromRules(SNIIconRules.rules, rect.widgetProperties);
            }
            const iconFromUerRule = Utils.getTrayIconFromRules(main.systemTrayIconUserReplacements, rect.widgetProperties);
            if (iconFromUerRule) {
                icon = iconFromUerRule;
            }
            return icon;
        }
        Binding {
            // https://github.com/KDE/plasma-workspace/blob/fd4e840e7c270b79d35e6978e44d1fe7bdaaa6e7/applets/systemtray/qml/StatusNotifierItem.qml#L25
            target: rect.target?.item?.iconContainer?.children[0] ?? null
            property: "source"
            value: rect.customIcon
            when: rect.customIcon !== ""
            delayed: true
        }
        property var wRecolorCfg: Utils.getForceFgWidgetConfig(widgetId, widgetName, forceRecolorList)
        property bool requiresRefresh: wRecolorCfg?.reload ?? false
        // 0: default | 1: start | 2: end
        property var wUnifyCfg: Utils.getForceFgWidgetConfig(widgetId, widgetName, unifiedBackgroundSettings)
        property int unifySection: wUnifyCfg?.unifyBgType ?? 0

        // 0: default | 1: start | 2: middle | 3: end
        property int unifyBgType: unifiedBackgroundFinal.find(item => item.index === maskIndex)?.type ?? 0
        onUnifySectionChanged: {
            Qt.callLater(main.updateUnified);
        }

        function updateUnifyType() {
            if (inTray || isPanel) {
                return;
            }
            main.unifiedBackgroundFinal = Utils.updateUnifiedBackgroundTracker(maskIndex, unifySection, isVisible, main.unifiedBackgroundTracker);
        }

        property var itemConfig: Utils.getItemCfg(itemType, widgetName, widgetId, main.cfg, main.configurationOverrides, widgetProperties.busy, widgetProperties.needsAttention, widgetProperties.hovered, widgetProperties.expanded)
        property var cfg: itemConfig.settings
        property bool cfgOverride: itemConfig.override
        property var bgColorCfg: cfg.backgroundColor
        property var fgColorCfg: cfg.foregroundColor
        property int itemCount: 0
        property int maxDepth: 0
        opacity: cfgEnabled ? 1 : 0
        property bool isVisible: target.visibleChildren.length > 0 && opacity !== 0
        property bool cfgEnabled: cfg.enabled && isEnabled
        property bool bgEnabled: bgColorCfg.enabled
        property bool fgEnabled: fgColorCfg.enabled
        property bool radiusEnabled: cfgEnabled && cfg.radius.enabled

        property bool panelTouchingTop: isPanel && main.panelElement && !main.panelIsFloating && main.panelPosition.location === "top"
        property bool panelTouchingBottom: isPanel && main.panelElement && !main.panelIsFloating && main.panelPosition.location === "bottom"
        property bool panelTouchingLeft: isPanel && main.panelElement && !main.panelIsFloating && main.panelPosition.location === "left"
        property bool panelTouchingRight: isPanel && main.panelElement && !main.panelIsFloating && main.panelPosition.location === "right"

        property var hideCfg: main.hiddenWidgets.widgets.find(widget => widget.id === widgetId && widget.name === widgetName)

        function cornerForcedZero(cornerName) {
            if (!isPanel || !(cfg.flattenOnDeFloat ?? false))
                return false;
            switch (cornerName) {
            case "topLeft":
                return panelTouchingTop || panelTouchingLeft;
            case "topRight":
                return panelTouchingTop || panelTouchingRight;
            case "bottomLeft":
                return panelTouchingBottom || panelTouchingLeft;
            case "bottomRight":
                return panelTouchingBottom || panelTouchingRight;
            }
            return false;
        }

        topLeftRadius: (!radiusEnabled || unifyBgType === 2 || unifyBgType === 3 || cornerForcedZero("topLeft")) ? 0 : cfg.radius.corner.topLeft ?? 0
        topRightRadius: (!radiusEnabled || (horizontal && (unifyBgType === 1 || unifyBgType === 2)) || (!horizontal && (unifyBgType === 2 || unifyBgType === 3)) || cornerForcedZero("topRight")) ? 0 : cfg.radius.corner.topRight ?? 0

        bottomLeftRadius: (!radiusEnabled || (horizontal && (unifyBgType === 2 || unifyBgType === 3)) || (!horizontal && (unifyBgType === 1 || unifyBgType === 2)) || cornerForcedZero("bottomLeft")) ? 0 : cfg.radius.corner.bottomLeft ?? 0

        bottomRightRadius: (!radiusEnabled || unifyBgType === 1 || unifyBgType === 2 || (!horizontal && (unifyBgType === 1 || unifyBgType === 2)) || cornerForcedZero("bottomRight")) ? 0 : cfg.radius.corner.bottomRight ?? 0

        property bool marginEnabled: cfg.margin.enabled && cfgEnabled
        property bool borderEnabled: cfg.border.enabled && cfgEnabled
        property bool bgShadowEnabled: cfg.shadow.background.enabled && cfgEnabled
        property var bgShadow: cfg.shadow.background
        property bool fgShadowEnabled: cfg.shadow.foreground.enabled && cfgEnabled
        property var fgShadow: cfg.shadow.foreground
        property bool blurBehind: {
            return (isPanel && !anyWidgetDoingBlur && !anyTrayItemDoingBlur) || (isWidget) || (inTray && !trayWidgetBgItem?.blurBehind) ? cfg.blurBehind : false;
        }
        property string fgColor: {
            if (inTray && fgEnabled && cfgEnabled) {
                return Utils.getColor(fgColorCfg, targetIndex, color, itemType, fgColorHolder);
            }
            if (inTray && (!fgEnabled || !cfgEnabled) && trayWidgetBgItem?.cfgEnabled && trayWidgetBgItem?.fgColorCfg?.enabled) {
                return trayWidgetBgItem?.fgColor;
            }
            if (isWidget && fgEnabled && cfgEnabled) {
                return Utils.getColor(fgColorCfg, targetIndex, color, itemType, fgColorHolder);
            }
            return defaultColorHolder.Kirigami.Theme.textColor.toString();
        }

        property bool throttleMaskUpdate: false
        // `visible: false` breaks in Plasma 6.3.4, so we use `opacity: 0` instead
        // https://github.com/luisbocanegra/plasma-panel-colorizer/issues/212
        // https://bugs.kde.org/show_bug.cgi?id=502480
        Rectangle {
            id: defaultColorHolder
            height: 6
            width: height
            opacity: 0
        }
        Rectangle {
            id: fgColorHolder
            height: 6
            width: height
            opacity: 0
            Kirigami.Theme.colorSet: Kirigami.Theme[fgColorCfg.systemColorSet]
        }

        Behavior on topLeftRadius {
            enabled: animatePropertyChanges
            NumberAnimation {
                duration: main.animationDuration
                easing.type: main.animationEasingType
            }
        }
        Behavior on topRightRadius {
            enabled: animatePropertyChanges
            NumberAnimation {
                duration: main.animationDuration
                easing.type: main.animationEasingType
            }
        }
        Behavior on bottomLeftRadius {
            enabled: animatePropertyChanges
            NumberAnimation {
                duration: main.animationDuration
                easing.type: main.animationEasingType
            }
        }
        Behavior on bottomRightRadius {
            enabled: animatePropertyChanges
            NumberAnimation {
                duration: main.animationDuration
                easing.type: main.animationEasingType
            }
        }

        Kirigami.Theme.colorSet: Kirigami.Theme[bgColorCfg.systemColorSet]
        color: {
            if (bgEnabled && bgColorCfg.sourceType !== 5) {
                return Utils.getColor(bgColorCfg, targetIndex, null, itemType, rect);
            } else {
                return "transparent";
            }
        }

        GradientRoundedRectangle {
            stops: bgColorCfg.gradient?.stops || []
            visible: bgColorCfg.sourceType === 5 && bgColorCfg.gradient?.stops && bgEnabled
            orientation: bgColorCfg.gradient?.orientation === 0 ? Gradient.Horizontal : Gradient.Vertical
            corners: {
                "topLeftRadius": rect.topLeftRadius,
                "topRightRadius": rect.topRightRadius,
                "bottomLeftRadius": rect.bottomLeftRadius,
                "bottomRightRadius": rect.bottomRightRadius
            }
        }

        ImageRoundedRectangle {
            source: visible ? bgColorCfg.image?.source : ""
            visible: bgColorCfg.sourceType === 6 && bgColorCfg.image?.source && bgEnabled
            fillMode: bgColorCfg.image?.fillMode !== undefined ? bgColorCfg.image?.fillMode : Image.PreserveAspectCrop
            corners: {
                "topLeftRadius": rect.topLeftRadius,
                "topRightRadius": rect.topRightRadius,
                "bottomLeftRadius": rect.bottomLeftRadius,
                "bottomRightRadius": rect.bottomRightRadius
            }
            sourceSize: {
                if (fillMode === AnimatedImage.Tile) {
                    return undefined;
                } else {
                    Qt.size(rect.width > rect.height ? rect.width : rect.height, 0);
                }
            }
            onStatusChanged: {
                if (status === AnimatedImage.Ready) {
                    playing = true;
                }
            }
        }

        Behavior on color {
            enabled: animatePropertyChanges
            ColorAnimation {
                duration: main.animationDuration
                easing.type: main.animationEasingType
            }
        }

        property int targetChildren: target?.children.length ?? 0
        onTargetChildrenChanged: {
            // console.error("CHILDREN CHANGED", targetChildren, target)
            recolorTimer.restart();
        }
        property int targetVisibleChildren: target?.visibleChildren.length ?? 0
        onTargetVisibleChildrenChanged: {
            // console.error("CHILDREN CHANGED", targetVisibleChildren, target)
            recolorTimer.restart();
        }
        property int targetCount: target?.count ?? 0
        onTargetCountChanged: {
            // console.error("COUNT CHANGED", targetCount, target)
            recolorTimer.restart();
        }

        onFgColorChanged: {
            // console.error("FG COLOR CHANGED", fgColor, target)
            recolorTimer.restart();
        }

        property bool fgColorModified: false

        onFgEnabledChanged: {
            if (fgEnabled)
                fgColorModified = true;
        }

        Timer {
            id: recolorTimer
            interval: 10
            onTriggered: {
                if (isPanel)
                    return;
                if (isTray && trayWidgetSettings.normal.foregroundColor.enabled)
                    return;
                const result = Utils.applyFgColor(target, fgColor, fgColorCfg, 0, wRecolorCfg, fgColorModified, colorEffectComponent, repaintDebugComponent);
                if (result) {
                    itemCount = result.count;
                    maxDepth = result.depth;
                }
            }
        }

        onRequiresRefreshChanged: {
            if (requiresRefresh) {
                main.refreshNeeded.connect(recolorTimer.restart);
            } else {
                main.refreshNeeded.disconnect(recolorTimer.restart);
            }
        }

        Component.onCompleted: {
            main.recolorCountChanged.connect(recolorTimer.restart);
            main.updateUnified.connect(updateUnifyType);
            main.updateMasks.connect(updateMaskDebounced);
            recolorTimer.start();
        }

        Component.onDestruction: {
            if (main.panelColorizer) {
                main.panelColorizer.popLastVisibleMaskRegion();
            }
            main.recolorCountChanged.disconnect(recolorTimer.restart);
            main.updateUnified.disconnect(updateUnifyType);
            main.updateMasks.disconnect(updateMaskDebounced);
            main.refreshNeeded.disconnect(recolorTimer.restart);
            trayInitTimer.restart();
        }

        height: inTray ? (target?.height ?? 0) : parent.height
        width: inTray ? (target?.width ?? 0) : parent.width
        Behavior on height {
            enabled: animatePropertyChanges
            NumberAnimation {
                duration: main.animationDuration
                easing.type: main.animationEasingType
            }
        }
        Behavior on width {
            enabled: animatePropertyChanges
            NumberAnimation {
                duration: main.animationDuration
                easing.type: main.animationEasingType
            }
        }
        anchors.centerIn: (inTray || isTrayArrow) ? parent : undefined
        anchors.fill: (isPanel || inTray || isTrayArrow) ? parent : undefined

        property int extraLSpacing: ((unifyBgType === 2 || unifyBgType === 3) && horizontal ? widgetsSpacing : 0) / 2
        property int extraRSpacing: ((unifyBgType === 1 || unifyBgType === 2) && horizontal ? widgetsSpacing : 0) / 2
        property int extraTSpacing: ((unifyBgType === 2 || unifyBgType === 3) && !horizontal ? widgetsSpacing : 0) / 2
        property int extraBSpacing: ((unifyBgType === 1 || unifyBgType === 2) && !horizontal ? widgetsSpacing : 0) / 2

        property int marginLeft: (marginEnabled ? cfg.margin.side.left : 0) + extraLSpacing
        property int marginRight: (marginEnabled ? cfg.margin.side.right : 0) + extraRSpacing
        property int horizontalWidth: marginLeft + marginRight

        property int marginTop: (marginEnabled ? cfg.margin.side.top : 0) + extraTSpacing
        property int marginBottom: (marginEnabled ? cfg.margin.side.bottom : 0) + extraBSpacing
        property int verticalWidth: marginTop + marginBottom

        Behavior on horizontalWidth {
            enabled: animatePropertyChanges
            NumberAnimation {
                duration: main.animationDuration
                easing.type: main.animationEasingType
            }
        }
        Behavior on verticalWidth {
            enabled: animatePropertyChanges
            NumberAnimation {
                duration: main.animationDuration
                easing.type: main.animationEasingType
            }
        }

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
            value: (parent?.width ?? 0) + horizontalWidth
            when: isWidget && horizontal
            delayed: true
        }

        Binding {
            target: rect
            property: "height"
            value: (parent?.height ?? 0) + verticalWidth
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
            value: {
                let margin = 0;
                if (rect.marginEnabled && rect.marginLeft !== 0) {
                    margin = rect.marginLeft;
                }
                if (main.fillAreaOnDeFloat && main.panelElement?.floating && (main.panelElement?.floatingness !== 1)) {
                    margin -= (8 * (1 - main.panelElement?.floatingness));
                }
                return margin;
            }
            when: rect.isPanel && main.isEnabled
            delayed: true
        }

        Binding {
            target: rect.target
            property: "anchors.rightMargin"
            value: {
                let margin = 0;
                if (rect.marginEnabled && rect.marginRight !== 0) {
                    margin = rect.marginRight;
                }
                if (main.fillAreaOnDeFloat && main.panelElement?.floating && (main.panelElement?.floatingness !== 1)) {
                    margin -= (8 * (1 - main.panelElement?.floatingness));
                }
                return margin;
            }
            when: rect.isPanel && main.isEnabled
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
            when: marginEnabled && inTray
            delayed: true
        }

        Binding {
            target: rect
            property: "anchors.rightMargin"
            value: marginRight
            when: marginEnabled && inTray
            delayed: true
        }

        Binding {
            target: rect
            property: "anchors.topMargin"
            value: marginTop
            when: marginEnabled && inTray
            delayed: true
        }

        Binding {
            target: rect
            property: "anchors.bottomMargin"
            value: marginBottom
            when: marginEnabled && inTray
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

        Binding {
            target: rect.target
            property: "opacity"
            value: rect.cfg?.opacity ?? 1
            when: (rect.isWidget || rect.inTray || rect.isTrayArrow) && rect.cfg?.opacity !== undefined
            delayed: true
        }

        Binding {
            target: rect.target.applet?.plasmoid ?? null
            property: "status"
            when: (rect.hideCfg?.hide ?? false) && !main.editMode
            value: PlasmaCore.Types.HiddenStatus
        }

        Item {
            anchors.fill: parent
            CustomBorder {
                id: borderRec
                visible: borderEnabled && Math.min(rect.height, rect.width) > 1
                Behavior on borderColor {
                    enabled: main.animatePropertyChanges
                    ColorAnimation {
                        duration: main.animationDuration
                        easing.type: main.animationEasingType
                    }
                }
                horizontal: main.horizontal
                unifyBgType: rect.unifyBgType
                corners: {
                    "topLeftRadius": rect.topLeftRadius,
                    "topRightRadius": rect.topRightRadius,
                    "bottomLeftRadius": rect.bottomLeftRadius,
                    "bottomRightRadius": rect.bottomRightRadius
                }
                cfgBorder: cfg.border
                panelTouchingTop: rect.panelTouchingTop
                panelTouchingBottom: rect.panelTouchingBottom
                panelTouchingLeft: rect.panelTouchingLeft
                panelTouchingRight: rect.panelTouchingRight
                flattenPanelBordersOnEdge: cfg.flattenOnDeFloat ?? false
                borderColor: {
                    return Utils.getColor(cfg.border.color, targetIndex, rect.color, itemType, borderRec);
                }
            }

            CustomBorder {
                id: borderSecondary
                property real parentBorderLeft: cfg.border.customSides ? cfg.border.custom.widths.left : cfg.border.width
                property real parentBorderRight: cfg.border.customSides ? cfg.border.custom.widths.right : cfg.border.width
                property real parentBorderTop: cfg.border.customSides ? cfg.border.custom.widths.top : cfg.border.width
                property real parentBorderBottom: cfg.border.customSides ? cfg.border.custom.widths.bottom : cfg.border.width
                property real extraLMargin: ((rect.unifyBgType === 2 || rect.unifyBgType === 3) && main.horizontal) ? 0 : parentBorderLeft
                property real extraRMargin: ((rect.unifyBgType === 1 || rect.unifyBgType === 2) && main.horizontal) ? 0 : parentBorderRight
                property real extraTMargin: ((rect.unifyBgType === 2 || rect.unifyBgType === 3) && !main.horizontal) ? 0 : parentBorderTop
                property real extraBMargin: ((rect.unifyBgType === 1 || rect.unifyBgType === 2) && !main.horizontal) ? 0 : parentBorderBottom
                anchors.topMargin: cfg.border.enabled ? extraTMargin : 0
                anchors.bottomMargin: cfg.border.enabled ? extraBMargin : 0
                anchors.leftMargin: cfg.border.enabled ? extraLMargin : 0
                anchors.rightMargin: cfg.border.enabled ? extraRMargin : 0
                visible: cfg.borderSecondary.enabled && cfgEnabled && Math.min(rect.height, rect.width) > 1
                Behavior on borderColor {
                    enabled: main.animatePropertyChanges
                    ColorAnimation {
                        duration: main.animationDuration
                        easing.type: main.animationEasingType
                    }
                }
                horizontal: main.horizontal
                unifyBgType: rect.unifyBgType
                corners: {
                    "topLeftRadius": Math.max(rect.topLeftRadius - cfg.border.width, 0),
                    "topRightRadius": Math.max(rect.topRightRadius - cfg.border.width, 0),
                    "bottomLeftRadius": Math.max(rect.bottomLeftRadius - cfg.border.width, 0),
                    "bottomRightRadius": Math.max(rect.bottomRightRadius - cfg.border.width, 0)
                }
                cfgBorder: cfg.borderSecondary
                panelTouchingTop: rect.panelTouchingTop
                panelTouchingBottom: rect.panelTouchingBottom
                panelTouchingLeft: rect.panelTouchingLeft
                panelTouchingRight: rect.panelTouchingRight
                flattenPanelBordersOnEdge: cfg.flattenOnDeFloat ?? false
                borderColor: {
                    return Utils.getColor(cfg.borderSecondary.color, targetIndex, rect.color, itemType, borderSecondary);
                }
            }

            layer.enabled: cfg.border.customSides
            layer.effect: OpacityMask {
                maskSource: Item {
                    width: rect.width
                    height: rect.height
                    Rectangle {
                        anchors.fill: parent
                        topLeftRadius: rect.topLeftRadius
                        topRightRadius: rect.topRightRadius
                        bottomLeftRadius: rect.bottomLeftRadius
                        bottomRightRadius: rect.bottomRightRadius
                    }
                }
            }
        }

        Kirigami.ShadowedRectangle {
            id: backgroundShadow
            anchors.fill: parent
            color: "transparent"
            z: -1
            corners {
                topLeftRadius: rect.topLeftRadius
                topRightRadius: rect.topRightRadius
                bottomLeftRadius: rect.bottomLeftRadius
                bottomRightRadius: rect.bottomRightRadius
            }
            shadow {
                property var shadowColorCfg: bgShadow.color
                Kirigami.Theme.colorSet: Kirigami.Theme[shadowColorCfg.systemColorSet]
                size: (bgShadowEnabled && Math.min(rect.height, rect.width) > 1) ? bgShadow.size : 0
                color: {
                    return Utils.getColor(shadowColorCfg, targetIndex, rect.color, itemType, backgroundShadow.shadow);
                }
                xOffset: bgShadow.xOffset
                yOffset: bgShadow.yOffset

                Behavior on size {
                    enabled: animatePropertyChanges
                    NumberAnimation {
                        duration: main.animationDuration
                        easing.type: main.animationEasingType
                    }
                }
                Behavior on xOffset {
                    enabled: animatePropertyChanges
                    NumberAnimation {
                        duration: main.animationDuration
                        easing.type: main.animationEasingType
                    }
                }
                Behavior on yOffset {
                    enabled: animatePropertyChanges
                    NumberAnimation {
                        duration: main.animationDuration
                        easing.type: main.animationEasingType
                    }
                }
                Behavior on color {
                    enabled: animatePropertyChanges
                    ColorAnimation {
                        duration: main.animationDuration
                        easing.type: main.animationEasingType
                    }
                }
            }
        }

        // paddingRect to hide the shadow in one or two sides Qt.rect(left,top,right,bottom)
        layer.enabled: bgShadowEnabled && unifyBgType !== 0
        // how much padding are we hiding
        property int ps: Math.max(bgShadow.size, bgShadow.xOffset, bgShadow.yOffset)
        layer.effect: MultiEffect {
            autoPaddingEnabled: true
            paddingRect: {
                if (unifyBgType === 1) {
                    return horizontal ? Qt.rect(ps, ps, 0, ps) : Qt.rect(ps, ps, ps, 0);
                }
                if (unifyBgType === 2) {
                    return horizontal ? Qt.rect(0, ps, 0, ps) : Qt.rect(ps, 0, ps, 0);
                }
                if (unifyBgType === 3) {
                    return horizontal ? Qt.rect(0, ps, ps, ps) : Qt.rect(ps, 0, ps, ps);
                }
            }
        }

        DropShadow {
            id: dropShadow
            anchors.fill: parent
            // we need to compensate because we now space widgets with margins
            // instead of the layout spacing for the unified background feature
            // can't anchor to center because we can also add different margin
            // on each side, the shadow position is off otherwise
            anchors.leftMargin: horizontal ? rect.marginLeft : undefined
            anchors.rightMargin: horizontal ? rect.marginRight : undefined
            anchors.topMargin: horizontal ? undefined : rect.marginTop
            anchors.bottomMargin: horizontal ? undefined : rect.marginBottom
            property var shadowColorCfg: fgShadow.color
            Kirigami.Theme.colorSet: Kirigami.Theme[shadowColorCfg.systemColorSet]
            horizontalOffset: fgShadow.xOffset
            verticalOffset: fgShadow.yOffset
            radius: fgShadowEnabled ? fgShadow.size : 0
            samples: radius * 2 + 1
            spread: 0.35
            color: {
                return Utils.getColor(shadowColorCfg, targetIndex, rect.color, itemType, dropShadow);
            }
            source: target?.applet ?? null
            visible: fgShadowEnabled
            Behavior on color {
                enabled: animatePropertyChanges
                ColorAnimation {
                    duration: main.animationDuration
                    easing.type: main.animationEasingType
                }
            }
            Behavior on radius {
                enabled: animatePropertyChanges
                NumberAnimation {
                    duration: main.animationDuration
                    easing.type: main.animationEasingType
                }
            }
            Behavior on horizontalOffset {
                enabled: animatePropertyChanges
                NumberAnimation {
                    duration: main.animationDuration
                    easing.type: main.animationEasingType
                }
            }
            Behavior on verticalOffset {
                enabled: animatePropertyChanges
                NumberAnimation {
                    duration: main.animationDuration
                    easing.type: main.animationEasingType
                }
            }
        }

        property real blurMaskX: {
            const marginLeft = rect.marginEnabled ? rect.marginLeft : 0;
            if (panelElement !== null && panelElement.floating && horizontal) {
                if (floatigness > 0) {
                    return marginLeft;
                } else {
                    return (panelElement.width - borderRec.width) / 2;
                }
            } else {
                return marginLeft;
            }
        }

        property real blurMaskY: {
            const marginTop = rect.marginEnabled ? rect.marginTop : 0;
            if (panelElement !== null && panelElement.floating && !horizontal) {
                if (floatigness > 0) {
                    return marginTop;
                } else {
                    return (panelElement.height - borderRec.height) / 2;
                }
            } else {
                return marginTop;
            }
        }

        property var position: Qt.point(0, 0)
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
                    z: -1
                    opacity: 0.5
                }
            }
            Label {
                text: unifySection + "," + unifyBgType//blurBehind+","+anyWidgetDoingBlur //parseInt(position.x)+","+parseInt(position.y)
                font.pixelSize: 8
                Rectangle {
                    anchors.fill: parent
                    color: "black"
                    z: -1
                    opacity: 0.5
                }
            }
        }

        Label {
            text: parseInt(borderRec.width) + "x" + parseInt(borderRec.height)
            font.pixelSize: 8
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            visible: debug
            Rectangle {
                anchors.fill: parent
                color: "black"
                z: -1
            }
        }

        onXChanged: {
            // console.error("onXChanged()")
            updateMaskDebounced();
        }

        onYChanged: {
            // console.error("onYChanged()")
            updateMaskDebounced();
        }

        onWidthChanged: {
            // console.error("onWidthChanged()")
            main.updateMasks();
        }

        onHeightChanged: {
            // console.error("onHeightChanged()")
            main.updateMasks();
        }

        onBlurMaskXChanged: {
            // console.error("onBlurMaskXChanged()")
            updateMaskDebounced();
        }

        onBlurMaskYChanged: {
            // console.error("onBlurMaskYChanged()")
            updateMaskDebounced();
        }

        onTopLeftRadiusChanged: updateMaskDebounced()
        onTopRightRadiusChanged: updateMaskDebounced()
        onBottomLeftRadiusChanged: updateMaskDebounced()
        onBottomRightRadiusChanged: updateMaskDebounced()

        // TODO find where does 16 and 8 come from instead of blindly hardcoding them
        property real moveX: {
            const edge = main.plasmaVersion.isLowerThan("6.2.0") ? PlasmaCore.Types.LeftEdge : PlasmaCore.Types.RightEdge;
            const m = horizontal ? 0 : (panelElement?.floating && plasmoid.location === edge ? 16 : 0);
            return floatigness > 0 ? (8 * floatigness) : m;
        }

        property real moveY: {
            const edge = main.plasmaVersion.isLowerThan("6.2.0") ? PlasmaCore.Types.TopEdge : PlasmaCore.Types.BottomEdge;
            const m = horizontal ? (panelElement?.floating && plasmoid.location === edge ? 16 : 0) : 0;
            return floatigness > 0 ? (8 * floatigness) : m;
        }

        onIsVisibleChanged: {
            Qt.callLater(function () {
                main.updateUnified();
                updateMaskDebounced();
            });
        }

        onBlurBehindChanged: {
            if (isWidget) {
                widgetsDoingBlur[maskIndex] = blurBehind;
                anyWidgetDoingBlur = Object.values(widgetsDoingBlur).some(state => state);
            } else if (inTray) {
                trayItemsDoingBlur[maskIndex] = blurBehind;
                anyTrayItemDoingBlur = Object.values(trayItemsDoingBlur).some(state => state);
            }
            updateMaskDebounced();
        }

        function updateMaskDebounced() {
            if (rect.throttleMaskUpdate) {
                return;
            }
            rect.throttleMaskUpdate = true;
            Qt.callLater(function () {
                updateMask();
                rect.throttleMaskUpdate = false;
            });
        }

        function updateMask() {
            if (panelColorizer === null || !borderRec)
                return;
            // don't try to create a mask if the widget is not visible
            // for example with PlasmaCore.Types.HiddenStatus
            if (borderRec.width <= 0 || borderRec.height <= 0)
                return;
            position = Utils.getGlobalPosition(borderRec, panelElement);
            panelColorizer.updatePanelMask(maskIndex, borderRec, rect.topLeftRadius, rect.topRightRadius, rect.bottomLeftRadius, rect.bottomRightRadius, Qt.point(rect.positionX - moveX, rect.positionY - moveY), 5, isVisible && blurBehind);
        }

        property bool hovered: hoverHandler.hovered
        onHoveredChanged: {
            if (main.logSystemTrayIconChanges && hovered && rect.inTray && rect.trayIconHash) {
                console.log("Hovered tray item, title:", rect.widgetTitle, "name:", rect.widgetName, "\nSHA1:", rect.trayIconHash, "\nReplacement:", rect.customIcon);
            }
        }
        HoverHandler {
            id: hoverHandler
            parent: rect.target
        }
    }

    // Search the actual gridLayout of the panel
    property Item panelLayout: {
        let candidate = main.parent;
        while (candidate) {
            if (candidate instanceof GridLayout) {
                return candidate;
            }
            candidate = candidate.parent;
        }
        return null;
    }

    property QtObject panelLayoutContainer: {
        if (!panelLayout)
            return null;
        return panelLayout.parent;
    }

    Binding {
        target: panelLayoutContainer
        property: "anchors.leftMargin"
        value: fixedSidePaddingEnabled ? panelBgItem.cfg.padding.side.left : 0
        when: fixedSidePaddingEnabled
        delayed: true
    }

    Binding {
        target: panelLayoutContainer
        property: "anchors.rightMargin"
        value: fixedSidePaddingEnabled ? panelBgItem.cfg.padding.side.right : 0
        when: fixedSidePaddingEnabled
        delayed: true
    }

    Binding {
        target: panelLayoutContainer
        property: "anchors.topMargin"
        value: fixedSidePaddingEnabled ? panelBgItem.cfg.padding.side.top : 0
        when: fixedSidePaddingEnabled
        delayed: true
    }

    Binding {
        target: panelLayoutContainer
        property: "anchors.bottomMargin"
        value: fixedSidePaddingEnabled ? panelBgItem.cfg.padding.side.bottom : 0
        when: fixedSidePaddingEnabled
        delayed: true
    }

    Binding {
        target: panelElement
        property: "panelMask"
        value: blurMask
        when: (panelColorizer !== null && blurMask && panelColorizer?.hasRegions && (panelBgItem.cfg.blurBehind || anyWidgetDoingBlur || anyTrayItemDoingBlur))
    }

    Binding {
        target: panelElement
        property: "topShadowMargin"
        value: panelView !== null ? -panelView.height - 8 : 0
        when: (!nativePanelBackgroundShadowEnabled && panelView !== null)
    }

    Binding {
        target: panelElement
        property: "bottomShadowMargin"
        value: panelView !== null ? -panelView.height - 8 : 0
        when: (!nativePanelBackgroundShadowEnabled && panelView !== null)
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

    property QtObject panelBg: {
        if (!panelLayoutContainer)
            return null;
        return panelLayoutContainer.parent;
    }

    property GridView trayGridView: {
        if (!panelLayout?.children)
            return null;
        for (let i in panelLayout.children) {
            const child = panelLayout.children[i];
            // name may not be available while gragging into the panel and
            // other situations
            if (!child.applet?.plasmoid?.pluginName)
                continue;
            const name = child.applet.plasmoid.pluginName;
            if (name === "org.kde.plasma.systemtray") {
                return Utils.findTrayGridView(child);
            }
        }
        return null;
    }

    property QtObject trayExpandArrow: {
        if (trayGridView?.parent) {
            return Utils.findTrayExpandArrow(trayGridView.parent);
        }
        return null;
    }

    Binding {
        target: main.trayExpandArrow
        property: "iconSize"
        value: (main.horizontal ? main.trayGridView?.cellWidth : main.trayGridView?.cellHeight) ?? 0
        when: main.trayGridView !== null && (main.trayWidgetSettings.wideTrayArrow ?? false)
        delayed: true
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
        return null;
    }

    property QtObject containmentItem: {
        let candidate = main.parent;
        while (candidate) {
            if (candidate.toString().indexOf("ContainmentItem_QML") > -1) {
                return candidate;
            }
            candidate = candidate.parent;
        }
        return null;
    }

    onPanelElementChanged: {
        Utils.panelOpacity(panelElement, isEnabled, nativePanelBackgroundOpacity);
    }

    property Component gridComponent: RectangularGrid {
        id: gridComponent
        backgroundColor: editModeGrid.background.color
        backgroundOpacity: editModeGrid.background.alpha

        minorLineColor: editModeGrid.minorLine.color
        minorLineOpacity: editModeGrid.minorLine.alpha

        majorLineColor: editModeGrid.majorLine.color
        majorLineOpacity: editModeGrid.majorLine.alpha

        spacing: editModeGrid.spacing
        majorLineEvery: editModeGrid.majorLineEvery
        Component.onCompleted: {
            main.onShowEditingGridChanged.connect(function release() {
                if (!main.showEditingGrid) {
                    main.onShowEditingGridChanged.disconnect(release);
                    gridComponent.destroy();
                }
            });
        }
    }

    property Component configuringIndicator: ConfiguringIndicator {
        id: configuringIndicator
        Component.onCompleted: {
            Plasmoid.onUserConfiguringChanged.connect(function release() {
                if (!Plasmoid.userConfiguring) {
                    Plasmoid.onUserConfiguringChanged.disconnect(release);
                    configuringIndicator.destroy();
                }
            });
        }
    }

    onNativePanelBackgroundOpacityChanged: {
        Utils.panelOpacity(panelElement, isEnabled, nativePanelBackgroundOpacity);
    }

    Behavior on nativePanelBackgroundOpacity {
        enabled: animatePropertyChanges
        NumberAnimation {
            duration: main.animationDuration
            easing.type: main.animationEasingType
        }
    }

    onNativePanelBackgroundEnabledChanged: {
        Utils.toggleTransparency(containmentItem, nativePanelBackgroundEnabled);
        Utils.panelOpacity(panelElement, isEnabled, nativePanelBackgroundOpacity);
    }

    onFloatingDialogsChanged: {
        setFloatingApplets();
    }

    onFloatingDialogsAllowOverrideChanged: {
        setFloatingApplets();
    }

    // inspired by https://invent.kde.org/plasma/plasma-desktop/-/merge_requests/1912
    function setFloatingApplets() {
        if (!containmentItem)
            return;
        // Plasma 6.4 now has a floating applets option, but we are overriding it,
        // so let's require the user to enable it before forcing one state of the other
        if (main.plasmaVersion.isGreaterThan("6.3.5") && !floatingDialogsAllowOverride) {
            return;
        }
        if (floatingDialogs) {
            containmentItem.Plasmoid.containmentDisplayHints |= PlasmaCore.Types.ContainmentPrefersFloatingApplets;
        } else {
            containmentItem.Plasmoid.containmentDisplayHints &= ~PlasmaCore.Types.ContainmentPrefersFloatingApplets;
        }
    }

    onContainmentItemChanged: {
        Utils.toggleTransparency(containmentItem, nativePanelBackgroundEnabled);
        setFloatingApplets();
        if (!containmentItem)
            return;
        containmentItem.Plasmoid.onContainmentDisplayHintsChanged.connect(setFloatingApplets);
    }

    // HACK: change panelLayout spacing on startup to trigger a length reload
    // BUG: https://bugs.kde.org/show_bug.cgi?id=489086
    // https://github.com/luisbocanegra/plasma-panel-colorizer/issues/100

    onPanelLayoutChanged: {
        if (!panelLayout)
            return;
        panelFixTimer.restart();
    }

    Timer {
        id: panelFixTimer
        repeat: false
        interval: 2000
        onTriggered: {
            doPanelLengthFix = true;
            Utils.delay(200, () => {
                doPanelLengthFix = false;
                reconfigure();
            }, main);
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

    onPanelLayoutCountChanged: {
        // console.log("onPanelLayoutCountChanged")
        initAll();
        // re-apply customizations after the widget stops being dagged around
        if (!panelLayout?.children?.length) {
            return;
        }
        for (var i = 0; i < panelLayout.children.length; i++) {
            var item = panelLayout.children[i];
            if (!item || (!item.hasOwnProperty("draggingChanged")))
                return;
            item.draggingChanged.disconnect(initAll);
            item.draggingChanged.connect(initAll);
        }
    }

    function initAll() {
        if (!panelLayout || panelLayoutCount === 0)
            return;
        Qt.callLater(function () {
            trayInitTimer.restart();
            Utils.showWidgets(panelLayout, backgroundComponent, Plasmoid);
            updateCurrentWidgets();
            showPanelBg(panelBg);
            updateContextualActions(configureFromAllWidgets);
        });
    }

    onEditModeChanged: {
        if (editMode)
            return;
        initAll();
    }

    onTrayGridViewCountChanged: {
        if (trayGridViewCount === 0)
            return;
        // console.error(trayGridViewCount);
        trayInitTimer.restart();
    }

    function switchPreset() {
        const nextPresetDir = Utils.getPresetName(panelState, presetAutoloading);
        if (nextPresetDir && nextPresetDir !== lastPreset)
            applyPreset(nextPresetDir);
    }

    function applyPreset(presetDir) {
        if (!presetDir || presetDir === lastPreset)
            return;
        console.log("Reading preset:", presetDir);
        runCommand.run("cat '" + presetDir + "/settings.json'");
        lastPreset = presetDir;
    }

    onPanelStateChanged: {
        if (!isEnabled)
            return;
        switchPreset();
    }

    onPresetAutoloadingChanged: {
        if (!isEnabled)
            return;
        switchPreset();
    }

    Timer {
        id: trayInitTimer
        interval: 100
        onTriggered: {
            if (trayGridView && trayGridViewCount !== 0) {
                Utils.showTrayAreas(main.trayGridView, main.backgroundComponent);
            }
            main.updateCurrentWidgets();
        }
    }

    DBusMethodCall {
        id: dbusKWinReconfigure
        service: "org.kde.KWin"
        objectPath: "/KWin"
        iface: service
        method: "reconfigure"
        arguments: []
        signature: null
        inSignature: null
    }

    DBusMethodCall {
        id: dbusEvaluateScript
        service: "org.kde.plasmashell"
        objectPath: "/PlasmaShell"
        iface: "org.kde.PlasmaShell"
        method: "evaluateScript"
        arguments: []
        signature: null
        inSignature: null
        useGdbus: true
    }

    function reconfigure() {
        // sometimes windows won't update when the panel visibility or height
        // (and maybe other properties) changes, this is more noticeable with
        // krohnkite tiling extension so we make the panel visible by
        // activating the widget for a moment which in turn activates the panel
        // and org.kde.KWin.reconfigure triggers the resize we need
        // TODO figure out how the desktop edit mode informs the new available size
        if (isWayland) {
            // X11 doesn't seem to need it and also will flicker the panel/screen
            dbusKWinReconfigure.call();
        }
    }

    function activatePlasmoidCycle() {
        Plasmoid.activated();
        Plasmoid.activated();
    }

    // https://github.com/olib14/pinpanel/blob/2d126f0f3ac3e35a725f05b0060a3dd5c924cbe7/package/contents/ui/main.qml#L58 ♥
    Item {
        onWindowChanged: window => {
            main.panelView = window;
        }
    }

    onShowEditingGridChanged: {
        if (showEditingGrid) {
            gridComponent.createObject(main.panelView, {
                "z": -999
            });
        }
    }

    Plasmoid.onUserConfiguringChanged: {
        if (Plasmoid.userConfiguring)
            configuringIndicator.createObject(main.panelBg, {
                "z": 999
            });
    }

    function updateCurrentWidgets() {
        panelWidgets = [];
        panelWidgets = Utils.findWidgets(panelLayout, panelWidgets);
        if (trayGridView) {
            panelWidgets = Utils.findWidgetsTray(trayGridView, panelWidgets);
            panelWidgets = Utils.findWidgetsTray(trayGridView.parent, panelWidgets);
        }
        plasmoid.configuration.panelWidgets = JSON.stringify(panelWidgets, null, null);
        plasmoid.configuration.writeConfig();
    }

    PlasmaCore.Action {
        id: configureAction
        text: plasmoid.internalAction("configure").text
        objectName: "panelColorizerConfigureAction"
        icon.name: 'configure'
        onTriggered: plasmoid.internalAction("configure").trigger()
    }

    onConfigureFromAllWidgetsChanged: {
        updateContextualActions(configureFromAllWidgets);
    }

    function updateContextualActions(enabled) {
        if (!main.panelLayout)
            return;
        for (var i in main.panelLayout.children) {
            const child = main.panelLayout.children[i];
            // may not be available while dragging into the panel and other situations
            if (!child.applet?.plasmoid?.pluginName)
                continue;

            if (child.applet.plasmoid.pluginName === Plasmoid.metaData.pluginId) {
                continue;
            }
            child.applet.plasmoid.contextualActions = child.applet.plasmoid.contextualActions.filter(item => {
                if (item && item.objectName === "panelColorizerConfigureAction") {
                    return false;
                }
                return true;
            });
            if (enabled) {
                child.applet.plasmoid.contextualActions.push(configureAction);
            }
        }
    }

    function showPanelBg(panelBg) {
        if (!panelBg || Utils.getBgManaged(panelBg)) {
            return;
        }
        panelBgItem = backgroundComponent.createObject(panelBg, {
            "z": -1,
            "target": panelBg,
            "itemType": Enums.ItemType.PanelBgItem
        });
    }

    Component.onCompleted: {
        updatePlasmoidStatus();
        runCommand.run("plasmashell --version");
        let pluginFound = false;
        try {
            panelColorizer = Qt.createQmlObject("import org.kde.plasma.panelcolorizer 1.0; PanelColorizer { id: panelColorizer }", main);
            console.log("QML Plugin org.kde.plasma.panelcolorizer loaded");
            pluginFound = true;
        } catch (err) {
            console.warn("QML Plugin org.kde.plasma.panelcolorizer not found. Custom blur background will not work.");
        }
        if (plasmoid.configuration.pluginFound !== pluginFound) {
            plasmoid.configuration.pluginFound = pluginFound;
            plasmoid.configuration.writeConfig();
        }
        Utils.delay(100, () => {
            applyStockPanelSettings();
        }, main);
        Utils.delay(500, () => {
            updateContextualActions(configureFromAllWidgets);
        }, main);
    }

    TasksModel {
        id: tasksModel
        screenGeometry: Plasmoid.containment.screenGeometry
        filterByActive: presetAutoloading.filterByActive ?? false
        filterByScreen: presetAutoloading.filterByScreen ?? true
        trackLastActive: presetAutoloading.trackLastActive ?? true
    }

    RunCommand {
        id: runCommand
    }

    Connections {
        target: runCommand
        function onExited(cmd, exitCode, exitStatus, stdout, stderr, liveUpdate) {
            if (exitCode !== 0) {
                console.error(cmd, exitCode, exitStatus, stdout, stderr);
                return;
            }
            stdout = stdout.trim();
            if (cmd.startsWith("cat")) {
                try {
                    presetContent = JSON.parse(stdout);
                } catch (e) {
                    console.error(`Error reading preset (${cmd}): ${e}`);
                    return;
                }
                Utils.loadPreset(presetContent, plasmoid.configuration, Globals.ignoredConfigs, Globals.defaultConfig, true);
                plasmoid.configuration.lastPreset = lastPreset;
                plasmoid.configuration.writeConfig();
            }
            if (cmd === "plasmashell --version") {
                const parts = stdout.split(" ");
                if (parts.length < 2)
                    return;
                main.plasmaVersion = new VersionUtil.Version(parts[1]);
            }
        }
    }

    Timer {
        running: requiresRefresh
        repeat: true
        interval: forceRecolorInterval
        onTriggered: {
            refreshNeeded();
        }
    }

    compactRepresentation: CompactRepresentation {
        icon: main.icon
        onWidgetClicked: {
            switch (Plasmoid.configuration.widgetClickMode) {
            case (Enum.WidgetClickModes.TogglePanelColorizer):
                console.log("Toggle Pane Colorizer");
                plasmoid.configuration.isEnabled = !plasmoid.configuration.isEnabled;
                plasmoid.configuration.writeConfig();
                break;
            case (Enum.WidgetClickModes.SwitchPresets):
                console.log("Switch presets");
                plasmoid.configuration.switchPresetsIndex = (plasmoid.configuration.switchPresetsIndex + 1) % switchPresets.length;
                console.log(plasmoid.configuration.switchPresetsIndex);
                plasmoid.configuration.writeConfig();
                applyPreset(switchPresets[plasmoid.configuration.switchPresetsIndex]);
                break;
            case (Enum.WidgetClickModes.ShowPopup):
                console.log("Popup");
                main.expanded = !main.expanded;
                break;
            }
        }
    }

    // toolTipMainText: onDesktop ? "" :
    toolTipSubText: {
        let text = "";
        if (onDesktop) {
            text = "<font color='" + Kirigami.Theme.neutralTextColor + "'>Panel not found, this widget must be child of a panel</font>";
        } else if (plasmoid.configuration.isEnabled) {
            const name = plasmoid.configuration.lastPreset.split("/");
            if (name.length) {
                text = i18n("Last preset loaded:") + " " + name[name.length - 1];
            }
        }
        return text;
    }
    toolTipTextFormat: Text.PlainText

    function updatePlasmoidStatus() {
        Plasmoid.status = (editMode || !hideWidget || !runningLatest) ? PlasmaCore.Types.ActiveStatus : PlasmaCore.Types.HiddenStatus;
    }

    onHideWidgetChanged: updatePlasmoidStatus()

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

    Component {
        id: popupView
        ColumnLayout {
            Layout.minimumWidth: main.Kirigami.Units.gridUnit * 25
            Layout.minimumHeight: main.Kirigami.Units.gridUnit * 25
            Layout.maximumWidth: main.Kirigami.Units.gridUnit * 25
            Layout.maximumHeight: main.Kirigami.Units.gridUnit * 25

            property string presetsDir: StandardPaths.writableLocation(StandardPaths.HomeLocation).toString().substring(7) + "/.config/panel-colorizer/presets"
            property string cratePresetsDirCmd: "mkdir -p " + presetsDir
            property string presetsBuiltinDir: Qt.resolvedUrl("./presets").toString().substring(7) + "/"
            property string toolsDir: Qt.resolvedUrl("./tools").toString().substring(7) + "/"
            property string listUserPresetsCmd: "'" + toolsDir + "list_presets.sh' '" + presetsDir + "'"
            property string listBuiltinPresetsCmd: "'" + toolsDir + "list_presets.sh' '" + presetsBuiltinDir + "' b"
            property string listPresetsCmd: listBuiltinPresetsCmd + ";" + listUserPresetsCmd

            ListModel {
                id: presetsModel
            }

            RunCommand {
                id: listPresets
            }

            Component.onCompleted: {
                listPresets.run(listPresetsCmd);
            }

            Connections {
                target: listPresets
                function onExited(cmd, exitCode, exitStatus, stdout, stderr) {
                    if (exitCode !== 0) {
                        console.error(cmd, exitCode, exitStatus, stdout, stderr);
                        return;
                    }
                    if (cmd === listPresetsCmd) {
                        if (stdout.length === 0)
                            return;
                        const out = stdout.trim().split("\n");
                        for (const line of out) {
                            let builtin = false;
                            const parts = line.split(":");
                            const path = parts[parts.length - 1];
                            let name = path.split("/");
                            name = name[name.length - 1];
                            const dir = parts[1];
                            if (line.startsWith("b:")) {
                                builtin = true;
                            }
                            presetsModel.append({
                                "name": name,
                                "value": dir
                            });
                        }
                    }
                }
            }
            ColumnLayout {
                visible: main.runningLatest
                PlasmaComponents.Label {
                    text: i18n("Select a preset")
                    Layout.fillWidth: true
                    font.weight: Font.DemiBold
                    Layout.leftMargin: Kirigami.Units.smallSpacing
                }

                ListView {
                    id: listView
                    clip: true
                    // Layout.preferredWidth: Kirigami.Units.gridUnit * 10
                    // Layout.preferredHeight: Kirigami.Units.gridUnit * 12
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: presetsModel
                    delegate: PlasmaComponents.ItemDelegate {
                        width: ListView.view.width
                        required property string name
                        required property string value
                        contentItem: RowLayout {
                            spacing: Kirigami.Units.smallSpacing
                            PlasmaComponents.Label {
                                Layout.fillWidth: true
                                text: name
                                textFormat: Text.PlainText
                                elide: Text.ElideRight
                            }
                        }

                        onClicked: {
                            applyPreset(value);
                        }
                    }
                }
            }

            ColumnLayout {
                visible: !main.runningLatest
                PlasmaExtras.PlaceholderMessage {
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                    Layout.margins: Kirigami.Units.gridUnit
                    iconName: "dialog-warning"
                    text: i18n("Running outdated version of %1", Plasmoid.metaData.name)
                }

                PlasmaComponents.Label {
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                    Layout.margins: Kirigami.Units.gridUnit
                    text: i18n("Running version of the widget (%1) is different to the one on disk (%2), please log out and back in (or restart plasmashell user unit) to ensure things work correctly!", Plasmoid.metaData.version, main.localVersion.version)
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                }
            }
        }
    }

    property var localVersion: new VersionUtil.Version("999.999.999") // to assume latest
    property string metadataFile: Qt.resolvedUrl("../../metadata.json").toString().substring(7)
    property string localVersionCmd: `cat '${metadataFile}' | grep \\"Version | sed 's/.* //;s/[",]//g'`
    property bool runningLatest: true
    RunCommand {
        id: versionChecker
        onExited: (cmd, exitCode, exitStatus, stdout, stderr) => {
            if (exitCode !== 0) {
                console.error(cmd, exitCode, exitStatus, stdout, stderr);
                return;
            }
            if (stdout) {
                main.localVersion = new VersionUtil.Version(stdout.trim());
                main.runningLatest = main.localVersion.isEqual(Plasmoid.metaData.version);
            }
        }
    }
    Timer {
        running: true
        interval: 5000
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            versionChecker.run(main.localVersionCmd);
        }
    }

    Component {
        id: desktopView
        Item {
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
                    text: "<font color='" + Kirigami.Theme.neutralTextColor + "'>" + i18n("Panel not found, this widget must be placed on a panel to work") + "</font>"
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                }
            }
        }
    }

    fullRepresentation: onDesktop ? desktopView : popupView

    DBusServiceModel {
        id: serviceModel
        enabled: plasmoid.configuration.enableDBusService
    }

    DBusSignalMonitor {
        enabled: plasmoid.configuration.enableDBusService
        service: Plasmoid.metaData.pluginId + ".c" + Plasmoid.containment.id + ".w" + Plasmoid.id
        path: "preset"
        method: "property_changed"
        onSignalReceived: message => {
            if (message) {
                const [path, ...value] = message.split(" ");
                Utils.editProperty(main.cfg, path, value.join(" "));
                plasmoid.configuration.globalSettings = JSON.stringify(main.cfg);
            }
        }
    }

    DBusSignalMonitor {
        enabled: plasmoid.configuration.enableDBusService
        service: Plasmoid.metaData.pluginId + ".c" + Plasmoid.containment.id + ".w" + Plasmoid.id
        path: "preset"
        method: "preset_changed"
        onSignalReceived: message => {
            if (message) {
                applyPreset(message);
            }
        }
    }
    TaskManager.ActivityInfo {
        id: activityInfo
        readonly property string nullUuid: "00000000-0000-0000-0000-000000000000"
    }
}

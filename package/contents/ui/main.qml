pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.taskmanager as TaskManager

import "code/utils.js" as Utils
import "code/globals.js" as Globals
import "code/enum.js" as Enum
import "code/version.js" as VersionUtil
import "./components/" as Components

PlasmoidItem {
    id: main
    property int panelLayoutCount: panelLayout?.children.length || 0
    property int trayGridViewCount: trayGridView?.count || 0
    property int trayGridViewCountOld: 0
    property var panelPosition: {
        var location;
        var screen = main.screen;
        switch (Plasmoid.location) {
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
    property bool onDesktop: Plasmoid.location === PlasmaCore.Types.Floating
    property bool isWayland: Qt.platform.pluginName.includes("wayland")
    property string iconName: (onDesktop || !runningLatest) ? "error" : "icon"
    property string icon: Qt.resolvedUrl("../icons/" + iconName + ".svg").toString().replace("file://", "")
    property bool hideWidget: Plasmoid.configuration.hideWidget
    property bool fixedSidePaddingEnabled: isEnabled && panelBgItem !== null && panelBgItem.cfg.padding.enabled
    property bool floatingDialogs: main.isEnabled ? cfg.nativePanel.floatingDialogs : false
    property bool floatingDialogsAllowOverride: main.isEnabled ? cfg.nativePanel.floatingDialogsAllowOverride : false
    property bool fillAreaOnDeFloat: main.isEnabled ? cfg.nativePanel.fillAreaOnDeFloat : false
    property bool isEnabled: Plasmoid.configuration.isEnabled
    property bool nativePanelBackgroundEnabled: (isEnabled ? cfg.nativePanel.background.enabled : true) || doPanelClickFix
    property real nativePanelBackgroundOpacity: isEnabled ? cfg.nativePanel.background.opacity : 1.0
    property bool nativePanelBackgroundShadowEnabled: isEnabled ? cfg.nativePanel.background.shadow : true
    property bool configureFromAllWidgets: Plasmoid.configuration.configureFromAllWidgets
    property var panelWidgets: []
    // keep track of these to allow others to follow their color
    property Components.CustomBackground panelBgItem
    property Components.CustomBackground trayWidgetBgItem
    property Components.RectangularGrid editingGridItem: null
    property Components.ConfiguringIndicator configuringIndicatorItem: null
    property string lastPreset
    property var presetContent: ""
    property bool animatePropertyChanges: Plasmoid.configuration.animatePropertyChanges
    property int animationDuration: Plasmoid.configuration.animationDuration
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
            globalSettings = JSON.parse(Plasmoid.configuration.globalSettings);
        } catch (e) {
            console.error(e, e.stack);
            globalSettings = Globals.defaultConfig;
        }

        Utils.fixGlobalSettingsV3(globalSettings);
        const config = Utils.mergeConfigs(Globals.defaultConfig, globalSettings);
        const configStr = JSON.stringify(config);
        if (Plasmoid.configuration.globalSettings !== configStr) {
            Plasmoid.configuration.globalSettings = configStr;
            Plasmoid.configuration.writeConfig();
        }
        return config;
    }
    property var presetAutoloading: {
        try {
            return JSON.parse(Plasmoid.configuration.presetAutoloading);
        } catch (e) {
            console.error(e, e.stack);
            return {};
        }
    }
    property var configurationOverrides: {
        let globalOverrides = {};
        try {
            globalOverrides = JSON.parse(Plasmoid.configuration.configurationOverrides);
        } catch (e) {
            console.error(e, e.stack);
        }
        if (!("overrides" in globalOverrides)) {
            globalOverrides.overrides = {};
        }
        Utils.fixConfigurationOverridesV3(globalOverrides.overrides);
        globalOverrides = Utils.mergeConfigs(Globals.defaultConfig.configurationOverrides, globalOverrides);
        const configStr = JSON.stringify(globalOverrides);
        if (Plasmoid.configuration.configurationOverrides !== configStr) {
            Plasmoid.configuration.configurationOverrides = configStr;
            Plasmoid.configuration.writeConfig();
        }
        return globalOverrides;
    }
    property var forceForegroundColor: {
        try {
            return JSON.parse(Plasmoid.configuration.forceForegroundColor);
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
        if (unifiedBackgroundSettings.length) {
            return Utils.makeEven(widgetSettings?.normal?.spacing ?? 4);
        } else {
            return widgetSettings?.normal?.spacing ?? 4;
        }
    }
    property var unifiedBackgroundSettings: Utils.fixV2UnifiedWidgetConfig(Utils.clearOldWidgetConfig(cfg.unifiedBackground))
    onUnifiedBackgroundSettingsChanged: {
        // fix config from v2
        if (Plasmoid.configuration.globalSettings !== JSON.stringify(cfg)) {
            Plasmoid.configuration.globalSettings = JSON.stringify(cfg);
            Plasmoid.configuration.writeConfig();
        }
    }
    property var forceRecolorList: Utils.clearOldWidgetConfig(forceForegroundColor?.widgets ?? [])
    property int forceRecolorInterval: forceForegroundColor?.reloadInterval ?? 0
    property int forceRecolorCount: forceRecolorList.length
    property bool requiresRefresh: forceRecolorList.some(w => w.reload)
    property var panelColorizer: null
    property var blurMask: panelColorizer?.mask ?? null
    property var floatingness: panelElement?.floatingness ?? 0
    property bool panelIsFloating: (panelElement?.floating ?? false) && (floatingness !== 0)
    property var panelWidth: panelElement?.width ?? 0
    property var panelHeight: panelElement?.height ?? 0
    property bool debug: Plasmoid.configuration.enableDebug
    property var plasmaVersion: new VersionUtil.Version("999.999.999") // to assume latest
    property var editModeGridCfg: JSON.parse(Plasmoid.configuration.editModeGridSettings)
    property bool showEditingGrid: (editModeGridCfg?.enabled ?? false) && Plasmoid.userConfiguring
    property bool logSystemTrayIconChanges: Plasmoid.configuration.logSystemTrayIconChanges
    property bool systemTrayIconsReplacementEnabled: Plasmoid.configuration.systemTrayIconsReplacementEnabled
    property var systemTrayIconUserReplacements: {
        let replacements = [];
        try {
            replacements = JSON.parse(Plasmoid.configuration.systemTrayIconUserReplacements);
        } catch (e) {
            console.error(e.message, "\n", e.stack);
        }
        return replacements;
    }
    // Used by Utils.pointToPixel()
    // https://invent.kde.org/plasma/plasma-workspace/-/blob/d5ca4251661b5adfdb9b87a4c932ed6971376cbe/applets/digital-clock/DigitalClock.qml#L133
    property real pixelsPerInch: Screen.pixelDensity * 25.4
    signal recolorCountChanged
    signal refreshNeeded
    signal updateUnified
    signal updateMasks

    property var switchPresets: JSON.parse(Plasmoid.configuration.switchPresets)
    property var panelView: null

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

    onFloatingnessChanged: {
        updateMasks();
        // fixes the mask getting stuck a couple of pixels off for some reason
        if ((main.floatingness === 1 || main.floatingness === 0) && !editMode) {
            Utils.delay(10, () => {
                updateMasks();
            // TODO this forces hidden panels to be always visible and is unclear
            // if it actually helps
            // activatePlasmoidCycle();
            }, main);
        }
    }

    property Component repaintDebugComponent: Components.RepaintDebug {}

    property Component colorEffectComponent: Components.ColorEffect {}

    property Component backgroundComponent: Components.CustomBackground {
        main: main
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

    property Item panelLayoutContainer: {
        if (!panelLayout)
            return null;
        return panelLayout.parent;
    }

    Binding {
        target: main.panelLayoutContainer
        property: "anchors.leftMargin"
        value: main.fixedSidePaddingEnabled ? main.panelBgItem.cfg.padding.side.left : 0
        when: main.fixedSidePaddingEnabled
        delayed: true
    }

    Binding {
        target: main.panelLayoutContainer
        property: "anchors.rightMargin"
        value: main.fixedSidePaddingEnabled ? main.panelBgItem.cfg.padding.side.right : 0
        when: main.fixedSidePaddingEnabled
        delayed: true
    }

    Binding {
        target: main.panelLayoutContainer
        property: "anchors.topMargin"
        value: main.fixedSidePaddingEnabled ? main.panelBgItem.cfg.padding.side.top : 0
        when: main.fixedSidePaddingEnabled
        delayed: true
    }

    Binding {
        target: main.panelLayoutContainer
        property: "anchors.bottomMargin"
        value: main.fixedSidePaddingEnabled ? main.panelBgItem.cfg.padding.side.bottom : 0
        when: main.fixedSidePaddingEnabled
        delayed: true
    }

    Binding {
        target: main.panelElement
        property: "panelMask"
        value: main.blurMask
        when: (main.panelColorizer !== null && main.blurMask && main.panelColorizer?.hasRegions && (main.panelBgItem.cfg.blurBehind || main.anyWidgetDoingBlur || main.anyTrayItemDoingBlur))
    }

    Binding {
        target: main.panelElement
        property: "topShadowMargin"
        value: main.panelView !== null ? -main.panelView.height - 8 : 0
        when: (!main.nativePanelBackgroundShadowEnabled && main.panelView !== null)
    }

    Binding {
        target: main.panelElement
        property: "bottomShadowMargin"
        value: main.panelView !== null ? -main.panelView.height - 8 : 0
        when: (!main.nativePanelBackgroundShadowEnabled && main.panelView !== null)
    }

    // The panel doesn't like having its spacings set to 0
    // while adding/dragging widgets in edit mode, so temporary restore them
    Binding {
        target: main.panelLayout
        property: "columnSpacing"
        value: main.widgetsSpacing
        when: !main.editMode
    }

    Binding {
        target: main.panelLayout
        property: "rowSpacing"
        value: main.widgetsSpacing
        when: !main.editMode
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
            const name = child.applet.Plasmoid.pluginName;
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

    property var containmentItem: {
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

    property Component gridComponent: Components.RectangularGrid {
        id: gridComponent
        property var gridConfig: main.editModeGridCfg
        backgroundColor: gridConfig.background.color
        backgroundOpacity: gridConfig.background.alpha

        minorLineColor: gridConfig.minorLine.color
        minorLineOpacity: gridConfig.minorLine.alpha

        majorLineColor: gridConfig.majorLine.color
        majorLineOpacity: gridConfig.majorLine.alpha

        spacing: gridConfig.spacing
        majorLineEvery: gridConfig.majorLineEvery
    }

    property Component configuringIndicatorComponent: Components.ConfiguringIndicator {}

    onNativePanelBackgroundOpacityChanged: {
        Utils.panelOpacity(panelElement, isEnabled, nativePanelBackgroundOpacity);
    }

    Behavior on nativePanelBackgroundOpacity {
        enabled: main.animatePropertyChanges
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
            main.doPanelLengthFix = true;
            Utils.delay(200, () => {
                main.doPanelLengthFix = false;
                main.reconfigure();
            }, main);
        }
    }

    Binding {
        target: main.panelLayout
        property: "columnSpacing"
        value: 0
        when: main.doPanelLengthFix
    }

    Binding {
        target: main.panelLayout
        property: "rowSpacing"
        value: 0
        when: main.doPanelLengthFix
    }

    onPanelLayoutCountChanged: {
        // console.log("onPanelLayoutCountChanged")
        initAll();
        // re-apply customizations after the widget stops being dragged around
        if (!panelLayout?.children.length) {
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

    property Timer trayInitTimer: Timer {
        interval: 100
        onTriggered: {
            if (main.trayGridView && main.trayGridViewCount !== 0) {
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
            editingGridItem = gridComponent.createObject(main.panelView, {
                "z": -999
            });
        } else if (!showEditingGrid && editingGridItem !== null) {
            editingGridItem.destroy();
            editingGridItem = null;
        }
    }

    Plasmoid.onUserConfiguringChanged: {
        if (Plasmoid.userConfiguring && configuringIndicatorItem == null) {
            configuringIndicatorItem = configuringIndicatorComponent.createObject(main.panelBg, {
                "z": 999
            });
        } else if (!Plasmoid.userConfiguring && configuringIndicatorItem !== null) {
            configuringIndicatorItem.destroy();
            configuringIndicatorItem = null;
        }
    }

    function updateCurrentWidgets() {
        panelWidgets = [];
        panelWidgets = Utils.findWidgets(panelLayout, panelWidgets);
        if (trayGridView) {
            panelWidgets = Utils.findWidgetsTray(trayGridView, panelWidgets);
            panelWidgets = Utils.findWidgetsTray(trayGridView.parent, panelWidgets);
        }
        Plasmoid.configuration.panelWidgets = JSON.stringify(panelWidgets, null, null);
        Plasmoid.configuration.writeConfig();
    }

    PlasmaCore.Action {
        id: configureAction
        text: Plasmoid.internalAction("configure").text
        objectName: "panelColorizerConfigureAction"
        icon.name: 'configure'
        onTriggered: Plasmoid.internalAction("configure").trigger()
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

            if (child.applet.Plasmoid.pluginName === Plasmoid.metaData.pluginId) {
                continue;
            }
            child.applet.Plasmoid.contextualActions = child.applet.Plasmoid.contextualActions.filter(item => {
                if (item && item.objectName === "panelColorizerConfigureAction") {
                    return false;
                }
                return true;
            });
            if (enabled) {
                child.applet.Plasmoid.contextualActions.push(configureAction);
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
        if (Plasmoid.configuration.pluginFound !== pluginFound) {
            Plasmoid.configuration.pluginFound = pluginFound;
            Plasmoid.configuration.writeConfig();
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
        filterByActive: main.presetAutoloading.filterByActive ?? false
        filterByScreen: main.presetAutoloading.filterByScreen ?? true
        trackLastActive: main.presetAutoloading.trackLastActive ?? true
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
                    main.presetContent = JSON.parse(stdout);
                } catch (e) {
                    console.error(`Error reading preset (${cmd}): ${e}`);
                    return;
                }
                Utils.loadPreset(main.presetContent, Plasmoid.configuration, Globals.ignoredConfigs, Globals.defaultConfig, true);
                Plasmoid.configuration.lastPreset = main.lastPreset;
                Plasmoid.configuration.writeConfig();
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
        running: main.requiresRefresh
        repeat: true
        interval: main.forceRecolorInterval
        onTriggered: {
            main.refreshNeeded();
        }
    }

    activationTogglesExpanded: false
    onExpandedChanged: {
        if (Plasmoid.configuration.widgetClickMode !== Enum.WidgetClickModes.ShowPopup) {
            main.expanded = false;
        }
    }

    function widgetClickAction() {
        switch (Plasmoid.configuration.widgetClickMode) {
        case (Enum.WidgetClickModes.TogglePanelColorizer):
            console.log("Toggle Pane Colorizer");
            Plasmoid.configuration.isEnabled = !Plasmoid.configuration.isEnabled;
            Plasmoid.configuration.writeConfig();
            break;
        case (Enum.WidgetClickModes.SwitchPresets):
            console.log("Switch presets");
            Plasmoid.configuration.switchPresetsIndex = (Plasmoid.configuration.switchPresetsIndex + 1) % main.switchPresets.length;
            console.log(Plasmoid.configuration.switchPresetsIndex);
            Plasmoid.configuration.writeConfig();
            main.applyPreset(main.switchPresets[Plasmoid.configuration.switchPresetsIndex]);
            break;
        case (Enum.WidgetClickModes.ShowPopup):
            console.log("Popup");
            main.expanded = !main.expanded;
            break;
        }
    }

    preferredRepresentation: compactRepresentation

    compactRepresentation: CompactRepresentation {
        icon: main.icon
        onWidgetClicked: {
            main.widgetClickAction();
        }
    }

    // toolTipMainText: onDesktop ? "" :
    toolTipSubText: {
        let text = "";
        if (onDesktop) {
            text = "<font color='" + Kirigami.Theme.neutralTextColor + "'>Panel not found, this widget must be child of a panel</font>";
        } else if (Plasmoid.configuration.isEnabled) {
            const name = Plasmoid.configuration.lastPreset.split("/");
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

    property PlasmaCore.Action hideWidgetAction: PlasmaCore.Action {
        text: i18n("Hide widget (visible in panel Edit Mode)")
        checkable: true
        icon.name: "visibility-symbolic"
        checked: Plasmoid.configuration.hideWidget
        onTriggered: {
            Plasmoid.configuration.hideWidget = checked;
            Plasmoid.configuration.writeConfig();
        }
    }

    Plasmoid.contextualActions: [hideWidgetAction]

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

    property Component popupView: Components.PopupView {
        main: main
    }
    property Component desktopView: Components.DesktopView {
        main: main
    }

    fullRepresentation: onDesktop ? desktopView : popupView

    DBusServiceModel {
        id: serviceModel
        enabled: Plasmoid.configuration.enableDBusService
    }

    DBusSignalMonitor {
        enabled: Plasmoid.configuration.enableDBusService
        service: Plasmoid.metaData.pluginId + ".c" + Plasmoid.containment.id + ".w" + Plasmoid.id
        path: "preset"
        method: "property_changed"
        onSignalReceived: message => {
            if (message) {
                const [path, ...value] = message.split(" ");
                Utils.editProperty(main.cfg, path, value.join(" "));
                Plasmoid.configuration.globalSettings = JSON.stringify(main.cfg);
            }
        }
    }

    DBusSignalMonitor {
        enabled: Plasmoid.configuration.enableDBusService
        service: Plasmoid.metaData.pluginId + ".c" + Plasmoid.containment.id + ".w" + Plasmoid.id
        path: "preset"
        method: "preset_changed"
        onSignalReceived: message => {
            if (message) {
                main.applyPreset(message);
            }
        }
    }
    TaskManager.ActivityInfo {
        id: activityInfo
        readonly property string nullUuid: "00000000-0000-0000-0000-000000000000"
    }

    Plasmoid.onActivated: {
        main.widgetClickAction();
    }
}

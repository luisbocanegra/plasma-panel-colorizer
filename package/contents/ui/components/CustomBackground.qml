import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import "../code/utils.js" as Utils
import "../code/statusNotifierItemIconRules.js" as SNIIconRules
import "../"

Rectangle {
    id: rect
    property var target
    property int targetIndex
    property var main
    property bool animatePropertyChanges: Plasmoid.configuration.animatePropertyChanges
    property int animationDuration: Plasmoid.configuration.animationDuration
    property int animationEasingType: Easing.OutCubic
    property bool horizontal: main.horizontal
    // use an extra id so we can track the panel and items in tray separately
    // e.g panel[0, widget[1] widget[2] trayWidget[3 [widget[5], widget[6], widget[7]]] widget[4]]
    property int maskIndex: {
        if (isPanel) {
            return 0;
        } else {
            return (inTray ? (main.panelLayoutCount - 1 + targetIndex) : targetIndex + 1);
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
            const systemTrayState = Utils.getSystemTrayState(main.trayWidgetBgItem?.target?.applet, main.plasmaVersion);
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
    property var wRecolorCfg: Utils.getForceFgWidgetConfig(widgetId, widgetName, main.forceRecolorList)
    property bool requiresRefresh: wRecolorCfg?.reload ?? false
    // 0: default | 1: start | 2: end
    property var wUnifyCfg: Utils.getForceFgWidgetConfig(widgetId, widgetName, main.unifiedBackgroundSettings)
    property int unifySection: wUnifyCfg?.unifyBgType ?? 0

    // 0: default | 1: start | 2: middle | 3: end
    property int unifyBgType: main.unifiedBackgroundFinal.find(item => item.index === maskIndex)?.type ?? 0
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
    property bool cfgEnabled: cfg.enabled && main.isEnabled
    property bool bgEnabled: bgColorCfg.enabled
    property bool fgEnabled: fgColorCfg.enabled
    property var fontCfg: cfg.fontConfig
    onFontCfgChanged: {
        recolorTimer.restart();
    }
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
    topRightRadius: (!radiusEnabled || (rect.horizontal && (unifyBgType === 1 || unifyBgType === 2)) || (!rect.horizontal && (unifyBgType === 2 || unifyBgType === 3)) || cornerForcedZero("topRight")) ? 0 : cfg.radius.corner.topRight ?? 0

    bottomLeftRadius: (!radiusEnabled || (rect.horizontal && (unifyBgType === 2 || unifyBgType === 3)) || (!rect.horizontal && (unifyBgType === 1 || unifyBgType === 2)) || cornerForcedZero("bottomLeft")) ? 0 : cfg.radius.corner.bottomLeft ?? 0

    bottomRightRadius: (!radiusEnabled || unifyBgType === 1 || unifyBgType === 2 || (!rect.horizontal && (unifyBgType === 1 || unifyBgType === 2)) || cornerForcedZero("bottomRight")) ? 0 : cfg.radius.corner.bottomRight ?? 0

    property bool marginEnabled: cfg.margin.enabled && cfgEnabled
    property bool borderEnabled: cfg.border.enabled && cfgEnabled
    property bool bgShadowEnabled: cfg.shadow.background.enabled && cfgEnabled
    property var bgShadow: cfg.shadow.background
    property bool fgShadowEnabled: cfg.shadow.foreground.enabled && cfgEnabled
    property var fgShadow: cfg.shadow.foreground
    property bool blurBehind: {
        return (isPanel && !main.anyWidgetDoingBlur && !main.anyTrayItemDoingBlur) || (isWidget) || (inTray && !main.trayWidgetBgItem?.blurBehind) ? cfg.blurBehind : false;
    }
    property string fgColor: {
        if (inTray && fgEnabled && cfgEnabled) {
            return Utils.getColor(fgColorCfg, targetIndex, color, itemType, fgColorHolder);
        }
        if (inTray && (!fgEnabled || !cfgEnabled) && main.trayWidgetBgItem?.cfgEnabled && main.trayWidgetBgItem?.fgColorCfg?.enabled) {
            return main.trayWidgetBgItem?.fgColor;
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
        Kirigami.Theme.colorSet: Kirigami.Theme[rect.fgColorCfg.systemColorSet]
    }

    Behavior on topLeftRadius {
        enabled: rect.animatePropertyChanges
        NumberAnimation {
            duration: rect.animationDuration
            easing.type: rect.animationEasingType
        }
    }
    Behavior on topRightRadius {
        enabled: rect.animatePropertyChanges
        NumberAnimation {
            duration: rect.animationDuration
            easing.type: rect.animationEasingType
        }
    }
    Behavior on bottomLeftRadius {
        enabled: rect.animatePropertyChanges
        NumberAnimation {
            duration: rect.animationDuration
            easing.type: rect.animationEasingType
        }
    }
    Behavior on bottomRightRadius {
        enabled: rect.animatePropertyChanges
        NumberAnimation {
            duration: rect.animationDuration
            easing.type: rect.animationEasingType
        }
    }

    Kirigami.Theme.colorSet: Kirigami.Theme[bgColorCfg.systemColorSet]
    color: {
        if (bgEnabled && rect.bgColorCfg.sourceType !== 5) {
            return Utils.getColor(bgColorCfg, targetIndex, null, itemType, rect);
        } else {
            return "transparent";
        }
    }

    GradientRoundedRectangle {
        stops: rect.bgColorCfg.gradient?.stops || []
        visible: rect.bgColorCfg.sourceType === 5 && rect.bgColorCfg.gradient?.stops && rect.bgEnabled
        orientation: rect.bgColorCfg.gradient?.orientation === 0 ? Gradient.Horizontal : Gradient.Vertical
        corners: {
            "topLeftRadius": rect.topLeftRadius,
            "topRightRadius": rect.topRightRadius,
            "bottomLeftRadius": rect.bottomLeftRadius,
            "bottomRightRadius": rect.bottomRightRadius
        }
    }

    ImageRoundedRectangle {
        source: visible ? rect.bgColorCfg.image?.source : ""
        visible: rect.bgColorCfg.sourceType === 6 && rect.bgColorCfg.image?.source && rect.bgEnabled
        fillMode: rect.bgColorCfg.image?.fillMode !== undefined ? rect.bgColorCfg.image?.fillMode : Image.PreserveAspectCrop
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
        enabled: rect.animatePropertyChanges
        ColorAnimation {
            duration: rect.animationDuration
            easing.type: rect.animationEasingType
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
            if (rect.isPanel)
                return;
            if (rect.isTray && rect.main.trayWidgetSettings.normal.foregroundColor.enabled)
                return;
            const result = Utils.applyFgColor(rect.target, rect.fgColor, rect.fgColorCfg, 0, rect.wRecolorCfg, rect.fgColorModified, rect.fontCfg);
            if (result) {
                rect.itemCount = result.count;
                rect.maxDepth = result.depth;
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
        main.trayInitTimer.restart();
    }

    height: inTray ? (target?.height ?? 0) : parent.height
    width: inTray ? (target?.width ?? 0) : parent.width
    Behavior on height {
        enabled: rect.animatePropertyChanges
        NumberAnimation {
            duration: rect.animationDuration
            easing.type: rect.animationEasingType
        }
    }
    Behavior on width {
        enabled: rect.animatePropertyChanges
        NumberAnimation {
            duration: rect.animationDuration
            easing.type: rect.animationEasingType
        }
    }
    anchors.centerIn: (inTray || isTrayArrow) ? parent : undefined
    anchors.fill: (isPanel || inTray || isTrayArrow) ? parent : undefined

    property int extraLSpacing: ((unifyBgType === 2 || unifyBgType === 3) && rect.horizontal ? main.widgetsSpacing : 0) / 2
    property int extraRSpacing: ((unifyBgType === 1 || unifyBgType === 2) && rect.horizontal ? main.widgetsSpacing : 0) / 2
    property int extraTSpacing: ((unifyBgType === 2 || unifyBgType === 3) && !rect.horizontal ? main.widgetsSpacing : 0) / 2
    property int extraBSpacing: ((unifyBgType === 1 || unifyBgType === 2) && !rect.horizontal ? main.widgetsSpacing : 0) / 2

    property int marginLeft: (marginEnabled ? cfg.margin.side.left : 0) + extraLSpacing
    property int marginRight: (marginEnabled ? cfg.margin.side.right : 0) + extraRSpacing
    property int horizontalWidth: marginLeft + marginRight

    property int marginTop: (marginEnabled ? cfg.margin.side.top : 0) + extraTSpacing
    property int marginBottom: (marginEnabled ? cfg.margin.side.bottom : 0) + extraBSpacing
    property int verticalWidth: marginTop + marginBottom

    Behavior on horizontalWidth {
        enabled: rect.animatePropertyChanges
        NumberAnimation {
            duration: rect.animationDuration
            easing.type: rect.animationEasingType
        }
    }
    Behavior on verticalWidth {
        enabled: rect.animatePropertyChanges
        NumberAnimation {
            duration: rect.animationDuration
            easing.type: rect.animationEasingType
        }
    }

    Binding {
        target: rect
        property: "x"
        value: -rect.marginLeft
        when: rect.isWidget && rect.horizontal
        delayed: true
    }

    Binding {
        target: rect
        property: "y"
        value: -rect.marginTop
        when: rect.isWidget && !rect.horizontal
        delayed: true
    }

    Binding {
        target: rect
        property: "width"
        value: (rect.parent?.width ?? 0) + rect.horizontalWidth
        when: rect.isWidget && rect.horizontal
        delayed: true
    }

    Binding {
        target: rect
        property: "height"
        value: (rect.parent?.height ?? 0) + rect.verticalWidth
        when: rect.isWidget && !rect.horizontal
        delayed: true
    }

    Binding {
        target: rect.target
        property: "Layout.leftMargin"
        value: rect.marginLeft - rect.extraLSpacing
        when: rect.isWidget && (rect.marginEnabled || rect.extraLSpacing !== 0)
        delayed: true
    }

    Binding {
        target: rect.target
        property: "Layout.rightMargin"
        value: rect.marginRight - rect.extraRSpacing
        when: rect.isWidget && (rect.marginEnabled || rect.extraRSpacing !== 0)
        delayed: true
    }

    Binding {
        target: rect.target
        property: "Layout.topMargin"
        value: rect.marginTop - rect.extraTSpacing
        when: rect.isWidget && (rect.marginEnabled || rect.extraTSpacing !== 0)
        delayed: true
    }

    Binding {
        target: rect.target
        property: "Layout.bottomMargin"
        value: rect.marginBottom - rect.extraBSpacing
        when: rect.isWidget && (rect.marginEnabled || rect.extraBSpacing !== 0)
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
            if (rect.main.fillAreaOnDeFloat && rect.main.panelElement?.floating && (rect.main.panelElement?.floatingness !== 1)) {
                margin -= (8 * (1 - rect.main.panelElement?.floatingness));
            }
            return margin;
        }
        when: rect.isPanel && rect.main.isEnabled
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
            if (rect.main.fillAreaOnDeFloat && rect.main.panelElement?.floating && (rect.main.panelElement?.floatingness !== 1)) {
                margin -= (8 * (1 - rect.main.panelElement?.floatingness));
            }
            return margin;
        }
        when: rect.isPanel && rect.main.isEnabled
        delayed: true
    }

    Binding {
        target: rect.target
        property: "anchors.topMargin"
        value: rect.marginEnabled ? rect.marginTop : 0
        when: rect.isPanel
        delayed: true
    }

    Binding {
        target: rect.target
        property: "anchors.bottomMargin"
        value: rect.marginEnabled ? rect.marginBottom : 0
        when: rect.isPanel
        delayed: true
    }

    // Tray item / arrow

    Binding {
        target: rect
        property: "anchors.leftMargin"
        value: rect.marginLeft
        when: rect.marginEnabled && rect.inTray
        delayed: true
    }

    Binding {
        target: rect
        property: "anchors.rightMargin"
        value: rect.marginRight
        when: rect.marginEnabled && rect.inTray
        delayed: true
    }

    Binding {
        target: rect
        property: "anchors.topMargin"
        value: rect.marginTop
        when: rect.marginEnabled && rect.inTray
        delayed: true
    }

    Binding {
        target: rect
        property: "anchors.bottomMargin"
        value: rect.marginBottom
        when: rect.marginEnabled && rect.inTray
        delayed: true
    }

    // fix tray weird margin
    Binding {
        target: rect.target
        property: "Layout.leftMargin"
        value: -2
        when: rect.marginEnabled && rect.isTrayArrow && rect.horizontal
        delayed: true
    }

    Binding {
        target: rect.target
        property: "Layout.rightMargin"
        value: 2
        when: rect.marginEnabled && rect.isTrayArrow && rect.horizontal
        delayed: true
    }

    Binding {
        target: rect.target
        property: "Layout.topMargin"
        value: -2
        when: rect.marginEnabled && rect.isTrayArrow && !rect.horizontal
        delayed: true
    }

    Binding {
        target: rect.target
        property: "Layout.bottomMargin"
        value: 2
        when: rect.marginEnabled && rect.isTrayArrow && !rect.horizontal
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
        when: (rect.hideCfg?.hide ?? false) && !rect.main.editMode
        value: PlasmaCore.Types.HiddenStatus
    }

    Item {
        anchors.fill: parent
        CustomBorder {
            id: borderRec
            visible: rect.borderEnabled && Math.min(rect.height, rect.width) > 1
            Behavior on borderColor {
                enabled: rect.animatePropertyChanges
                ColorAnimation {
                    duration: rect.animationDuration
                    easing.type: rect.animationEasingType
                }
            }
            horizontal: rect.horizontal
            unifyBgType: rect.unifyBgType
            corners: {
                "topLeftRadius": rect.topLeftRadius,
                "topRightRadius": rect.topRightRadius,
                "bottomLeftRadius": rect.bottomLeftRadius,
                "bottomRightRadius": rect.bottomRightRadius
            }
            cfgBorder: rect.cfg.border
            panelTouchingTop: rect.panelTouchingTop
            panelTouchingBottom: rect.panelTouchingBottom
            panelTouchingLeft: rect.panelTouchingLeft
            panelTouchingRight: rect.panelTouchingRight
            flattenPanelBordersOnEdge: rect.cfg.flattenOnDeFloat ?? false
            borderColor: {
                return Utils.getColor(rect.cfg.border.color, rect.targetIndex, rect.color, rect.itemType, borderRec);
            }
        }

        CustomBorder {
            id: borderSecondary
            property real parentBorderLeft: rect.cfg.border.customSides ? rect.cfg.border.custom.widths.left : rect.cfg.border.width
            property real parentBorderRight: rect.cfg.border.customSides ? rect.cfg.border.custom.widths.right : rect.cfg.border.width
            property real parentBorderTop: rect.cfg.border.customSides ? rect.cfg.border.custom.widths.top : rect.cfg.border.width
            property real parentBorderBottom: rect.cfg.border.customSides ? rect.cfg.border.custom.widths.bottom : rect.cfg.border.width
            property real extraLMargin: ((rect.unifyBgType === 2 || rect.unifyBgType === 3) && rect.horizontal) ? 0 : parentBorderLeft
            property real extraRMargin: ((rect.unifyBgType === 1 || rect.unifyBgType === 2) && rect.horizontal) ? 0 : parentBorderRight
            property real extraTMargin: ((rect.unifyBgType === 2 || rect.unifyBgType === 3) && !rect.horizontal) ? 0 : parentBorderTop
            property real extraBMargin: ((rect.unifyBgType === 1 || rect.unifyBgType === 2) && !rect.horizontal) ? 0 : parentBorderBottom
            anchors.topMargin: rect.cfg.border.enabled ? extraTMargin : 0
            anchors.bottomMargin: rect.cfg.border.enabled ? extraBMargin : 0
            anchors.leftMargin: rect.cfg.border.enabled ? extraLMargin : 0
            anchors.rightMargin: rect.cfg.border.enabled ? extraRMargin : 0
            visible: rect.cfg.borderSecondary.enabled && rect.cfgEnabled && Math.min(rect.height, rect.width) > 1
            Behavior on borderColor {
                enabled: rect.animatePropertyChanges
                ColorAnimation {
                    duration: rect.animationDuration
                    easing.type: rect.animationEasingType
                }
            }
            horizontal: rect.horizontal
            unifyBgType: rect.unifyBgType
            corners: {
                "topLeftRadius": Math.max(rect.topLeftRadius - rect.cfg.border.width, 0),
                "topRightRadius": Math.max(rect.topRightRadius - rect.cfg.border.width, 0),
                "bottomLeftRadius": Math.max(rect.bottomLeftRadius - rect.cfg.border.width, 0),
                "bottomRightRadius": Math.max(rect.bottomRightRadius - rect.cfg.border.width, 0)
            }
            cfgBorder: rect.cfg.borderSecondary
            panelTouchingTop: rect.panelTouchingTop
            panelTouchingBottom: rect.panelTouchingBottom
            panelTouchingLeft: rect.panelTouchingLeft
            panelTouchingRight: rect.panelTouchingRight
            flattenPanelBordersOnEdge: rect.cfg.flattenOnDeFloat ?? false
            borderColor: {
                return Utils.getColor(rect.cfg.borderSecondary.color, rect.targetIndex, rect.color, rect.itemType, borderSecondary);
            }
        }

        layer.enabled: rect.cfg.border.customSides
        layer.effect: OpacityMask {
            maskSource: Item {
                id: mask
                required property var rect
                width: rect.width
                height: rect.height
                Rectangle {
                    anchors.fill: parent
                    topLeftRadius: mask.rect.topLeftRadius
                    topRightRadius: mask.rect.topRightRadius
                    bottomLeftRadius: mask.rect.bottomLeftRadius
                    bottomRightRadius: mask.rect.bottomRightRadius
                }
            }
        }
    }

    Kirigami.ShadowedRectangle {
        id: backgroundShadow
        anchors.fill: parent
        color: "transparent"
        z: -1
        property var shadowColorCfg: rect.bgShadow.color
        corners {
            topLeftRadius: rect.topLeftRadius
            topRightRadius: rect.topRightRadius
            bottomLeftRadius: rect.bottomLeftRadius
            bottomRightRadius: rect.bottomRightRadius
        }
        shadow {
            Kirigami.Theme.colorSet: Kirigami.Theme[shadowColorCfg.systemColorSet]
            size: (rect.bgShadowEnabled && Math.min(rect.height, rect.width) > 1) ? rect.bgShadow.size : 0
            color: {
                return Utils.getColor(shadowColorCfg, rect.targetIndex, rect.color, rect.itemType, backgroundShadow.shadow);
            }
            xOffset: rect.bgShadow.xOffset
            yOffset: rect.bgShadow.yOffset

            Behavior on size {
                enabled: rect.animatePropertyChanges
                NumberAnimation {
                    duration: rect.animationDuration
                    easing.type: rect.animationEasingType
                }
            }
            Behavior on xOffset {
                enabled: rect.animatePropertyChanges
                NumberAnimation {
                    duration: rect.animationDuration
                    easing.type: rect.animationEasingType
                }
            }
            Behavior on yOffset {
                enabled: rect.animatePropertyChanges
                NumberAnimation {
                    duration: rect.animationDuration
                    easing.type: rect.animationEasingType
                }
            }
            Behavior on color {
                enabled: rect.animatePropertyChanges
                ColorAnimation {
                    duration: rect.animationDuration
                    easing.type: rect.animationEasingType
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
        required property var unifyBgType
        required property var horizontal
        required property var ps
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
        anchors.leftMargin: rect.horizontal ? rect.marginLeft : undefined
        anchors.rightMargin: rect.horizontal ? rect.marginRight : undefined
        anchors.topMargin: rect.horizontal ? undefined : rect.marginTop
        anchors.bottomMargin: rect.horizontal ? undefined : rect.marginBottom
        property var shadowColorCfg: rect.fgShadow.color
        Kirigami.Theme.colorSet: Kirigami.Theme[shadowColorCfg.systemColorSet]
        horizontalOffset: rect.fgShadow.xOffset
        verticalOffset: rect.fgShadow.yOffset
        radius: rect.fgShadowEnabled ? rect.fgShadow.size : 0
        samples: radius * 2 + 1
        spread: 0.35
        color: {
            return Utils.getColor(shadowColorCfg, rect.targetIndex, rect.color, rect.itemType, dropShadow);
        }
        source: rect.target?.applet ?? null
        visible: rect.fgShadowEnabled
        Behavior on color {
            enabled: rect.animatePropertyChanges
            ColorAnimation {
                duration: rect.animationDuration
                easing.type: rect.animationEasingType
            }
        }
        Behavior on radius {
            enabled: rect.animatePropertyChanges
            NumberAnimation {
                duration: rect.animationDuration
                easing.type: rect.animationEasingType
            }
        }
        Behavior on horizontalOffset {
            enabled: rect.animatePropertyChanges
            NumberAnimation {
                duration: rect.animationDuration
                easing.type: rect.animationEasingType
            }
        }
        Behavior on verticalOffset {
            enabled: rect.animatePropertyChanges
            NumberAnimation {
                duration: rect.animationDuration
                easing.type: rect.animationEasingType
            }
        }
    }

    property real blurMaskX: {
        const marginLeft = rect.marginEnabled ? rect.marginLeft : 0;
        if (main.panelElement !== null && main.panelElement.floating && horizontal) {
            if (main.floatingness > 0) {
                return marginLeft;
            } else {
                return (main.panelElement.width - borderRec.width) / 2;
            }
        } else {
            return marginLeft;
        }
    }

    property real blurMaskY: {
        const marginTop = rect.marginEnabled ? rect.marginTop : 0;
        if (main.panelElement !== null && main.panelElement.floating && !horizontal) {
            if (main.floatingness > 0) {
                return marginTop;
            } else {
                return (main.panelElement.height - borderRec.height) / 2;
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
        anchors.bottom: rect.isPanel ? parent.bottom : undefined
        visible: rect.main.debug
        Label {
            text: rect.maskIndex
            font.pixelSize: 8
            Rectangle {
                anchors.fill: parent
                color: "black"
                z: -1
                opacity: 0.5
            }
        }
        Label {
            text: rect.unifySection + "," + rect.unifyBgType//blurBehind+","+anyWidgetDoingBlur //parseInt(position.x)+","+parseInt(position.y)
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
        visible: rect.main.debug
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
        const m = horizontal ? 0 : (main.panelElement?.floating && Plasmoid.location === edge ? 16 : 0);
        return main.floatingness > 0 ? (8 * main.floatingness) : m;
    }

    property real moveY: {
        const edge = main.plasmaVersion.isLowerThan("6.2.0") ? PlasmaCore.Types.TopEdge : PlasmaCore.Types.BottomEdge;
        const m = horizontal ? (main.panelElement?.floating && Plasmoid.location === edge ? 16 : 0) : 0;
        return main.floatingness > 0 ? (8 * main.floatingness) : m;
    }

    onIsVisibleChanged: {
        Qt.callLater(function () {
            main.updateUnified();
            updateMaskDebounced();
        });
    }

    onBlurBehindChanged: {
        if (isWidget) {
            main.widgetsDoingBlur[maskIndex] = blurBehind;
            main.anyWidgetDoingBlur = Object.values(main.widgetsDoingBlur).some(state => state);
        } else if (inTray) {
            main.trayItemsDoingBlur[maskIndex] = blurBehind;
            main.anyTrayItemDoingBlur = Object.values(main.trayItemsDoingBlur).some(state => state);
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
        if (main.panelColorizer === null || !borderRec)
            return;
        // don't try to create a mask if the widget is not visible
        // for example with PlasmaCore.Types.HiddenStatus
        if (borderRec.width <= 0 || borderRec.height <= 0)
            return;
        position = Utils.getGlobalPosition(borderRec, main.panelElement);
        main.panelColorizer.updatePanelMask(maskIndex, borderRec, rect.topLeftRadius, rect.topRightRadius, rect.bottomLeftRadius, rect.bottomRightRadius, Qt.point(rect.positionX - moveX, rect.positionY - moveY), 5, isVisible && blurBehind);
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

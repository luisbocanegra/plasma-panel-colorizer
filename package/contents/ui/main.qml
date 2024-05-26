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
import Qt5Compat.GraphicalEffects

import "components" as Components

PlasmoidItem {
    id: main

    preferredRepresentation: compactRepresentation
    property bool onDesktop: plasmoid.location === PlasmaCore.Types.Floating

    property string iconName: !onDesktop ? "icon" : "error"
    property string icon: Qt.resolvedUrl("../icons/" + iconName + ".svg").toString().replace("file://", "")

    property bool isEnabled: plasmoid.configuration.isEnabled
    property int mode: plasmoid.configuration.mode
    property int colorMode: plasmoid.configuration.colorMode
    property int colorModeTheme: plasmoid.configuration.colorModeTheme
    property color singleColor: plasmoid.configuration.singleColor
    property var customColors: []
    property int bgColorStart:0
    property bool widgetBgEnabled: plasmoid.configuration.widgetBgEnabled
    property real bgOpacity: plasmoid.configuration.opacity
    property int bgRadius: plasmoid.configuration.radius
    property bool bgContrastFixEnabled: plasmoid.configuration.bgContrastFixEnabled
    property bool bgSaturationEnabled: plasmoid.configuration.bgSaturationEnabled
    property real bgSaturation: plasmoid.configuration.bgSaturation
    property real bgLightness: plasmoid.configuration.bgLightness
    property int rainbowInterval: plasmoid.configuration.rainbowInterval
    property int rainbowTransition: plasmoid.configuration.rainbowTransition
    property string blacklist: plasmoid.configuration.blacklist
    property int widgetBgHMargin: plasmoid.configuration.widgetBgHMargin
    property int widgetBgVMargin: plasmoid.configuration.widgetBgVMargin
    property string marginRules: plasmoid.configuration.marginRules
    property bool hideWidget: plasmoid.configuration.hideWidget

    property bool panelBgEnabled: plasmoid.configuration.panelBgEnabled
    property int panelBgColorMode: plasmoid.configuration.panelBgColorMode
    property int panelBgColorModeTheme: plasmoid.configuration.panelBgColorModeTheme
    property string panelBgColor: {
        if (panelBgColorMode === 0) {
            return plasmoid.configuration.panelBgColor
        } else {
            return themeColors[panelBgColorModeTheme]
        }
    }
    property int panelBgColorModeThemeVariant: plasmoid.configuration.panelBgColorModeThemeVariant
    property var panelBgColorScope: {
        return themeScopes[panelBgColorModeThemeVariant]
    }
    property real panelBgOpacity: plasmoid.configuration.panelBgOpacity
    property real panelBgRadius: isFloating ? plasmoid.configuration.panelBgRadius : 0
    property bool hideRealPanelBg: plasmoid.configuration.hideRealPanelBg
    property real panelRealBgOpacity: plasmoid.configuration.panelRealBgOpacity
    property int widgetOutlineColorMode: plasmoid.configuration.widgetOutlineColorMode
    property int widgetOutlineColorModeTheme: plasmoid.configuration.widgetOutlineColorModeTheme
    property real widgetOutlineOpacity: plasmoid.configuration.widgetOutlineOpacity
    property string widgetOutlineColor: {
        if (widgetOutlineColorMode === 0) {
            return plasmoid.configuration.widgetOutlineColor
        } else {
            return themeColors[widgetOutlineColorModeTheme]
        }
    }
    property int widgetOutlineColorModeThemeVariant: plasmoid.configuration.widgetOutlineColorModeThemeVariant
    property var widgetOutlineColorScope: {
        return themeScopes[widgetOutlineColorModeThemeVariant]
    }
    property int widgetOutlineWidth: plasmoid.configuration.widgetOutlineWidth
    property color widgetShadowColor: plasmoid.configuration.widgetShadowColor
    property int widgetShadowSize: plasmoid.configuration.widgetShadowSize
    property int widgetShadowX: plasmoid.configuration.widgetShadowX
    property int widgetShadowY: plasmoid.configuration.widgetShadowY

    property int panelOutlineColorMode: plasmoid.configuration.panelOutlineColorMode
    property int panelOutlineColorModeTheme: plasmoid.configuration.panelOutlineColorModeTheme
    property int panelOutlineWidth: plasmoid.configuration.panelOutlineWidth
    property real panelOutlineOpacity: plasmoid.configuration.panelOutlineOpacity
    property string panelOutlineColor: {
        if (panelOutlineColorMode === 0) {
            return plasmoid.configuration.panelOutlineColor
        } else {
            return themeColors[panelOutlineColorModeTheme]
        }
    }
    property int panelOutlineColorModeThemeVariant: plasmoid.configuration.panelOutlineColorModeThemeVariant
    property var panelOutlineColorScope: {
        return themeScopes[panelOutlineColorModeThemeVariant]
    }
    property color panelShadowColor: plasmoid.configuration.panelShadowColor
    property int panelShadowSize: plasmoid.configuration.panelShadowSize
    property int panelShadowX: plasmoid.configuration.panelShadowX
    property int panelShadowY: plasmoid.configuration.panelShadowY

    property string forceRecolor: plasmoid.configuration.forceRecolor

    property bool isLoaded: false
    // property bool isConfiguring: plasmoid.userConfiguring

    property bool inEditMode: Plasmoid.containment.corona?.editMode ? true : false
    Plasmoid.status: (inEditMode || !hideWidget || showToUpdate) ?
                        PlasmaCore.Types.ActiveStatus :
                        PlasmaCore.Types.HiddenStatus
    property bool widgetConfiguring: Plasmoid.userConfiguring

    property int childCount: 0
    property bool wasEditing: false
    property bool destroyRequired: false

    property var themeColors: [
        "textColor",
        "disabledTextColor",
        "highlightedTextColor",
        "activeTextColor",
        "linkColor",
        "visitedLinkColor",
        "negativeTextColor",
        "neutralTextColor",
        "positiveTextColor",
        "backgroundColor",
        "highlightColor",
        "activeBackgroundColor",
        "linkBackgroundColor",
        "visitedLinkBackgroundColor",
        "negativeBackgroundColor",
        "neutralBackgroundColor",
        "positiveBackgroundColor",
        "alternateBackgroundColor",
        "focusColor",
        "hoverColor"
    ]

    property var themeScopes: [
        "View",
        "Window",
        "Button",
        "Selection",
        "Tooltip",
        "Complementary",
        "Header"
    ]



    property string systemColor: {
        return themeColors[colorModeTheme]
    }

    property int colorModeThemeVariant: plasmoid.configuration.colorModeThemeVariant
    property var widgetBgColorScope: {
        return themeScopes[colorModeThemeVariant]
    }
    property string fgSystemColor: {
        return themeColors[fgColorModeTheme]
    }
    property int fgColorModeThemeVariant: plasmoid.configuration.fgColorModeThemeVariant
    property var fgColorScope: {
        return themeScopes[fgColorModeThemeVariant]
    }

    RowLayout {
        Rectangle {
            id: fgSystemColorHolder
            Kirigami.Theme.colorSet: Kirigami.Theme[main.widgetBgColorScope]
            Kirigami.Theme.inherit: false
            width: 20
            height: 10
            color: {
                return Kirigami.Theme[main.fgSystemColor]
            }
            visible: true
            opacity: 0
        }

        Rectangle {
            id: systemColorHolder
            Kirigami.Theme.colorSet: Kirigami.Theme[main.widgetBgColorScope]
            Kirigami.Theme.inherit: false
            width: 10
            height: 10
            color: {
                return Kirigami.Theme[main.systemColor]
            }
            visible: true
            opacity: 0
        }

        Rectangle {
            id: fgBlacklistColorHolder
            Kirigami.Theme.colorSet: Kirigami.Theme[main.fgBlacklistedColorScope]
            Kirigami.Theme.inherit: false
            width: 10
            height: 10
            color: {
                if (main.blacklistedFgColor.startsWith("#")) {
                    return main.blacklistedFgColor
                } else {
                    return Kirigami.Theme[main.blacklistedFgColor]
                }
            }
            visible: true
            opacity: 0
        }
    }

    property color defaultTextColor: Kirigami.Theme.textColor
    property real fgOpacity: plasmoid.configuration.fgOpacity
    property bool fgColorEnabled: plasmoid.configuration.fgColorEnabled

    property bool fgBlacklistedColorEnabled: plasmoid.configuration.fgBlacklistedColorEnabled
    property int fgBlacklistedColorMode: plasmoid.configuration.fgBlacklistedColorMode
    property int fgBlacklistedColorModeTheme: plasmoid.configuration.fgBlacklistedColorModeTheme
    property string blacklistedFgColor: {
        if (fgBlacklistedColorMode === 0) {
            return plasmoid.configuration.blacklistedFgColor
        } else {
            return themeColors[fgBlacklistedColorModeTheme]
        }
    }
    property int fgBlacklistedColorModeThemeVariant: plasmoid.configuration.fgBlacklistedColorModeThemeVariant
    property var fgBlacklistedColorScope: {
        return themeScopes[fgBlacklistedColorModeThemeVariant]
    }

    property bool showToUpdate: false

    property string runtimeDir: StandardPaths.writableLocation(
                            StandardPaths.RuntimeLocation).toString().substring(7)
    property string schemeFile: runtimeDir + "/PanelColorizer-"+plasmoid.id+".colors"

    property string saveSchemeCmd: "echo '" + schemeContent.text + "' > " + schemeFile

    property int fgMode: plasmoid.configuration.fgMode
    property int fgColorMode: plasmoid.configuration.fgColorMode
    property int fgColorModeTheme: plasmoid.configuration.fgColorModeTheme
    property color fgSingleColor: plasmoid.configuration.fgSingleColor
    property var fgCustomColors: []
    property int fgColorStart: 0
    property bool addingColors: true
    property var currentFgColors: []
    property int fgRainbowInterval: plasmoid.configuration.fgRainbowInterval

    property bool fgContrastFixEnabled: plasmoid.configuration.fgContrastFixEnabled
    property bool fgSaturationEnabled: plasmoid.configuration.fgSaturationEnabled
    property real fgSaturation: plasmoid.configuration.fgSaturation
    property real fgLightness: plasmoid.configuration.fgLightness

    property bool enableCustomPadding: plasmoid.configuration.enableCustomPadding
    property int panelPadding: plasmoid.configuration.panelPadding
    property bool isVertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical
    property var panelPrefixes: ["north","south","west","east"]
    property var panelBg: {
        return panelElement?.children ? panelElement.children.find(function (child) {
            return panelPrefixes.some(function (target) {
                return child.prefix.toString().includes(target)
            })
        }) : null
    }
    property bool isFloating: !panelElement ? false : Boolean(panelElement.floatingness)
    property bool isTouchingWindow: !panelElement ? false : Boolean(panelElement.touchingWindow)

    property ContainmentItem containmentItem: null
    readonly property int depth : 14

    property var panelBGE

    property bool bgLineModeEnabled: plasmoid.configuration.bgLineModeEnabled
    property int bgLinePosition: plasmoid.configuration.bgLinePosition
    property int bgLineWidth: plasmoid.configuration.bgLineWidth
    property int bgLineXOffset: plasmoid.configuration.bgLineXOffset
    property int bgLineYOffset: plasmoid.configuration.bgLineYOffset

    property string presetsDir: StandardPaths.writableLocation(
                    StandardPaths.HomeLocation).toString().substring(7) + "/.config/panel-colorizer/"
    property string listPresetsCmd: "find "+presetsDir+" -type f -print0 | while IFS= read -r -d '' file; do basename \"$file\"; done | sort"
    property var presetContent: ""
    property var ignoredConfigs: [
        "panelWidgetsWithTray",
        "panelWidgets",
        "objectName",
        "lastPreset",
        "floatingPreset",
        "normalPreset",
        "maximizedPreset"
        "touchingWindowPreset",
        "isEnabled"
    ]
    property string floatingPreset: plasmoid.configuration.floatingPreset
    property string touchingWindowPreset: plasmoid.configuration.touchingWindowPreset
    property string normalPreset: plasmoid.configuration.normalPreset
    property string maximizedPreset: plasmoid.configuration.maximizedPreset
    property string lastPreset

    property int panelSpacing: plasmoid.configuration.panelSpacing

    property bool fgShadowEnabled: plasmoid.configuration.fgShadowEnabled
    property string fgShadowColor: plasmoid.configuration.fgShadowColor
    property int fgShadowX: plasmoid.configuration.fgShadowX
    property int fgShadowY: plasmoid.configuration.fgShadowY
    property int fgShadowRadius: plasmoid.configuration.fgShadowRadius
    property int fixCustomBadges: plasmoid.configuration.fixCustomBadges

    function opacityToHex(opacity) {
        const op = Math.max(0, Math.min(1, opacity))
        const intOpacity = Math.round(op * 255)
        return intOpacity.toString(16).padStart(2, '0')
    }

    P5Support.DataSource {
        id: runCommand
        engine: "executable"
        connectedSources: []

        onNewData: function (source, data) {
            var exitCode = data["exit code"]
            var exitStatus = data["exit status"]
            var stdout = data["stdout"]
            var stderr = data["stderr"]
            exited(source, exitCode, exitStatus, stdout, stderr)
            disconnectSource(source) // cmd finished
        }

        function exec(cmd) {
            runCommand.connectSource(cmd)
        }

        signal exited(string cmd, int exitCode, int exitStatus, string stdout, string stderr)
    }

    Connections {
        target: runCommand
        function onExited(cmd, exitCode, exitStatus, stdout, stderr) {
            var presets = []
            if (exitCode!==0) return
            if(cmd === listPresetsCmd) {
                if (stdout.length > 0) {
                    presets = ("none\n"+stdout).trim().split("\n")
                } else {
                    presets = []
                }
            }
            if (cmd.startsWith("cat")) {
                presetContent = stdout.trim().split("\n")
            }
        }
    }

    function parseValues(value) {
        if (typeof value === 'boolean') {
            return value;
        }

        if (value === 'true' || value === 'false') {
            return value === 'true';
        }

        const numericValue = parseFloat(value);
        if (!isNaN(numericValue)) {
            return numericValue;
        }

        return value;
    }

    function applyPreset(presetName) {
        console.log("Reading preset:", presetName);
        lastPreset = presetName
        runCommand.exec("cat '" + presetsDir + presetName+"'")
        loadPresetTimer.start()
    }

    Timer {
        id: loadPresetTimer
        interval: 500
        onTriggered: {
            loadPreset()
        }
    }

    function loadPreset() {
        console.log("Loading preset contents...");
        for (let i in presetContent) {
            const line = presetContent[i]
            if (line.includes("=")) {
                const parts = line.split("=")
                const key = parts[0]
                const val = parts[1]
                if (ignoredConfigs.some(function (k) { return key.includes(k)})) continue
                plasmoid.configuration[key] = parseValues(val)
            }
        }
        plasmoid.configuration.lastPreset = lastPreset
        plasmoid.configuration.writeConfig();
    }

    function switchPreset() {
        if (maximizedWindowExists && maximizedPreset !== "") {
            applyPreset(maximizedPreset)
            return
        }
        if (isTouchingWindow && touchingWindowPreset !== "") {
            applyPreset(touchingWindowPreset)
            return
        }
        if (isFloating && floatingPreset !== "") {
            applyPreset(floatingPreset)
            return
        }
        applyPreset(normalPreset)
    }

    onIsFloatingChanged: {
        switchPreset()
    }

    onIsTouchingWindowChanged: {
        switchPreset()
    }

    onMaximizedWindowExistsChanged: {
        switchPreset()
    }

    function hexToRgb(hex) {
        var result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
        return result ? {
            r: parseInt(result[1], 16),
            g: parseInt(result[2], 16),
            b: parseInt(result[3], 16)
        } : null;
    }

    function readColors(colorsString) {
        let colors = []
        for (let hex of colorsString.split(" ")) {
            const rgb = hexToRgb(hex)
            if (rgb) {
                colors.push(Qt.rgba(rgb.r / 255, rgb.g / 255, rgb.b / 255, 1))
            }
        }
        return colors
    }

    Components.Scheme {
        id: schemeContent
    }

    Plasmoid.contextualActions: [
        PlasmaCore.Action {
            text: i18n("Hide widget (visible in panel Edit Mode)")
            checkable: true
            icon.name: "visibility-symbolic"
            checked: Plasmoid.configuration.hideWidget
            onTriggered: checked => {
                plasmoid.configuration.hideWidget = checked;
            }
        }
    ]

    property Component widgetBgComponent: Kirigami.ShadowedRectangle {
        property var target // holds element with expanded property
        property int heightOffset: 0
        property int widthOffset: 0
        property int linePosition: bgLinePosition
        property int lineWidth: bgLineWidth
        property bool lineMode: bgLineModeEnabled
        property int lineXOffset: -bgLineXOffset
        property int lineYOffset: -bgLineYOffset
        color: "transparent"
        opacity: bgOpacity
        radius: bgRadius
        height: lineMode && linePosition <= 1 ? lineWidth : parent.height + heightOffset
        width: lineMode && linePosition >= 2 ? lineWidth : parent.width + widthOffset

        anchors.centerIn: lineMode ? undefined : parent

        // top
        anchors.bottom: lineMode && linePosition === 0 ? parent.top : undefined
        anchors.bottomMargin: lineMode && linePosition === 0 ? lineYOffset : 0
        // bottom
        anchors.top: lineMode && linePosition === 1 ? parent.bottom : undefined
        anchors.topMargin: lineMode && linePosition === 1 ? lineYOffset : 0
        // left
        anchors.left: lineMode && linePosition === 2 ? parent.left : undefined
        anchors.leftMargin: lineMode && linePosition === 2 ? lineXOffset : 0
        // right
        anchors.right: lineMode && linePosition === 3 ? parent.right : undefined
        anchors.rightMargin: lineMode && linePosition === 3 ? lineXOffset : 0

        // centering
        anchors.horizontalCenter: lineMode && linePosition <= 1 ? parent.horizontalCenter : undefined
        anchors.verticalCenter: lineMode && linePosition >= 2 ? parent.verticalCenter : undefined

        // outline as separate rectangle so it draws inside the background
        Rectangle {
            anchors.centerIn: parent
            width: parent.width
            height: parent.height
            color: "transparent"
            radius: parent.radius
            Kirigami.Theme.colorSet: Kirigami.Theme[widgetOutlineColorScope]
            Kirigami.Theme.inherit: false
            border {
                color: {
                    let c
                    if (widgetOutlineColor.startsWith("#")) {
                        c = hexToRgb(widgetOutlineColor)
                    } else {
                        c = hexToRgb(Kirigami.Theme[widgetOutlineColor])
                    }
                    return Qt.rgba(c.r / 255, c.g / 255, c.b / 255, widgetOutlineOpacity).toString()
                }
                width: widgetOutlineWidth
            }
        }

        shadow {
            size: widgetBgEnabled ? widgetShadowSize : 0
            color: widgetShadowColor
            xOffset: widgetShadowX
            yOffset: widgetShadowY
        }

        ColorAnimation on color {
            id:anim
            to: color
            duration: rainbowTransition
        }

        function changeColor(newColor) {
            anim.to = newColor
            anim.restart()
        }
    }

    property Component panelBgComponent: Kirigami.ShadowedRectangle {
        Kirigami.Theme.colorSet: Kirigami.Theme[panelBgColorScope]
        Kirigami.Theme.inherit: false
        color: {
            if ( panelBgColor.startsWith("#")) {
                return panelBgColor
            } else {
                return Kirigami.Theme[panelBgColor]
            }
        }
        opacity: panelBgOpacity
        radius: panelBgRadius
        anchors.centerIn: parent
        width: panelBg.width
        height: panelBg.height
        shadow {
            size: panelShadowSize
            color: panelShadowColor
            xOffset: panelShadowX
            yOffset: panelShadowY
        }

        // outline as separate rectangle so it draws inside the background
        Rectangle {
            anchors.centerIn: parent
            width: parent.width
            height: parent.height
            color: "transparent"
            radius: parent.radius
            Kirigami.Theme.colorSet: Kirigami.Theme[panelOutlineColorScope]
            Kirigami.Theme.inherit: false
            border {
                color: {
                let c
                if (panelOutlineColor.startsWith("#")) {
                    c = hexToRgb(panelOutlineColor)
                } else {
                    c = hexToRgb(Kirigami.Theme[panelOutlineColor])
                }
                return Qt.rgba(c.r / 255, c.g / 255, c.b / 255, panelOutlineOpacity).toString()
            }
                width: panelOutlineWidth
            }
        }
    }

    property Component shadowComponent: DropShadow {
        property var target
        anchors.fill: target
        horizontalOffset: fgShadowX
        verticalOffset: fgShadowY
        radius: fgShadowRadius
        samples: radius * 2
        color: fgShadowColor
        source: target
        visible: fgShadowEnabled
    }

    toolTipSubText: onDesktop ? "<font color='"+Kirigami.Theme.neutralTextColor+"'>Panel not found, this widget must be child of a panel</font>" : Plasmoid.metaData.description
    toolTipTextFormat: Text.RichText

    compactRepresentation: CompactRepresentation {
        icon: main.icon
        onDesktop: main.onDesktop
    }

    fullRepresentation: ColumnLayout {}

    onModeChanged: {
        console.error("MODE CHANGED:",mode);
        plasmoid.configuration.mode = mode
        init()
    }

    function init() {
        if (isEnabled) {
            initTimer.restart()
            paddingTimer.restart()
            updateFgColor()
        } else {
            rainbowTimer.stop()
            paddingTimer.start()
            updateFgColor()
            destroyRects()
            setPanelBg()
            panelOpacity()
            destroyRequired = true
            runCommand.exec(saveSchemeCmd)
        }
    }

    onIsEnabledChanged: {
        console.error("ENABLED CHANGEDD:",isEnabled);
        plasmoid.configuration.isEnabled = isEnabled
    }

    onInEditModeChanged: {
        wasEditing = !inEditMode
        paddingTimer.start()
    }

    onSystemColorChanged: {
        if (colorMode === 1) init()
    }

    onFgSystemColorChanged: {
        if (fgColorMode === 1) init()
    }
    
    onBlacklistChanged: {
        destroyRequired = true
    }

    onMarginRulesChanged: {
        destroyRequired = true
    }

    onWidgetBgHMarginChanged: {
        destroyRequired = true
    }

    onWidgetBgVMarginChanged: {
        destroyRequired = true
    }

    onBgLinePositionChanged: {
        destroyRequired = true
    }

    onBgLineModeEnabledChanged: {
        destroyRequired = true
    }

    onWidgetConfiguringChanged: {
        // user should always see the latest widgets when configuring the widget
        if (widgetConfiguring) findWidgets()
    }

    Connections {
        target: plasmoid.configuration
        onValueChanged: {
            refreshSystemColor()
            configChangedTimer.restart()
        }
    }

    function refreshSystemColor() {
        systemColorHolder.color = "transparent"
        systemColorHolder.color = Kirigami.Theme[main.systemColor]
        fgSystemColorHolder.color = "transparent"
        fgSystemColorHolder.color = Kirigami.Theme[main.fgSystemColor]
        const tmp = fgBlacklistColorHolder.color
        fgBlacklistColorHolder.color = "transparent"
        fgBlacklistColorHolder.color = tmp
    }

    Connections {
        target: Kirigami.Theme
        onColorsChanged: {
            refreshSystemColor()
            init()
        }
    }

    Timer {
        id: configChangedTimer
        interval: 100
        onTriggered: {
            console.error("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
            console.log("CONFIG CHANGED");
            isEnabled = plasmoid.configuration.isEnabled
            mode = plasmoid.configuration.mode
            customColors = readColors(plasmoid.configuration.customColors)
            fgCustomColors = readColors(plasmoid.configuration.fgCustomColors)
            if (!widgetBgEnabled) destroyRequired = true
            addingColors = true
            init()
        }
    }

    function getRandomColor() {
        const h = Math.random()
        const s = Math.random()
        const l = Math.random()
        const a = 1.0
        return Qt.hsla(h,s,l,a)
    }

    function dumpProps(obj) {
        console.error("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
        for (var k of Object.keys(obj)) {
            print(k + "=" + obj[k]+"\n")
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

    ListModel {
        id: rectangles
    }

    function createRects() {
        if(!panelLayout) return
        if (!widgetBgEnabled && !isEnabled) return
        const blacklisted = blacklist.split("|").map(function (line) { return line.trim() })
        const marginLines = marginRules.split("|").map(function (line) { return line.trim() })
        console.log("creating widget background rects");
        for (var i in panelLayout.children) {
            const child = panelLayout.children[i];

            // name may not be available while gragging into the panel and
            // other situations
            if (!child.applet?.plasmoid?.pluginName) continue

            // TODO: Code for handling expanded widget action is here but not used yet
            const name = child.applet.plasmoid.pluginName
            var expandedTarget
            if (name === "org.kde.plasma.systemtray") {
                expandedTarget = child.applet.plasmoid.internalSystray.systemTrayState
            } else {
                expandedTarget = child
            }

            if (blacklisted.some(function (target) {
                    return target.length > 1 && name.includes(target)
                })
            ) continue

            var x = 0
            var y = 0
            for (var line of marginLines) {
                // name height width
                const parts = line.split(",")
                const match = parts[0]

                if (match.length > 0 && name.includes(match)){
                    y = parseInt(parts[1])
                    x = parseInt(parts[2])
                    break
                }
            }

            child.Layout.leftMargin = widgetBgHMargin + x
            child.Layout.rightMargin = widgetBgHMargin + x
            child.Layout.topMargin = widgetBgVMargin + y
            child.Layout.bottomMargin = widgetBgVMargin + y

            let heightOffset = 0
            let widthOffset = 0

            if (isVertical) {
                let heightOffset = (widgetBgVMargin + y) * 2
                let widthOffset = -widgetBgHMargin / 2
            } else {
                widthOffset = (widgetBgHMargin + x) * 2
            }

            rectangles.append({
                "comp": widgetBgComponent.createObject(
                    child,
                    {
                        "z": -1,
                        "target": expandedTarget,
                        "heightOffset": heightOffset,
                        "widthOffset": widthOffset
                    }
                ),
                "shadow": shadowComponent.createObject(
                    child,
                    {
                        "target":child.applet
                    }
                )
            })
            // if (child.applet) {
            //     const hasShadow = child.applet.children.find(function (child) {return child instanceof DropShadow})
            //     if (!hasShadow) shadowComponent.createObject(child, {"target":child.applet})
            // }
        }
    }

    function getNextElement(index, array) {
        var c = array[index]
        const nextIndex = index < array.length - 1 ? index + 1 : 0
        if (c === undefined) {
            console.log(index, c, nextIndex);
        }
        return [c, nextIndex]
    }

    function getColor(mode, fg = false) {
        var newColor="transparent"
        switch(mode) {
            case 0:
                newColor = fg ? Qt.rgba(fgSingleColor.r, fgSingleColor.g, fgSingleColor.b, 1) : Qt.rgba(singleColor.r, singleColor.g, singleColor.b, 1)
                break
            case 1:
                let themeColor = fg ? fgSystemColorHolder.color : systemColorHolder.color
                newColor = Qt.rgba(themeColor.r, themeColor.g, themeColor.b, 1);
                break
            case 3:
                newColor = getRandomColor()
        }
        if (fg && fgContrastFixEnabled) {
            const newSat = fgSaturationEnabled ? fgSaturation : newColor.hslSaturation
            newColor = scaleColor(newColor, newSat, fgLightness)
        }
        if (!fg && bgContrastFixEnabled) {
            const newSat = bgSaturationEnabled ? bgSaturation : newColor.hslSaturation
            newColor = scaleColor(newColor, newSat, bgLightness)
        }
        return newColor
    }

    function scaleColor(color, saturation, lightness) {
        return Qt.hsla(color.hslHue, saturation, lightness, 1);
    }

    function getNextColors(arr, start, length){
        var result = [];
        for (var j = 0; j < length; j++) {
            result.push(arr[(start + j) % arr.length]);
        }
        return [result, start]
    }

    function colorize() {
        var bgColors = []
        if (colorMode === 2) {
            if (mode === 1) {
                [bgColors, bgColorStart] = getNextColors(customColors, bgColorStart, rectangles.count)
                bgColorStart = (bgColorStart + 1) % customColors.length;
            } else {
                [bgColors, bgColorStart] = getNextColors(customColors, 0, rectangles.count)
            }
        }
        for(let i = 0; i < rectangles.count; i++) {
            try {
                var comp = rectangles.get(i)["comp"]
                var newColor = "transparent"
                if (isEnabled && widgetBgEnabled) {
                    newColor = colorMode === 2 ? bgColors[i] : getColor(colorMode)
                }
                comp.changeColor(newColor)
            } catch (e) {
                console.error("Error colorizing rect", i, "E:" , e);
            }
        }
    }

    function findWidgets() {
        console.log("Updating panel widgets list");
        plasmoid.configuration.panelWidgets = ""
        plasmoid.configuration.panelWidgetsWithTray = ""
        var panelWidgets = new Set()
        var panelWidgetsWithTray =new Set()
        function findPlasmoid(child) {
            if (child instanceof PlasmaExtras.Representation) return
            // App tray icons
            if (child.itemModel) {
                const model = child.itemModel
                if (model.itemType==="StatusNotifier") {
                    const name = model.Id
                    const title = model.ToolTipTitle !== "" ? model.ToolTipTitle : model.Title
                    const icon = model.IconName
                    const widget = name + "," + title + "," + icon
                    panelWidgetsWithTray.add(widget)
                }
            }
            if (child.plasmoid?.pluginName && child.plasmoid.pluginName !== "org.kde.plasma.private.systemtray") {
                const name = child.plasmoid.pluginName
                const title = child.plasmoid.title
                const icon = child.plasmoid.icon
                const inTray = child.plasmoid.containmentDisplayHints & PlasmaCore.Types.ContainmentDrawsPlasmoidHeading
                const widget = name + "," + title + "," + icon
                if (!inTray) {
                    panelWidgets.add(widget)
                }
                if (name !== "org.kde.plasma.systemtray") {
                    panelWidgetsWithTray.add(widget)
                }
            }
            for (var i = 0; i < child.children.length; i++) {
                findPlasmoid(child.children[i]);
            }
        }
        for (var i in panelLayout.children) {
            const child = panelLayout.children[i];
            findPlasmoid(child)
        }
        plasmoid.configuration.panelWidgets = Array.from(panelWidgets).join("|")
        plasmoid.configuration.panelWidgetsWithTray = Array.from(panelWidgetsWithTray).join("|")
    }

    function applyFgColor(element, forceMask, ignore, newColor, maskList, addingColors) {
        // don't go into expanded widgets
        if (element instanceof PlasmaExtras.Representation) return

        if (fixCustomBadges) {
            if ([Text,Label,Canvas,Kirigami.Icon].some(function (type) {return element instanceof type}) && element.parent instanceof Rectangle) {
                element.color = (Kirigami.ColorUtils.brightnessForColor(element.parent.color) === Kirigami.ColorUtils.Dark) ? "#ffffff" : "#000000"
                element.opacity = isEnabled ? fgOpacity : 1
                return
            }
        }

        if (element.plasmoid?.pluginName) {
            const name = element.plasmoid.pluginName
            forceMask = maskList.some(function (target) {
                return target.length > 0 && name.includes(target)
            })
        }
        // App tray icons
        if (element.itemModel) {
            const model = element.itemModel
            if (model.itemType==="StatusNotifier") {
                const name = model.Id
                forceMask = maskList.some(function (target) {
                    return target.length > 0 && name.includes(target)
                })
            }
        }

        if (element.hasOwnProperty("color")) {
            element.Kirigami.Theme.textColor = newColor
        }

        if (element.hasOwnProperty("scheme") && addingColors) {
            element.scheme = null
            element.scheme = schemeFile
        }

        if ([Text,ToolButton,Label,Canvas,Kirigami.Icon].some(function (type) {return element instanceof type})) {
            if (element.color) {
                element.color = newColor
            }
            if (element.hasOwnProperty("isMask") && forceMask) {
                element.isMask = true
            }
            element.Kirigami.Theme.textColor = newColor
            // fixes notification applet artifact when appearing
            if (element.scale !== 1) return
            element.opacity = isEnabled ? fgOpacity : 1
        }
        // fix unreadable badges
        if (element instanceof WorkspaceComponents.BadgeOverlay) {
            element.color = newColor
            // label contrast
            element.children[0].color = (Kirigami.ColorUtils.brightnessForColor(element.color) === Kirigami.ColorUtils.Dark) ? "#ffffff" : "#000000"
            element.opacity = isEnabled ? fgOpacity : 1
            return
        }

        for (var i = 0; i < element.children.length; i++) {
            applyFgColor(element.children[i], forceMask, ignore, newColor, maskList, addingColors);
        }
    }

    function updateFgColor() {
        if (addingColors) {
            currentFgColors = []
            if (fgColorMode === 2) {
                if (fgMode === 1){
                    [currentFgColors, fgColorStart] = getNextColors(fgCustomColors, fgColorStart, rectangles.count)
                    fgColorStart = (fgColorStart + 1) % fgCustomColors.length;
                } else {
                    [currentFgColors, fgColorStart] = getNextColors(fgCustomColors, 0, rectangles.count)
                }
                if (fgContrastFixEnabled) {
                    for (let i = 0; i < currentFgColors.length; i++) {
                        var newColor = Qt.rgba(currentFgColors[i].r, currentFgColors[i].g, currentFgColors[i].b, 1)
                        const newSat = fgSaturationEnabled ? fgSaturation : newColor.hslSaturation
                        newColor = scaleColor(newColor, newSat, fgLightness)
                        currentFgColors[i] = newColor
                    }
                }
            }
        }
        var idx=0
        const blacklisted = blacklist.split("|").map(function (line) { return line.trim() })
        const maskList = forceRecolor.split("|").map(function (line) { return line.trim() })
        // console.error(forceRecolor);
        for(let i = 0; i < panelLayout.children.length; i++) {
            const child = panelLayout.children[i];

            // name may not be available while gragging into the panel and
            // other situations
            if (!child.applet?.plasmoid?.pluginName) continue

            // only get root element of widgets
            const target = child.children.find(function (child) {return child instanceof PlasmoidItem})
            if (!target) return

            const name = child.applet.plasmoid.pluginName
            const ignore = blacklisted.some(function (target) {return target.length > 0 && name.includes(target)})
            const rect = child.children.find(function (child) {return child instanceof Kirigami.ShadowedRectangle})

            let newColor = defaultTextColor
            if (isEnabled && fgColorEnabled && !ignore) {
                if (addingColors) {
                    var bgColor = ""
                    if (fgColorMode === 4) {
                        if (rect) {
                            bgColor = Qt.hsla(rect.color.hslHue, rect.color.hslSaturation, rect.color.hslLightness, 1);
                        } else {
                            bgColor = Qt.hsla(defaultTextColor.hslHue, defaultTextColor.hslSaturation, defaultTextColor.hslLightness, 1);
                        }
                        if (fgContrastFixEnabled) {
                            const newSat = fgSaturationEnabled ? fgSaturation : bgColor.hslSaturation
                            bgColor = scaleColor(bgColor, newSat, fgLightness)
                        }
                    } else {
                        bgColor = fgColorMode === 2 ? currentFgColors[idx] : getColor(fgColorMode, true)
                    }
                    newColor = bgColor
                    currentFgColors.push(newColor)
                } else {
                    newColor = currentFgColors[idx]
                }
                idx++
            }
            if (fgBlacklistedColorEnabled && ignore) {
                newColor = fgBlacklistColorHolder.color
            }

            if (name === "org.kde.windowbuttons" && addingColors) {
                schemeContent.opacityComponent = opacityToHex(isEnabled ? fgOpacity : 1)
                schemeContent.fgWithAlpha = "#" + schemeContent.opacityComponent + newColor.toString().substring(1)
                schemeContent.fgContrast = (Kirigami.ColorUtils.brightnessForColor(newColor) === Kirigami.ColorUtils.Dark) ? "#ffffff" : "#000000"
                runCommand.exec(saveSchemeCmd)
            }

            try {
                applyFgColor(target, false, ignore, newColor, maskList, addingColors)
            } catch (e) {
                console.error("Error updating fg color in child", i, "E:" , e);
            }
        }
        addingColors = false
    }

    // Timer {
    //     id: debugTimer
    //     running: true
    //     repeat: true
    //     interval: 1000
    //     onTriggered: {
    //         // console.log("fgMode:", fgMode, "fgInterval", fgRainbowInterval, (fgMode === 1));
    //         // console.log(plasmoid.configuration.panelWidgets);
    //         // findWidgets()
    //         console.error("MAX", maximizedWindowExists );
    //     }
    // }

    Component.onCompleted: {
        customColors = readColors(plasmoid.configuration.customColors)
        fgCustomColors = readColors(plasmoid.configuration.fgCustomColors)
        if (!onDesktop) {
            init()
        } else {
            console.error("Panel not detected, aborted");
        }
    }

    Timer {
        id: initTimer
        running: false
        repeat: false
        interval: 100
        onTriggered: {
            console.log("initTimer");
            setPanelBg()
            panelOpacity()
            if (destroyRequired) {
                destroyRects()
            }
            runCommand.exec(saveSchemeCmd)
            startTimer.start()
            if (!isLoaded) runCommand.exec(listPresetsCmd)
            panelLayout.columnSpacing = panelSpacing
            panelLayout.rowSpacing = panelSpacing
        }
    }

    Timer {
        id: startTimer
        running: false
        repeat: false
        interval: 400
        onTriggered: {
            console.log("startTimer");
            if (destroyRequired) {
                createRects()
            }
            isLoaded = true
            destroyRequired = false
            rainbowTimer.interval = 100
            rainbowTimer.start()
            rainbowfgTimer.interval = 100
            rainbowfgTimer.start()
        }
    }

    Timer {
        id: fgUpdateTimer
        running: isEnabled && fgColorEnabled
        repeat: true
        interval: 250
        onTriggered: {
            updateFgColor()
        }
    }

    Timer {
        id: rainbowTimer
        running: false
        repeat: (mode === 1)
        interval: rainbowInterval
        onTriggered: {
            colorize()
            interval = rainbowInterval
            if (fgColorMode === 4 && fgMode !== 1) {
                addingColors = true
                rainbowfgTimer.interval = rainbowTransition
                rainbowfgTimer.restart()
            }
        }
    }

    Timer {
        id: rainbowfgTimer
        running: false
        repeat: (fgMode === 1)
        interval: fgRainbowInterval
        onTriggered: {
            addingColors = true
            interval = fgRainbowInterval
        }
    }

    function destroyRects() {
        console.log("Destroying rects:",rectangles.count,"widget id:",Plasmoid.id, "screen:", screen, "position", plasmoid.location);
        for (var i = rectangles.count - 1; i >= 0; i--) {
            var comp = rectangles.get(i)["comp"]
            var shadow = rectangles.get(i)["shadow"]
            try {
                comp.destroy()
                shadow.destroy()
            } catch (e) {
                console.error("Error destroying rect", i, "E:" , e);
            }
            rectangles.remove(i)
        }
    }

    Timer {
        id: panelModifiedTimer
        running: false
        interval: 5000
        repeat: false
        onTriggered: {
            showToUpdate = false
            init()
        }
    }

    Timer {
        id: initRects
        running: isEnabled && !onDesktop
        repeat: true
        interval: 100
        onTriggered: {
            if (!panelLayout) return
            // check for widget add/removal
            const newChildCount = panelLayout.children.length
            if(newChildCount !== childCount || wasEditing) {
                if(wasEditing) console.log("END EDITING");
                console.log(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
                console.log("Number of childs changed from " + childCount + " to " + newChildCount);
                childCount = newChildCount
                destroyRequired = true
                wasEditing = false
                if(isLoaded) {
                    showToUpdate = true
                    panelModifiedTimer.start()
                }
                findWidgets()
            }
        }
    }

    function printProps(element) {
        dumpProps(element)
        for (let p of Object.keys(element)) {
            dumpProps(element[p])
        }
        for (var i = 0; i < element.children.length; i++) {
            printProps(element.children[i]);
        }
    }

    Timer {
        id: paddingTimer
        interval: 1000;
        running: true;
        repeat: false;
        onTriggered: {
            updatePadding()
        }
    }

    function updatePadding() {
        if (isEnabled && enableCustomPadding) {
            panelLayout.anchors.centerIn = panelLayout.parent

            if (!isVertical) {
                panelLayout.width = panelBg.width - panelPadding
                panelLayout.height = panelBg.height
            }

            if (isVertical) {
                panelLayout.width = panelBg.width
                panelLayout.height = panelBg.height - panelPadding
            }
        }
    }

    Connections {
        target: panelBg
        onWidthChanged: {
            updatePadding()
        }

        onHeightChanged: {
            updatePadding()
        }
    }

    Connections {
        target: plasmoid
        onLocationChanged: {
            paddingTimer.start()
        }
    }

    function setPanelBg() {
        destroyPanelBg()
        if (isEnabled && panelBgEnabled) {
            panelBGE = panelBgComponent.createObject(
                panelLayout.parent,
                {
                    "z": -1
                }
            )
        }
    }

    function destroyPanelBg() {
        if (panelBGE) {
            panelBGE.destroy()
        }
    }

    function panelOpacity() {
        for (let i in panelElement.children) {
            const current = panelElement.children[i]

            if (current.imagePath && current.imagePath.toString().includes("panel-background")) {
                current.opacity = isEnabled ? panelRealBgOpacity : 1
            }
        }
        lookForContainerTimer.start()
    }

    // Taken from https://github.com/sanjay-kr-commit/panelTransparencyToggleForPlasma6

    function toggleTransparency(enabled) {
        if ( main.containmentItem == null ) lookForContainer( main.parent , depth ) ;
        if ( main.containmentItem != null ) {
            main.containmentItem.Plasmoid.backgroundHints = enabled ? PlasmaCore.Types.NoBackground : PlasmaCore.Types.DefaultBackground
        }
    }

    function lookForContainer( object , tries ) {
        if ( tries == 0 || object == null ) return ;
        if ( object.toString().indexOf("ContainmentItem_QML") > -1 ) {
            main.containmentItem = object ;
            console.log( "ContainmentItemFound At " + ( depth - tries ) + " recursive call" ) ;
        } else {
            lookForContainer( object.parent , tries-1 ) ;
        }
    }

    Timer {
        id: lookForContainerTimer
        interval: 1200
        property int step: 0
        readonly property int maxStep:4
        onTriggered: {
            console.log("enabling transparency mode attempt : " + (step+1) )
            main.toggleTransparency(hideRealPanelBg)
            if ( main.containmentItem == null && step<maxStep ) {
                step = step + 1;
                start();
            }
        }
    }

    // Based on https://github.com/KDE/plasma-active-window-control/blob/master/package/contents/ui/main.qml
    property var activeTaskLocal: null
    property bool noWindowActive: true
    property bool currentWindowMaximized: false
    property bool maximizedWindowExists: false

    TaskManager.VirtualDesktopInfo {
        id: virtualDesktopInfo
    }

    TaskManager.ActivityInfo {
        id: activityInfo
        readonly property string nullUuid: "00000000-0000-0000-0000-000000000000"
    }

    TaskManager.TasksModel {
        id: tasksModel
        sortMode: TaskManager.TasksModel.SortVirtualDesktop
        groupMode: TaskManager.TasksModel.GroupDisabled
        virtualDesktop: virtualDesktopInfo.currentDesktop
        activity: activityInfo.currentActivity
        filterByVirtualDesktop: true
        screenGeometry: main.screenGeometry
        filterByScreen: true
        filterByActivity: true
        filterMinimized: true

        onActiveTaskChanged: {
            hasMaximized()
        }
        onDataChanged: {
            hasMaximized()
        }
        onCountChanged: {
            hasMaximized()
        }
    }

    function hasMaximized() {
        var abstractTasksModel = TaskManager.AbstractTasksModel || {}
        var IsMaximized = abstractTasksModel.IsMaximized || 276
        var IsActive = abstractTasksModel.IsActive || 271
        var isMaximized = false

        for (var i = 0; i < tasksModel.count; i++) {
            const currentTask = tasksModel.index(i,0)
            if (currentTask === undefined) continue
            isMaximized = Boolean(tasksModel.data(currentTask, IsMaximized))
            if (isMaximized) break
        }
        maximizedWindowExists = isMaximized
    }
}

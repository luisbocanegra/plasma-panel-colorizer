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
    property color singleColor: plasmoid.configuration.singleColor
    property var customColors: []
    property int nextCustomColorIndex: 0
    property bool widgetBgEnabled: plasmoid.configuration.widgetBgEnabled
    property real bgOpacity: plasmoid.configuration.opacity
    property int bgRadius: plasmoid.configuration.radius
    property real rainbowSaturation: plasmoid.configuration.rainbowSaturation
    property real rainbowLightness: plasmoid.configuration.rainbowLightness
    property int rainbowInterval: plasmoid.configuration.rainbowInterval
    property int rainbowTransition: plasmoid.configuration.rainbowTransition
    property string blacklist: plasmoid.configuration.blacklist
    property string paddingRules: plasmoid.configuration.paddingRules
    property bool hideWidget: plasmoid.configuration.hideWidget

    property bool panelBgEnabled: plasmoid.configuration.panelBgEnabled
    property string panelBgColor: plasmoid.configuration.panelBgColor
    property real panelBgOpacity: plasmoid.configuration.panelBgOpacity
    property real panelBgRadius: isFloating ? plasmoid.configuration.panelBgRadius : 0
    property bool hideRealPanelBg: plasmoid.configuration.hideRealPanelBg
    property real panelRealBgOpacity: plasmoid.configuration.panelRealBgOpacity
    property color widgetOutlineColor: plasmoid.configuration.widgetOutlineColor
    property int widgetOutlineWidth: plasmoid.configuration.widgetOutlineWidth
    property color widgetShadowColor: plasmoid.configuration.widgetShadowColor
    property int widgetShadowSize: plasmoid.configuration.widgetShadowSize
    property int widgetShadowX: plasmoid.configuration.widgetShadowX
    property int widgetShadowY: plasmoid.configuration.widgetShadowY

    property color panelOutlineColor: plasmoid.configuration.panelOutlineColor
    property int panelOutlineWidth: plasmoid.configuration.panelOutlineWidth
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

    property int childCount: 0
    property bool wasEditing: false
    property bool destroyRequired: false

    property color accentColor: Kirigami.Theme.highlightColor
    property color defaultTextColor: Kirigami.Theme.textColor
    property real fgOpacity: plasmoid.configuration.fgOpacity
    property bool fgColorEnabled: plasmoid.configuration.fgColorEnabled

    property color blacklistedFgColor: plasmoid.configuration.blacklistedFgColor
    property bool fgBlacklistedColorEnabled: plasmoid.configuration.fgBlacklistedColorEnabled

    property bool showToUpdate: false

    property string runtimeDir: StandardPaths.writableLocation(
                            StandardPaths.RuntimeLocation).toString().substring(7)
    property string schemeFile: runtimeDir + "/PanelColorizer-"+plasmoid.id+".colors"

    property string saveSchemeCmd: "echo '" + schemeContent.text + "' > " + schemeFile

    property int fgMode: plasmoid.configuration.fgMode
    property int fgColorMode: plasmoid.configuration.fgColorMode
    property color fgSingleColor: plasmoid.configuration.fgSingleColor
    property var fgCustomColors: []
    property int nextfgCustomColorIndex: 0
    property bool addingColors: true
    property var currentFgColors: []
    property int fgRainbowInterval: plasmoid.configuration.fgRainbowInterval

    property bool fgContrastFixEnabled: plasmoid.configuration.fgContrastFixEnabled
    property real fgSaturation: plasmoid.configuration.fgSaturation
    property real fgLightness: plasmoid.configuration.fgLightness

    property int enableCustomPadding: plasmoid.configuration.enableCustomPadding
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

    property ContainmentItem containmentItem: null
    readonly property int depth : 14

    property var panelBGE


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
        color: "transparent"
        opacity: bgOpacity
        radius: bgRadius
        height: parent.height + heightOffset
        width: parent.width + widthOffset
        anchors.centerIn: parent
        border {
            color: widgetOutlineColor
            width: widgetOutlineWidth
        }
        shadow {
            size: widgetShadowSize
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
        color: panelBgColor
        opacity: panelBgOpacity
        radius: panelBgRadius
        anchors.centerIn: parent
        width: panelBg.width
        height: panelBg.height
        border {
            color: panelOutlineColor
            width: panelOutlineWidth
        }
        shadow {
            size: panelShadowSize
            color: panelShadowColor
            xOffset: panelShadowX
            yOffset: panelShadowY
        }
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
            initTimer.start()
            paddingTimer.start()
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

    onAccentColorChanged: {
        if (colorMode === 1) init()
    }
    
    onBlacklistChanged: {
        destroyRequired = true
    }

    onPaddingRulesChanged: {
        destroyRequired = true
    }

    Connections {
        target: plasmoid.configuration
        onValueChanged: {
            console.log("CONFIG CHANGED");
            isEnabled = plasmoid.configuration.isEnabled
            mode = plasmoid.configuration.mode
            customColors = readColors(plasmoid.configuration.customColors)
            fgCustomColors = readColors(plasmoid.configuration.fgCustomColors)
            if (!widgetBgEnabled) destroyRequired = true
            init()
        }
    }

    function getRandomColor() {
        const h = Math.random()
        const s = rainbowSaturation
        const l = rainbowLightness
        const a = 1.0
        return Qt.hsla(h,s,l,a)
    }

    function getRandomFgColor() {
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
        const blacklisted = blacklist.split("\n").map(function (line) { return line.trim() })
        const paddingLines = paddingRules.split("\n").map(function (line) { return line.trim() })

        console.log("creating widget background rects");
        for (var i in panelLayout.children) {
            let heightOffset = 0
            let widthOffset = 0
            const child = panelLayout.children[i];

            if (!child.applet) continue
            if (!child.applet.plasmoid) {
                continue
            }

            // name may not be available while gragging into the panel and
            // other situations
            try {
                console.error(child.applet.plasmoid.pluginName);
            } catch (e) {
                console.error(e);
                continue
            }

            // TODO: Code for handling expanded widget action is here but not used yet
            const name = child.applet.plasmoid.pluginName
            var expandedTarget
            if (name === "org.kde.plasma.systemtray") {
                expandedTarget = child.applet.plasmoid.internalSystray.systemTrayState
            } else {
                expandedTarget = child
            }

            if (blacklisted.some(function (target) {
                    return target.length > 0 && name.includes(target)
                })
            ) continue

            var x = 0
            var y = 0
            for (var line of paddingLines) {
                // name height width
                const parts = line.split(" ")
                const match = parts[0]

                if (match.length > 0 && name.includes(match)){
                    x = parts[1]
                    y = parts[2]
                    break
                }
            }

            rectangles.append({
                "comp":widgetBgComponent.createObject(
                    child,
                    {
                        "z": -1,
                        "target": expandedTarget,
                        "heightOffset": x,
                        "widthOffset": y
                    }
                )
            })
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

    function getColor() {
        var newColor="transparent"
        switch(colorMode) {
            case 0:
                newColor = singleColor
                break
            case 1:
                newColor = accentColor
                break
            case 2:
                [newColor, nextCustomColorIndex] = getNextElement(nextCustomColorIndex, customColors)
                break
            case 3:
                newColor = getRandomColor()
        }
        return newColor
    }

    function getFgColor() {
        var newColor="transparent"
        switch(fgColorMode) {
            case 0:
                newColor = Qt.rgba(fgSingleColor.r, fgSingleColor.g, fgSingleColor.b, 1)
                break
            case 1:
                newColor = Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 1);
                break
            case 2:
                [newColor, nextfgCustomColorIndex] = getNextElement(nextfgCustomColorIndex, fgCustomColors)
                break
            case 3:
                newColor = getRandomFgColor()
        }
        return newColor
    }

    function colorize() {
        for(let i = 0; i < rectangles.count; i++) {
            try {
                var comp = rectangles.get(i)["comp"]
                const newColor = isEnabled && widgetBgEnabled ? getColor() : "transparent"
                comp.changeColor(newColor)
            } catch (e) {
                console.error("Error colorizing rect", i, "E:" , e);
            }
        }
    }

    function applyFgColor(element, forceMask, ignore, newColor, maskList) {
        // don't go into expanded widgets
        if (element instanceof PlasmaExtras.Representation) return

        if (element.plasmoid?.pluginName) {
            const name = element.plasmoid.pluginName
            forceMask = maskList.some(function (target) {
                return target.length > 0 && name.includes(target)
            })
        }

        if (element.hasOwnProperty("color")) {
            element.Kirigami.Theme.textColor = newColor
        }

        if (element.hasOwnProperty("scheme")) {
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
            applyFgColor(element.children[i], forceMask, ignore, newColor, maskList);
        }
    }

    function updateFgColor() {
        if (addingColors) currentFgColors = []
        var idx=0
        const blacklisted = blacklist.split("\n").map(function (line) { return line.trim() })
        const maskList = forceRecolor.split("\n").map(function (line) { return line.trim() })
        for(let i = 0; i < panelLayout.children.length; i++) {
            const child = panelLayout.children[i];

            // name may not be available while gragging into the panel and
            // other situations
            if (!child.applet?.plasmoid?.pluginName) continue

            // only get root element of widgets
            const target = child.children.find(function (child) {return child instanceof PlasmoidItem})
            if (!target) return

            const name = child.applet.plasmoid.pluginName
            const ignore = blacklisted.some(function (target) {return name.includes(target)})
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
                    } else {
                        bgColor = getFgColor()
                    }
                    if (fgContrastFixEnabled) {
                        bgColor.hslLightness = fgLightness
                        bgColor.hslSaturation = fgSaturation
                    }
                    newColor = bgColor
                    currentFgColors.push(newColor)
                } else {
                    newColor = currentFgColors[idx]
                    idx++
                }
            }
            if (fgBlacklistedColorEnabled && ignore) {
                newColor = blacklistedFgColor
            }

            if (name === "org.kde.windowbuttons" && addingColors) {
                schemeContent.opacityComponent = opacityToHex(isEnabled ? fgOpacity : 1)
                schemeContent.fgWithAlpha = "#" + schemeContent.opacityComponent + newColor.toString().substring(1)
                schemeContent.fgContrast = (Kirigami.ColorUtils.brightnessForColor(newColor) === Kirigami.ColorUtils.Dark) ? "#ffffff" : "#000000"
                runCommand.exec(saveSchemeCmd)
            }

            try {
                applyFgColor(target, false, ignore, newColor, maskList)
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
    //         console.log("fgMode:", fgMode, "fgInterval", fgRainbowInterval, (fgMode === 1));
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
        }
    }

    Timer {
        id: startTimer
        running: false
        repeat: false
        interval: 400
        onTriggered: {
            console.log("startTimer");
            if (destroyRequired) createRects()
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
            try {
                comp.destroy()
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
                current.opacity = isEnabled && panelBgEnabled ? panelRealBgOpacity : 1
            }
        }
        lookForContainerTimer.start()
    }

    // Taken from https://github.com/sanjay-kr-commit/panelTransparencyToggleForPlasma6

    function toggleTransparency(enabled) {
        if ( main.containmentItem == null ) lookForContainer( main.parent , depth ) ;
        if ( main.containmentItem != null ) {
            main.containmentItem.Plasmoid.backgroundHints = enabled ? PlasmaCore.Types.NoBackground : PlasmaCore.Types.DefaultBackground ;
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
}

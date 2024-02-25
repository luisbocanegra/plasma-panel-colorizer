import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.plasma.extras 2.0 as PlasmaExtras
import Qt.labs.platform
import org.kde.plasma.plasma5support as P5Support
import "components" as Components

PlasmoidItem {
    id: main

    preferredRepresentation: compactRepresentation
    property bool onDesktop: plasmoid.location === PlasmaCore.Types.Floating

    property string iconName: !onDesktop ? "icon" : "error"
    property string icon: Qt.resolvedUrl("../icons/" + iconName + ".svg").toString().replace("file://", "")

    property var panelPosition: {}

    property bool isEnabled: plasmoid.configuration.isEnabled
    property int mode: plasmoid.configuration.mode
    property int colorMode: plasmoid.configuration.colorMode
    property string singleColor: plasmoid.configuration.singleColor
    property string customColors: plasmoid.configuration.customColors
    property int currentCustomColorIndex: 0
    property real bgOpacity: plasmoid.configuration.opacity
    property int bgRadius: plasmoid.configuration.radius
    property real rainbowSaturation: plasmoid.configuration.rainbowSaturation
    property real rainbowLightness: plasmoid.configuration.rainbowLightness
    property int rainbowInterval: plasmoid.configuration.rainbowInterval
    property int rainbowTransition: plasmoid.configuration.rainbowTransition
    property string blacklist: plasmoid.configuration.blacklist
    property string paddingRules: plasmoid.configuration.paddingRules
    property bool hideWidget: plasmoid.configuration.hideWidget

    property bool isLoaded: false
    property bool isConfiguring: plasmoid.userConfiguring

    property bool inEditMode: Plasmoid.containment.corona?.editMode ? true : false
    Plasmoid.status: (inEditMode || !hideWidget || showToUpdate || isConfiguring) ?
                        PlasmaCore.Types.ActiveStatus :
                        PlasmaCore.Types.HiddenStatus

    property GridLayout panelLayout
    property int childCount: 0
    property bool wasEditing: false
    property bool destroyRequired: false

    property color accentColor: Kirigami.Theme.highlightColor
    property color defaultTextColor: Kirigami.Theme.textColor
    property color customFgColor: plasmoid.configuration.customFgColor
    property real fgOpacity: plasmoid.configuration.fgOpacity
    property bool fgColorEnabled: plasmoid.configuration.fgColorEnabled

    property bool showToUpdate: false

    property string homeDir: StandardPaths.writableLocation(
                            StandardPaths.HomeLocation).toString().substring(7)
    property string schemeFile: homeDir + "/.local/share/color-schemes/PanelColorizer.colors"

    property string saveSchemeCmd: "echo '" + schemeContent.text + "' > " + schemeFile

    property string fgColor: isEnabled && fgColorEnabled ? customFgColor : defaultTextColor
    property string opacityComponent: {
        return opacityToHex(isEnabled ? fgOpacity : 1)
    }

    property string fgWighAlpha: {
        return "#" + opacityComponent + fgColor.substring(1)
    }
    property string fgContrast: {
        if (Kirigami.ColorUtils.brightnessForColor(fgColor) === Kirigami.ColorUtils.Light) {
            return "#000000"
        } else {
            return "#ffffff"
        }
    }

    function opacityToHex(opacity) {
        const op = Math.max(0, Math.min(1, opacity))
        const intOpacity = Math.round(op * 255)
        return intOpacity.toString(16).padStart(2, '0')
    }

    P5Support.DataSource {
        id: runCommand
        engine: "executable"
        connectedSources: []

        onNewData: function(source, data) {
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

    onFgColorChanged: {
        if (isLoaded) runCommand.exec(saveSchemeCmd)
    }

    Components.Scheme {
        id: schemeContent
        fgContrast: main.fgContrast
        fgWighAlpha: main.fgWighAlpha
        opacityComponent: main.opacityComponent
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

    property Component rectComponent: Rectangle {
        property var target // holds element with expanded property
        property int heightOffset: 0
        property int widthOffset: 0
        color: "transparent"
        opacity: bgOpacity
        radius: bgRadius
        height: parent.height + heightOffset
        width: parent.width + widthOffset
        anchors.centerIn: parent

        ColorAnimation on color { id:anim; to: color; duration: rainbowTransition }

        function changeColor(newColor) {
            anim.to = newColor
            anim.restart()
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
        } else {
            rainbowTimer.stop()
            updateFgColor()
            destroyRects()
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
    }

    onAccentColorChanged: {
        if (colorMode === 1) init()
    }

    Connections {
        target: plasmoid.configuration
        onValueChanged: {
            console.log("CONFIG CHANGED");
            isEnabled = plasmoid.configuration.isEnabled
            mode = plasmoid.configuration.mode
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

    function dumpProps(obj) {
        console.error("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
        for (var k of Object.keys(obj)) {
            print(k + "=" + obj[k]+"\n")
        }
    }

    // Search the actual gridLayout of the panel
    function getGrid() {
        let candidate = main.parent;
        while (candidate) {
            if (candidate instanceof GridLayout) {
                return candidate;
            }
            candidate = candidate.parent;
        }
        return null
    }

    ListModel {
        id: rectangles
    }

    function nextCustomColor() {
        const colors = customColors.split(" ")
        let next = colors[currentCustomColorIndex]
        currentCustomColorIndex= currentCustomColorIndex < colors.length - 1 ? currentCustomColorIndex + 1 : 0
        return next
    }


    function createRects() {
        if(!panelLayout) return
        if (rectangles.count === 0) {
            console.log("creating rects");
            const blacklisted = blacklist.split("\n").map(function(line) {return line.trim()})
            const paddingLines = paddingRules.split("\n").map(function(line) {return line.trim()})

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
                if (name === "org.kde.plasma.systemtray") {
                    rectangles.append({
                        "comp":rectComponent.createObject(
                            child.applet,
                            {
                                "z": -1,
                                "target": child.applet.plasmoid.internalSystray.systemTrayState
                            }
                        )
                    })
                    continue
                }

                if (blacklisted.some(function(target) {return name.includes(target)})) continue

                var x = 0
                var y = 0
                for (var line of paddingLines) {
                    // name height width
                    const parts = line.split(" ")
                    const match = parts[0]

                    if (name.includes(match)){
                        x = parts[1]
                        y = parts[2]
                        break
                    }
                }

                rectangles.append({
                    "comp":rectComponent.createObject(
                        child.applet,
                        {
                            "z": -1,
                            "target":child,
                            "heightOffset":x,
                            "widthOffset":y
                        }
                    )
                })
            }
        }
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
                newColor = nextCustomColor()
                break
            case 3:
                newColor = getRandomColor()
        }
        return newColor
    }

    function colorize() {
        console.log("colorize mode:",colorMode,"rects:",rectangles.count,"widget id:",Plasmoid.id, "screen:", screen, "position", plasmoid.location);
        for(let i = 0; i < rectangles.count; i++) {
            try {
                var comp = rectangles.get(i)["comp"]
                const newColor = isEnabled ? getColor() : "transparent"
                comp.changeColor(newColor)
                applyFgColor(comp.parent)
            } catch (e) {
                console.error("Error colorizing rect", i, "E:" , e);
            }
        }
    }

    function applyFgColor(element) {
        // don't go into the tray
        if (element instanceof PlasmaExtras.Representation) return

        var newColor = defaultTextColor
        if (isEnabled && fgColorEnabled) {
            newColor = customFgColor
        }

        if (element.hasOwnProperty("color")) {
            element.Kirigami.Theme.textColor = newColor
        }


        if (element.hasOwnProperty("scheme")) {
            element.scheme = schemeFile
        }

        if ([Text,ToolButton,Label,Canvas,Kirigami.Icon].some(function(type) {return element instanceof type})) {
            if (element.color) {
                element.color = newColor
            }
            // fixes notification applet artifact when appearing
            if (element.scale !== 1) return
            if (isEnabled) {
                element.opacity = fgOpacity
            } else {
                element.opacity = 1
            }
            element.Kirigami.Theme.textColor = newColor
        }

        for (var i = 0; i < element.children.length; i++) {
            applyFgColor(element.children[i]);
        }
    }

    function updateFgColor() {
        for(let i = 0; i < rectangles.count; i++) {
            try {
                var comp = rectangles.get(i)["comp"]
                applyFgColor(comp.parent)
            } catch (e) {
                console.error("Error updating text in rect", i, "E:" , e);
            }
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

    Component.onCompleted: {
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
            panelLayout = getGrid()
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
}

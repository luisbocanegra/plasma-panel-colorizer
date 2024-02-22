import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid

PlasmoidItem {
    id: main

    preferredRepresentation: compactRepresentation
    property bool onDesktop: plasmoid.location === PlasmaCore.Types.Floating

    property string iconName: !onDesktop ? "icon" : "error"
    property string icon: Qt.resolvedUrl("../icons/" + iconName + ".svg").toString().replace("file://", "")

    property var panelPosition: {}

    property bool isEnabled: true
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
    property bool hideWidget: false

    property bool isLoaded: false
    property bool isConfiguring: plasmoid.userConfiguring

    property bool inEditMode: Plasmoid.containment.corona?.editMode ? true : false
    Plasmoid.status: inEditMode || !hideWidget ? PlasmaCore.Types.ActiveStatus : PlasmaCore.Types.HiddenStatus

    property GridLayout panelLayout
    property int childCount: 0
    property bool errorCreatingRects: false
    property bool wasEditing: false

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
        // if (!isLoaded) return
        console.error("MODE CHANGED:",mode);
        plasmoid.configuration.mode = mode
        init()
    }

    function init() {
        if (isEnabled) {
            // colorize()
            startTimer.start()
        } else {
            rainbowTimer.stop()
            destroyRects()
        }

    }

    onIsEnabledChanged: {
        // if (!isLoaded) return
        console.error("ENABLED CHANGEDD:",isEnabled);
        plasmoid.configuration.isEnabled = isEnabled
        init()
    }

    onColorModeChanged: {
        // if (!isLoaded) return
        console.error("COLOR MODE CHANGED:",colorMode);
        init()
    }

    onRainbowLightnessChanged: {
        init()
    }

    onRainbowSaturationChanged: {
        init()
    }

    onInEditModeChanged: {
        wasEditing = !inEditMode
    }

    onHideWidgetChanged: {
        console.error("HIDE WIDGET:",hideWidget);
    }

    function getRandomColor() {
        const h = Math.random()
        const s = rainbowSaturation
        const l = rainbowLightness
        const a = 1.0
        return Qt.hsla(h,s,l,a)
    }

    function dumpProps(obj) {
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
                // if (!child.visible) continue;

                if (!child.applet) continue
                console.error(child.applet.plasmoid.pluginName);
                // TODO: Code for handling expanded widget action is here but not used yet
                if (child.applet && (child.applet.plasmoid.pluginName === "org.kde.plasma.systemtray")) {
                    rectangles.append({
                        "comp":rectComponent.createObject(
                            child,
                            {
                                "z": -1,
                                "target": child.applet.plasmoid.internalSystray.systemTrayState
                            }
                        )
                    })
                    continue
                }

                
                const name = child.applet.plasmoid.pluginName
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
                        child,
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
                newColor = Kirigami.Theme.highlightColor
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
            } catch (e) {
                console.error("Error colorizing rect", i, "E:" , e);
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

    Component.onCompleted: {
        if (!onDesktop) {
            init()
        } else {
            console.error("Panel not detected, aborted");
        }
    }

    Timer {
        id: startTimer
        running: true
        repeat: false
        interval: !isLoaded ? 1000 : 1
        onTriggered: {
            createRects()
            isLoaded = true
            rainbowTimer.interval = 10
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
        id: initRects
        running: true
        repeat: true
        interval: 100
        onTriggered: {
            panelLayout = getGrid()
            if (!panelLayout) return
            // check for widget add/removal
            const newChildCount = panelLayout.children.length
            if(newChildCount !== childCount || wasEditing ) {
                if(wasEditing) console.log("END EDITING");
                console.log(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
                console.log("Number of childs changed from " + childCount + " to " + newChildCount);
                destroyRects()
                childCount = newChildCount
                wasEditing = false
                init()
            }
        }
    }
}

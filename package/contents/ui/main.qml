import QtQuick 2.5
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.1
import org.kde.kirigami 2.10 as Kirigami
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0

Item {
    id: main

    Plasmoid.preferredRepresentation: Plasmoid.fullRepresentation
    // Plasmoid.preferredRepresentation: Plasmoid.compactRepresentation
    property bool onDesktop: plasmoid.location === PlasmaCore.Types.Floating

    property string iconName: !onDesktop ? "icon" : "error"
    property string icon: Qt.resolvedUrl("../icons/" + iconName + ".svg").toString().replace("file://", "")

    property var panelPosition: {}

    property bool enabled: plasmoid.configuration.enabled
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

    property bool inEditMode: Plasmoid.editMode
    Plasmoid.status: inEditMode || !hideWidget ? PlasmaCore.Types.ActiveStatus : PlasmaCore.Types.HiddenStatus

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

    Plasmoid.toolTipSubText: onDesktop ? "<font color='"+Kirigami.Theme.neutralTextColor+"'>Panel not found, this widget must be child of a panel</font>" : Plasmoid.metaData.description
    Plasmoid.toolTipTextFormat: Text.RichText

    // FIXME: Figure out why representation element doesn't work
    // Plasmoid.compactRepresentation: CompactRepresentation {
    //    icon: main.icon
    //    onDesktop: main.onDesktop
    //}
    // Plasmoid.fullRepresentation: ColumnLayout {}

    CompactRepresentation {
        icon: main.icon
        onDesktop: main.onDesktop
    }
    Layout.preferredWidth: Math.min(main.height,main.width)

    onModeChanged: {
        if (!isLoaded) return
        console.error("MODE CHANGED:",mode);
        plasmoid.configuration.mode = mode
        init()
    }

    function init() {
        if (enabled) {
            colorize()
            if (mode === 1) { 
                rainbowTimer.start()
            } else {
                rainbowTimer.stop()
            }
        } else {
            rainbowTimer.stop()
            destroyRects()
        }
        
    }

    onEnabledChanged: {
        console.log(isLoaded);
        if (!isLoaded) return
        console.error("ENABLED CHANGEDD:",enabled);
        createRects()
        init()
    }

    onColorModeChanged: {
        if (!isLoaded) return
        console.error("COLOR MODE CHANGED:",colorMode);
        init()
    }

    onRainbowLightnessChanged: {
        init()
    }

    onRainbowSaturationChanged: {
        init()
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
    property GridLayout panelLayout: {
        let candidate = main.parent;
        while (candidate) {
            if (candidate instanceof GridLayout) {
                return candidate;
            }
            candidate = candidate.parent;
        }
        return null;
    }

    ListModel {
        id: rectangles
    }

    function nextCustomColor() {
        console.log(customColors);
        const colors = customColors.split(" ")
        let next = colors[currentCustomColorIndex]
        currentCustomColorIndex= currentCustomColorIndex < colors.length - 1 ? currentCustomColorIndex + 1 : 0
        console.log("Next custom color:",currentCustomColorIndex, next);
        return next
    }


    function createRects() {
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
                console.error(child.applet.pluginName);
                // TODO: Code for handling expanded widget action is here but not used yet
                // if (child.applet && (child.applet.pluginName === "org.kde.plasma.systemtray")) {
                //     rectangles.append({
                //         "comp":rectComponent.createObject(
                //             child,
                //             {
                //                 "z": -1,
                //                 "target": child.applet.internalSystray.systemTrayState,
                //                 "color": getColor()
                                
                //             }
                //         )
                //     })
                //     continue
                // }

                
                const name = child.applet.pluginName
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
                            "target":child.applet,
                            "heightOffset":x,
                            "widthOffset":y,
                            "color":getColor()
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
        console.log("colorize mode:",colorMode,rectangles.count);
        for(let i = 0; i < rectangles.count; i++) {
            const newColor = getColor()
            rectangles.get(i)["comp"].changeColor(newColor)
        }
    }

    function destroyRects() {
        for (var i = rectangles.count - 1; i >= 0; i--) {
            var comp = rectangles.get(i)["comp"]
            comp.destroy()
            rectangles.remove(i)
        }
    }

    Timer {
        id: rainbowTimer
        running: false
        repeat: true
        interval: rainbowInterval
        onTriggered: {
            colorize()
        }
    }

    function action_hide() {
        Plasmoid.configuration.hideWidget = Plasmoid.action("hide").checked;
    }

    Component.onCompleted: {
        Plasmoid.setAction("hide", i18n("Hide widget (visible in panel Edit Mode)"))
        var action = Plasmoid.action("hide");
        action.checkable = true;
        action.checked = Qt.binding(function() {Plasmoid.configuration.hideWidget});
        if (!onDesktop) {
            startTimer.start()
        } else {
            console.error("Panel not detected, aborted");
        }
    }

    Timer {
        id: startTimer
        running: true
        repeat: false//(rectangles.count===0)
        interval: 1000
        onTriggered: {
            console.log("STARTED");
            isLoaded = true
            createRects()
            init()
        }
    }
}

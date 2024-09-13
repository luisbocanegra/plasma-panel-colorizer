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

import "components" as Components
import "code/utils.js" as Utils

PlasmoidItem {
    id: main
    preferredRepresentation: fullRepresentation
    property int panelLayoutCount: panelLayout?.children?.length || 0
    property int trayGridViewCount: trayGridView?.count || 0
    property int trayGridViewCountOld: 0
    property var panelPrefixes: ["north","south","west","east"]
    property bool horizontal: Plasmoid.formFactor === PlasmaCore.Types.Horizontal
    property bool fixedSideMarginEnabled: true
    property int fixedSideMarginSize: 4
    property bool isEnabled: true
    property bool panelOriginalBgHidden: true
    property real panelOriginalOpacity: 1
    property var panelWidgets: []
    property int panelWidgetsCount: 0

    property Component backgroundComponent: Kirigami.ShadowedRectangle {
        id: rect
        property Item target
        property int itemType
        radius: 5
        color: "transparent"
        property bool luisbocanegraPanelColorizerBgManaged: true
        height: itemType === Enums.ItemType.TrayItem ? target.height : parent.height
        width: itemType === Enums.ItemType.TrayItem ? target.width : parent.width
        anchors.centerIn: itemType === Enums.ItemType.TrayItem ? parent : undefined
        anchors.fill: itemType === Enums.ItemType.PanelBgItem ? parent : undefined

        property bool addMargin: true
        property int lr: itemType === Enums.ItemType.PanelBgItem ? 6 : itemType === Enums.ItemType.TrayItem ? 2 : 4
        property int rr: itemType === Enums.ItemType.PanelBgItem ? 6 : itemType === Enums.ItemType.TrayItem ? 2 : 4
        property int hr: lr + rr

        property int tr: itemType === Enums.ItemType.PanelBgItem ? 6 : itemType === Enums.ItemType.TrayItem ? 2 : 4
        property int br: itemType === Enums.ItemType.PanelBgItem ? 6 : itemType === Enums.ItemType.TrayItem ? 2 : 4
        property int vr: tr + br

        Binding {
            target: rect
            property: "x"
            value: -lr
            when: addMargin && itemType !== Enums.ItemType.PanelBgItem && itemType !== Enums.ItemType.TrayItem
        }

        Binding {
            target: rect
            property: "width"
            value: itemType === Enums.ItemType.TrayItem ? rect.target.width - hr : parent.width + hr
            when: addMargin
        }

        Binding {
            target: rect.target
            property: "Layout.leftMargin"
            value: lr
            when: addMargin && itemType !== Enums.ItemType.PanelBgItem
        }

        Binding {
            target: rect.target
            property: "Layout.rightMargin"
            value: rr
            when: addMargin && itemType !== Enums.ItemType.PanelBgItem
        }

        Binding {
            target: rect.target
            property: "Layout.topMargin"
            value: tr
            when: addMargin && itemType !== Enums.ItemType.PanelBgItem
        }

        Binding {
            target: rect.target
            property: "Layout.bottomMargin"
            value: br
            when: addMargin && itemType !== Enums.ItemType.PanelBgItem
        }

        Binding {
            target: rect.target
            property: "anchors.leftMargin"
            value: lr
            when: addMargin && itemType === Enums.ItemType.PanelBgItem
        }

        Binding {
            target: rect.target
            property: "anchors.rightMargin"
            value: rr
            when: addMargin && itemType === Enums.ItemType.PanelBgItem
        }

        Binding {
            target: rect.target
            property: "anchors.topMargin"
            value: tr
            when: addMargin && itemType === Enums.ItemType.PanelBgItem
        }

        Binding {
            target: rect.target
            property: "anchors.bottomMargin"
            value: br
            when: addMargin && itemType === Enums.ItemType.PanelBgItem
        }

        Binding {
            target: rect
            property: "height"
            value: rect.target.height - (vr * 2)
            when: addMargin && itemType === Enums.ItemType.TrayItem
        }

        Rectangle {
            id: borderRec
            anchors.fill: parent
            color: "transparent"

            layer.enabled: true
            layer.effect: MultiEffect {
                maskEnabled: true
                maskSpreadAtMax: 1
                maskSpreadAtMin: 1
                maskThresholdMin: 0.5
                maskSource: ShaderEffectSource {
                    sourceItem: Rectangle {
                        width: rect.width
                        height: rect.height
                        radius: rect.radius
                        Behavior on radius {
                            NumberAnimation {
                                duration: 100
                            }
                        }
                    }
                }
            }
        }

        shadow {
            size: 5
            color: Qt.rgba(0,0,0,0.8)
            xOffset: 0
            yOffset: 0
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
        value: fixedSideMarginSize
        when: fixedSideMarginEnabled && horizontal
    }

    Binding {
        target: panelLayoutContainer
        property: "anchors.rightMargin"
        value: fixedSideMarginSize
        when: fixedSideMarginEnabled && horizontal
    }

    Binding {
        target: panelLayoutContainer
        property: "anchors.topMargin"
        value: fixedSideMarginSize
        when: fixedSideMarginEnabled && !horizontal
    }

    Binding {
        target: panelLayoutContainer
        property: "anchors.bottomMargin"
        value: fixedSideMarginSize
        when: fixedSideMarginEnabled && !horizontal
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
        Utils.panelOpacity(panelElement, isEnabled, panelOriginalOpacity)
    }

    onContainmentItemChanged: {
        if(!containmentItem) return
        Utils.toggleTransparency(containmentItem, panelOriginalBgHidden)
    }

    onPanelLayoutCountChanged: {
        if (panelLayoutCount === 0) return
        showWidgets(panelLayout)
        updateCurrentWidgets()
        showPanelBg(panelBg)
    }

    onTrayGridViewCountChanged: {
        if (trayGridViewCount === 0) return
        console.error(trayGridViewCount);
        trayInitTimer.restart()
    }

    Timer {
        id: trayInitTimer
        interval: 5
        onTriggered: {
            if (trayGridViewCount === 0) return
            if (!trayGridView) return
            showTrayAreas(trayGridView)
            showTrayAreas(trayGridView.parent)
            updateCurrentWidgets()
        }
    }

    function updateCurrentWidgets() {
        if (!trayGridView) return
        panelWidgets = []
        panelWidgets = Utils.findWidgets(panelLayout, panelWidgets)
        panelWidgets = Utils.findWidgetsTray(trayGridView, panelWidgets)
        panelWidgets = Utils.findWidgetsTray(trayGridView.parent, panelWidgets)
    }

    function showTrayAreas(grid) {
        if (grid instanceof GridView) {
            for (let i = 0; i < grid.count; i++) {
                const item = grid.itemAtIndex(i);
                if (Utils.isBgManaged(item)) continue
                Utils.dumpProps(item)
                backgroundComponent.createObject(item, {"z":-1, "color": Utils.getRandomColor(), "target": item, "itemType": Enums.ItemType.TrayItem })
            }
        }
        // find the expand tray arrow
        if (grid instanceof GridLayout) {
            for (let i in grid.children) {
                const item = grid.children[i]
                if (!(item instanceof GridView)) {
                    if (Utils.isBgManaged(item)) continue
                    backgroundComponent.createObject(item, {"z":-1, "color": Utils.getRandomColor(), "target": item, "itemType": Enums.ItemType.TrayItem })
                }
            }
        }
    }

    function showWidgets(panelLayout) {
        for (var i in panelLayout.children) {
            const child = panelLayout.children[i];
            // name may not be available while gragging into the panel and
            // other situations
            if (!child.applet?.plasmoid?.pluginName) continue
            if (Utils.isBgManaged(child)) continue
            console.error(child.applet?.plasmoid?.pluginName)
            // Utils.dumpProps(child)
            backgroundComponent.createObject(child, { "z":-1, "color": Utils.getRandomColor(), "target":child, "itemType": Enums.ItemType.WidgetItem });
        }
    }

    function showPanelBg(panelBg) {
        // Utils.dumpProps(panelBg)
        backgroundComponent.createObject(panelBg, {"z":-1, "color": Utils.getRandomColor(), "target": panelBg, "itemType": Enums.ItemType.PanelBgItem });
    }

    onPanelWidgetsCountChanged: {
        console.error( panelWidgetsCount ,JSON.stringify(panelWidgets, null, null))
        plasmoid.configuration.panelWidgets = ""
        plasmoid.configuration.panelWidgets = JSON.stringify(panelWidgets, null, null)
    }

    Timer {
        running: true
        repeat: true
        interval: 1000
        onTriggered: {
            let tmp = panelWidgets.length
            if (tmp !== panelWidgetsCount) {
                panelWidgetsCount = tmp
            }
        }
    }
}

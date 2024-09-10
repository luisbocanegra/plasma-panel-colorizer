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
    preferredRepresentation: fullRepresentation
    property int panelLayoutCount: panelLayout?.children?.length || 0
    property int trayGridViewCount: trayGridView?.count || 0
    property int trayGridViewCountOld: 0

    property Component debugRectComponent: Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.color: "cyan"
        border.width: 1
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
                debugRectComponent.createObject(candidate.parent);
                return candidate;
            }
            candidate = candidate.parent;
        }
        return null
    }

    function findTrayGridView(item) {
        if (!item?.children) return null
        if (item instanceof GridView) {
            return item;
        }
        for (let i = 0; i < item.children.length; i++) {
            let result = findTrayGridView(item.children[i]);
            if (result) {
                return result;
            }
        }
        return null;
    }

    function findTrayExpandArrow(item) {
        if (item instanceof GridLayout) {
            for (let i in item.children) {
                const child = item.children[i]
                if (!(child instanceof GridView)) {
                    return child
                }
            }
        }
        return null
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
                return findTrayGridView(child)
            }
        }
        return null;
    }

    property Item trayExpandArrow: {
        if (trayGridView?.parent) {
            return findTrayExpandArrow(trayGridView.parent)
        }
        return null
    }

    onPanelLayoutCountChanged: {
        if (panelLayoutCount === 0) return
        showWidgets(panelLayout)
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
            showTrayAreas(trayGridView)
            showTrayAreas(trayGridView.parent)
        }
    }

    function showTrayAreas(grid) {
        if (grid instanceof GridView) {
            for (let i = 0; i < grid.count; i++) {
                const item = grid.itemAtIndex(i);
                if (!item) continue
                debugRectComponent.createObject(item, {"z":2, "border.color": "magenta"})
            }
        }
        // find the expand tray arrow
        if (grid instanceof GridLayout) {
            for (let i in grid.children) {
                const item = grid.children[i]
                if (!(item instanceof GridView)) {
                    debugRectComponent.createObject(item, {"z":2, "border.color": "yellow"})
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
            debugRectComponent.createObject(child);
        }
    }
}

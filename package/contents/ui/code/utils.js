function getRandomColor() {
  const h = Math.random()
  const s = Math.max(Math.random(), 0.3)
  const l = 0.4
  const a = 1.0
  return Qt.hsla(h, s, l, a)
}

function isBgManaged(item) {
  let managed = false
  if (item?.children) {
    for (let i in item.children) {
      const child = item.children[i];
      if (!child?.luisbocanegraPanelColorizerBgManaged) continue
      managed = true
    }
  }
  // console.error(item, "managed:", managed);
  return managed
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


function panelOpacity(panelElement, enabled, panelRealBgOpacity) {
  for (let i in panelElement.children) {
    const current = panelElement.children[i]

    if (current.imagePath && current.imagePath.toString().includes("panel-background")) {
      current.opacity = enabled ? panelRealBgOpacity : 1
    }
  }
}

function dumpProps(obj) {
  console.error("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
  console.error(obj);
  for (var k of Object.keys(obj)) {
    const val = obj[k]
    if (typeof val === 'function') continue
    if (k === 'metaData') continue
    console.log(k + "=" + val + "\n")
  }
}

function toggleTransparency(containmentItem, enabled) {
  containmentItem.Plasmoid.backgroundHints = enabled
    ? PlasmaCore.Types.NoBackground
    : PlasmaCore.Types.DefaultBackground
}

function findWidgets(panelLayout, panelWidgets) {
  // console.log("Updating panel widgets list");
  for (let i in panelLayout.children) {
    const child = panelLayout.children[i];
    // name may not be available while gragging into the panel and
    // other situations
    if (!child.applet?.plasmoid?.pluginName) continue
    // Utils.dumpProps(child.applet.plasmoid)
    const name = child.applet.plasmoid.pluginName
    const title = child.applet.plasmoid.title
    const icon = child.applet.plasmoid.icon
    if (panelWidgets.find((item) => item.name === name)) continue
    // console.error(name, title, icon)
    panelWidgets.push({ "name": name, "title": title, "icon": icon, "inTray": false })
  }
  return panelWidgets
}
function findWidgetsTray(grid, panelWidgets) {
  if (grid instanceof GridView) {
    for (let i = 0; i < grid.count; i++) {
      const item = grid.itemAtIndex(i);
      if (!item) continue
      for (let j in item.children) {
        if (!(item.children[j].model)) continue
        const model = item.children[j].model
        // App tray icons
        if (model.itemType === "StatusNotifier") {
          dumpProps(model)
          const name = model.Id
          const title = model.ToolTipTitle !== "" ? model.ToolTipTitle : model.Title
          const icon = model.IconName
          if (panelWidgets.find((item) => item.name === name)) continue
          // console.error(name, title, icon)
          panelWidgets.push({ "name": name, "title": title, "icon": icon, "inTray": true })
        }
        if (model.itemType === "Plasmoid") {
          const applet = model.applet ?? null
          const name = applet?.plasmoid.pluginName ?? ""
          const title = applet?.plasmoid.title ?? ""
          const icon = applet?.plasmoid.icon ?? ""
          if (panelWidgets.find((item) => item.name === name)) continue
          // console.error(name, title, icon)
          panelWidgets.push({ "name": name, "title": title, "icon": icon, "inTray": true })
        }
      }
      // panelWidgets.add(item)
    }
  }
  // find the expand tray arrow
  if (grid instanceof GridLayout) {
    for (let i in grid.children) {
      const item = grid.children[i]
      if (!(item instanceof GridView)) {
        const name = "org.kde.plasma.systemtray.expand"
        if (panelWidgets.find((item) => item.name === name)) continue
        const title = item.subText || "Show hidden icons"
        panelWidgets.push({ "name": name, "title": title, "icon": "arrow-down" })
      }
    }
  }
  return panelWidgets
}

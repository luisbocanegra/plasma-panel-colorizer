function getRandomColor() {
  const h = Math.random()
  const s = Math.random()
  const l = Math.random()
  const a = 1.0
  return Qt.hsla(h, s, l, a)
}

function getBgManaged(item) {
  let managed = null
  if (item?.children) {
    for (let i in item.children) {
      const child = item.children[i];
      if (!child?.luisbocanegraPanelColorizerBgManaged) continue
      managed = child
    }
  }
  // console.error(item, "managed:", managed);
  return managed
}

function getEffectItem(item) {
  let managed = null
  if (item?.children) {
    for (let i in item.children) {
      const child = item.children[i];
      if (!child?.luisbocanegraPanelColorizerEffectManaged) continue
      managed = child
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

function toggleTransparency(containmentItem, nativePanelBackgroundEnabled) {
  containmentItem.Plasmoid.backgroundHints = !nativePanelBackgroundEnabled
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
          // dumpProps(model)
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
        panelWidgets.push({ "name": name, "title": title, "icon": "arrow-down", "inTray": true })
      }
    }
  }
  return panelWidgets
}

function getWidgetName(item) {
  let name = null
  if (item.applet?.plasmoid?.pluginName) {
    name = item.applet.plasmoid.pluginName
  } else if (item.model) {
    const model = item.model
    if (model.itemType === "StatusNotifier") {
      name = model.Id
    } else if (model.itemType === "Plasmoid") {
      const applet = model.applet ?? null
      name = applet?.plasmoid.pluginName ?? null
    }
  }
  // if (name) {
  //   console.error("@@@@ getWidgetName ->", name)
  // }
  return name
}

var themeColors = [
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

var themeScopes = [
  "View",
  "Window",
  "Button",
  "Selection",
  "Tooltip",
  "Complementary",
  "Header"
]

function getCustomCfg(config, widgetName) {
  if (!widgetName) return null
  console.error("getCustomCfg()", config, widgetName)
  let custom = config.perWidgetConfiguration
  if (custom) {
    const cfg = custom.find((cfg) => cfg.widgets.includes(widgetName))
    if (cfg) {
      console.error("customm ->", JSON.stringify(cfg.configuration))
      return cfg.configuration
    }
  }
  return null
}

function getItemCfg(itemType, widgetName, config) {
  let custom = getCustomCfg(config, widgetName)
  // TODO merge only the enabled ones with the global configuration
  if (custom) return custom
  if (itemType === Enums.ItemType.PanelBgItem) {
    return panelSettings
  }
  if (itemType === Enums.ItemType.TrayItem || itemType === Enums.ItemType.TrayArrow) {
    return trayWidgetSettings
  }
  return widgetSettings
}

function scaleSaturation(color, saturation) {
  return Qt.hsla(color.hslHue, saturation, color.hslLightness, color.a);
}

function scaleLightness(color, lightness) {
  return Qt.hsla(color.hslHue, color.hslSaturation, lightness, color.a);
}

function hexToRgb(hex) {
  var result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
  return result ? {
    r: parseInt(result[1], 16),
    g: parseInt(result[2], 16),
    b: parseInt(result[3], 16)
  } : null;
}

function rgbToQtColor(rgb) {
  return Qt.rgba(rgb.r / 255, rgb.g / 255, rgb.b / 255, 1)
}

function mergeConfigs(defaultConfig, existingConfig) {
  for (var key in defaultConfig) {
    if (defaultConfig.hasOwnProperty(key)) {
      if (typeof defaultConfig[key] === "object" && defaultConfig[key] !== null) {
        if (!existingConfig.hasOwnProperty(key)) {
          existingConfig[key] = {}
        }
        mergeConfigs(defaultConfig[key], existingConfig[key])
      } else {
        if (!existingConfig.hasOwnProperty(key)) {
          existingConfig[key] = defaultConfig[key]
        }
      }
    }
  }
  return existingConfig
}

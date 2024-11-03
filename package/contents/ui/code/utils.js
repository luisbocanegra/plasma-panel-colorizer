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
  } else {
    for (let i in item.children) {
      if (!(item.children[i].model)) continue
      const model = item.children[i].model
      if (model.itemType === "StatusNotifier") {
        name = model.Id
      } else if (model.itemType === "Plasmoid") {
        const applet = model.applet ?? null
        name = applet?.plasmoid.pluginName ?? null
      }
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

function getCustomCfg(widgetName, configurationOverrides) {
  if (!widgetName) return null
  var custom = {}
  if (widgetName in configurationOverrides.associations) {
    const overrideNames = configurationOverrides.associations[widgetName]

    for (let overrideName of overrideNames) {
      if (!(overrideName in configurationOverrides.overrides)) continue
      const current = configurationOverrides.overrides[overrideName]
      custom = getEffectiveSettings(current, custom)
    }
  }
  if (Object.keys(custom).length !== 0) {
    return custom
  }
  return null
}

function getGlobalSettings(itemType) {
  let globalSettings = {}
  if (itemType === Enums.ItemType.PanelBgItem) {
    globalSettings = panelSettings
  }
  else if (itemType === Enums.ItemType.TrayItem || itemType === Enums.ItemType.TrayArrow) {
    globalSettings = trayWidgetSettings
  } else {
    globalSettings = widgetSettings
  }
  return globalSettings
}

function getEffectiveSettings(customSettings, globalSettings) {
  let effectiveSettings = JSON.parse(JSON.stringify(customSettings));
  for (var key in customSettings) {
    if (typeof customSettings[key] === "object" && customSettings[key] !== null && globalSettings.hasOwnProperty(key)) {
      effectiveSettings[key] = getEffectiveSettings(customSettings[key], globalSettings[key])
    }
    if (customSettings[key].hasOwnProperty("enabled")) {
      if (!customSettings[key].enabled && globalSettings.hasOwnProperty(key)) {
        effectiveSettings[key] = globalSettings[key]
      }
    }
  }
  return effectiveSettings
}

function getItemCfg(itemType, widgetName, config, configurationOverrides) {
  let output = { override: false }
  let custom = getCustomCfg(widgetName, configurationOverrides)
  let presetOverrides = getCustomCfg(widgetName, config.configurationOverrides)
  if (presetOverrides) {
    if (custom && custom.disabledFallback) {
      custom = getEffectiveSettings(custom, presetOverrides)
    } else {
      custom = presetOverrides
    }
  }
  if (custom) {
    output.settings = custom
    output.override = true
    const disabledFallback = custom.disabledFallback

    if (disabledFallback) {
      const global = getGlobalSettings(itemType)
      output.settings = getEffectiveSettings(custom, global)
    } else {
      output.settings = custom
    }
  } else {
    output.settings = getGlobalSettings(itemType)
  }
  return output
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


function mergeConfigs(sourceConfig, newConfig) {
  for (var key in sourceConfig) {
    if (typeof sourceConfig[key] === "object" && sourceConfig[key] !== null) {
      if (!newConfig.hasOwnProperty(key)) {
        newConfig[key] = {}
      }
      mergeConfigs(sourceConfig[key], newConfig[key])
    } else {
      if (!newConfig.hasOwnProperty(key)) {
        newConfig[key] = sourceConfig[key]
      }
    }
  }
  return newConfig
}

function stringify(config) {
  return JSON.stringify(config, null, null)
}

function loadPreset(presetContent, item, ignoredConfigs, defaults, store) {
  for (let key in presetContent) {
    let val = presetContent[key]
    const cfgKey = "cfg_" + key;
    if (ignoredConfigs.some(function (k) { return key.includes(k) })) continue
    if (key === "globalSettings") {
      val = mergeConfigs(defaults, val)
    }
    const valStr = stringify(val)
    if (store) {
      if (item[key]) item[key] = valStr
    } else {
      if (item[cfgKey]) item[cfgKey] = valStr
    }
    // }
  }
}

function getPresetName(panelState, presetAutoloading) {
  // loop until we find a the currently active 'true' panel state with a configured preset
  // normal is our fallback so does not need active state
  const priority = ["maximized", "touchingWindow", "floating", "normal"]
  for (let state of priority) {
    if ((panelState[state] || state === "normal") && presetAutoloading[state]) {
      console.error("getPresetName()", state, "->", presetAutoloading[state])
      return presetAutoloading[state]
    }
  }
  return null
}


function getGlobalPosition(rect, panelElement) {
  return rect.mapToItem(
    panelElement, 0, 0,
    rect.width,
    rect.height
  )
}

function getUnifyBgType(itemTypes, index) {
  let type = itemTypes[index];
  if (type === 1) {
    return 1;
  } else if (type === 2) {
    return 3;
  } else {
    // Check in between
    let hasType1Before = false;
    let hasType2After = false;
    for (let i = 0; i < index; i++) {
      if (itemTypes[i] === 1) {
        hasType1Before = true;
        break;
      }
    }
    for (let i = index + 1; i < itemTypes.length; i++) {
      if (itemTypes[i] === 1) {
        break
      }
      if (itemTypes[i] === 2) {
        hasType2After = true;
        break;
      }
    }
    if (hasType1Before && hasType2After) {
      return 2;
    }
    return 0; // Default color
  }
}

// https://github.com/rbn42/panon/blob/stable/plasmoid/contents/ui/utils.js
function getWidgetRootDir() {
  var path = plasmoid.metaData.fileName
  path = path.split('/')
  path[path.length - 1] = 'contents/'
  return path.join('/')
}

function getPanelPosition() {
  var location
  var screen = main.screen

  switch (plasmoid.location) {
    case PlasmaCore.Types.TopEdge:
      location = "top"
      break
    case PlasmaCore.Types.BottomEdge:
      location = "bottom"
      break
    case PlasmaCore.Types.LeftEdge:
      location = "left"
      break
    case PlasmaCore.Types.RightEdge:
      location = "right"
      break
  }

  console.log("location:" + location + " screen:" + screen);
  return { "screen": screen, "location": location }
}

function setPanelModeScript(panelPosition, panelSettings) {
  var setPanelModeScript = `
for (var id of panelIds) {
  var panel = panelById(id);
  if (panel.screen === ${panelPosition.screen} && panel.location === "${panelPosition.location}" ) {
    if (${panelSettings.visibility.enabled}) {
      panel.hiding = "${panelSettings.visibility.value}"
    }
    if (${panelSettings.thickness.enabled}) {
      panel.height = ${panelSettings.thickness.value}
    }
    if (${panelSettings.lengthMode.enabled}) {
      panel.lengthMode = "${panelSettings.lengthMode.value}"
    }
    if (${panelSettings.position.enabled}) {
      panel.location = "${panelSettings.position.value}"
    }
    if (${panelSettings.floating.enabled}) {
      panel.floating = ${panelSettings.floating.value}
    }
    if (${panelSettings.alignment.enabled}) {
      panel.alignment = "${panelSettings.alignment.value}"
    }
    if (${panelSettings.opacity.enabled}) {
      panel.opacity = "${panelSettings.opacity.value}"
    }
    break
  }
}`
  return setPanelModeScript
}

function evaluateScript(script) {
  console.error(script)
  runCommand.run("gdbus call --session --dest org.kde.plasmashell --object-path /PlasmaShell --method org.kde.PlasmaShell.evaluateScript '" + script + "'")
}

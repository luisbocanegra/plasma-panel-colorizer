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
    if (k.endsWith("Changed")) continue
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
    const id = child.applet.plasmoid.id
    const name = child.applet.plasmoid.pluginName
    const title = child.applet.plasmoid.title
    const icon = child.applet.plasmoid.icon
    if (panelWidgets.find((item) => item.id === id)) continue
    // console.error(name, title, icon)
    panelWidgets.push({ "id": id, "name": name, "title": title, "icon": icon, "inTray": false })
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
          // in contrast with applet?.plasmoid.id, Id is not actually given by plasma,
          // but since there should be only a single instance of StatusNotifier per app,
          // model.Id _should_ be enough for any sane implementation of tray icon
          const name = model.Id
          const title = model.ToolTipTitle !== "" ? model.ToolTipTitle : model.Title
          const icon = model.IconName
          if (panelWidgets.find((item) => item.name === name)) continue
          // console.error(name, title, icon)
          panelWidgets.push({ "id": -1, "name": name, "title": title, "icon": icon, "inTray": true })
        }
        // normal plasmoids in tray
        if (model.itemType === "Plasmoid") {
          const applet = model.applet ?? null
          const id = applet?.plasmoid.id ?? -1
          const name = applet?.plasmoid.pluginName ?? ""
          const title = applet?.plasmoid.title ?? ""
          const icon = applet?.plasmoid.icon ?? ""
          if (panelWidgets.find((item) => item.id === id)) continue
          // console.error(name, title, icon)
          panelWidgets.push({ "id": id, "name": name, "title": title, "icon": icon, "inTray": true })
        }
      }
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
        panelWidgets.push({ "id": -1, "name": name, "title": title, "icon": "arrow-down", "inTray": true })
      }
    }
  }
  return panelWidgets
}

function getWidgetNameAndId(item) {
  let name = ""
  let id = -1
  if (item.applet?.plasmoid?.pluginName) {
    name = item.applet.plasmoid.pluginName
    id = item.applet.plasmoid.id
  } else {
    for (let i in item.children) {
      if (!(item.children[i].model)) continue
      const model = item.children[i].model
      if (model.itemType === "StatusNotifier") {
        name = model.Id
      } else if (model.itemType === "Plasmoid") {
        const applet = model.applet ?? null
        name = applet?.plasmoid.pluginName ?? ""
        id = applet?.plasmoid.id ?? -1
      }
    }
  }
  // if (name) {
  //   console.error("@@@@ getWidgetName ->", name)
  // }
  return { name, id }
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

function getWidgetAsocIdx(id, name, config) {
  // console.log("getWidgetAsocIdx()")
  return config.findIndex((item) => item.id == id && item.name == name)
}

function getCustomCfg(widgetName, widgetId, configurationOverrides) {
  if (!widgetId) return null
  var custom = {}
  configurationOverrides.associations = clearOldWidgetConfig(configurationOverrides.associations)
  let asocIndex = getWidgetAsocIdx(widgetId, widgetName, configurationOverrides.associations)
  if (asocIndex !== -1) {

    const overrideNames = configurationOverrides.associations[asocIndex].presets

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

function getItemCfg(itemType, widgetName, widgetId, config, configurationOverrides) {
  let output = { override: false }
  let custom = getCustomCfg(widgetName, widgetId, configurationOverrides)
  let presetOverrides = getCustomCfg(widgetName, widgetId, config.configurationOverrides)
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
  if (presetAutoloading.hasOwnProperty("enabled") && !presetAutoloading.enabled) return null
  // loop until we find a the currently active 'true' panel state with a configured preset
  // normal is our fallback so does not need active state
  const priority = ["fullscreenWindow", "maximized", "touchingWindow", "visibleWindows", "floating", "normal"]
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

function setPanelModeScript(panelId, panelSettings) {
  var setPanelModeScript = `
var panel = panelById(${panelId});
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
}`;
  return setPanelModeScript;
}

function evaluateScript(script) {
  runCommand.run("gdbus call --session --dest org.kde.plasmashell --object-path /PlasmaShell --method org.kde.PlasmaShell.evaluateScript '" + script + "'")
}

function getForceFgWidgetConfig(id, name, config) {
  return config.find((item) => item.id == id && item.name == name)
}

function clearOldWidgetConfig(config) {
  if (Array.isArray(config)) {
    return config
  }
  else return []
}

function getWidgetConfigIdx(id, name, config) {
  // console.log("getWidgetConfigIdx()")
  return config.findIndex((item) => item.id == id && item.name == name)
}

function makeEven(n) {
  return n - n % 2
}

function parseValue(rawValue) {
  try {
      return JSON.parse(rawValue)
  } catch (e) {
      if (rawValue.toLowerCase() === "true") {
          return true
      }
      if (rawValue.toLowerCase() === "false") {
          return false
      }
      if (!isNaN(rawValue)) {
          return Number(rawValue)
      }

      return rawValue
  }
}

/**
* Edit an existing object property using dot and square brackets notation
* Overrides objects if the new value is also an object
* For array allows setting per index (appending if not consecutive) or replacing with a new array
* @param {Object} object - The object to set the property on.
* @param {string} path - The path to the property.
* @param {string} value - The value to set.
*/
function editProperty(object, path, value) {
  console.log(`editing property path: '${path}' value: '${value}'`)
  value = parseValue(value)
  const keys = path.replace(/\[/g, ".").replace(/\]/g, "").split(".")
  let current = object

  for (let i = 0; i < keys.length - 1; i++) {
      const key = keys[i]
      if (!current.hasOwnProperty(key)) return
      current = current[key]
      if (typeof current !== "object" || current === null) return
  }

  const lastKey = keys[keys.length - 1]

  // no new keys unless it's an array
  if (!current.hasOwnProperty(lastKey) && !Array.isArray(current)) return

  if (Array.isArray(current)) {
    const index = parseInt(lastKey, 10)
    // add to array if it's the next index
    if (index === current.length) {
        current.push(value)
    } else if (index < current.length) {
        current[index] = value
    } else if (Array.isArray(value)) {
        current[lastKey] = value
    } else {
        return
    }
  } else if (
    typeof current[lastKey] === "object" &&
    current[lastKey] !== null
  ) {
    // override only if the new value is an object
    if (typeof value === "object" && value !== null) {
        current[lastKey] = value
    } else {
        return
    }
  } else {
      current[lastKey] = value
  }
}

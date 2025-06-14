function getRandomColor() {
  const h = Math.random();
  const s = Math.random();
  const l = Math.random();
  const a = 1.0;
  return Qt.hsla(h, s, l, a);
}

function getBgManaged(item) {
  let managed = null;
  if (item?.children) {
    for (let i in item.children) {
      const child = item.children[i];
      if (!child?.luisbocanegraPanelColorizerBgManaged) continue;
      managed = child;
    }
  }
  // console.error(item, "managed:", managed);
  return managed;
}

function getEffectItem(item) {
  let managed = null;
  if (item?.children) {
    for (let i in item.children) {
      const child = item.children[i];
      if (!child?.luisbocanegraPanelColorizerEffectManaged) continue;
      managed = child;
    }
  }
  // console.error(item, "managed:", managed);
  return managed;
}

function findTrayGridView(item) {
  if (!item?.children) return null;
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
      const child = item.children[i];
      if (!(child instanceof GridView)) {
        return child;
      }
    }
  }
  return null;
}

function panelOpacity(panelElement, enabled, panelRealBgOpacity) {
  if (!panelElement) return;
  for (let i in panelElement.children) {
    const current = panelElement.children[i];

    if (
      current.imagePath &&
      current.imagePath.toString().includes("panel-background")
    ) {
      current.opacity = enabled ? panelRealBgOpacity : 1;
    }
  }
}

function dumpProps(obj) {
  console.error("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
  console.error(obj);
  for (var k of Object.keys(obj)) {
    const val = obj[k];
    if (k.endsWith("Changed")) continue;
    if (k === "metaData") continue;
    console.log(k + "=" + val + "\n");
  }
}

function toggleTransparency(containmentItem, nativePanelBackgroundEnabled) {
  if (!containmentItem) return;
  containmentItem.Plasmoid.backgroundHints = !nativePanelBackgroundEnabled
    ? PlasmaCore.Types.NoBackground
    : PlasmaCore.Types.DefaultBackground;
}

function findWidgets(panelLayout, panelWidgets) {
  if (!panelLayout) return panelWidgets;
  // console.log("Updating panel widgets list");
  for (let i in panelLayout.children) {
    const child = panelLayout.children[i];
    // name may not be available while gragging into the panel and
    // other situations
    if (!child.applet?.plasmoid?.pluginName) continue;
    // Utils.dumpProps(child.applet.plasmoid)
    const id = child.applet.plasmoid.id;
    const name = child.applet.plasmoid.pluginName;
    const title = child.applet.plasmoid.title;
    const icon = child.applet.plasmoid.icon;
    if (panelWidgets.find((item) => item.id === id)) continue;
    // console.error(name, title, icon)
    panelWidgets.push({
      id: id,
      name: name,
      title: title,
      icon: icon,
      inTray: false,
    });
  }
  return panelWidgets;
}
function findWidgetsTray(grid, panelWidgets) {
  if (!grid) return panelWidgets;
  if (grid instanceof GridView) {
    for (let i = 0; i < grid.count; i++) {
      const item = grid.itemAtIndex(i);
      if (!item) continue;
      for (let j in item.children) {
        if (!item.children[j].model) continue;
        const model = item.children[j].model;
        // App tray icons
        if (model.itemType === "StatusNotifier") {
          // in contrast with applet?.plasmoid.id, Id is not actually given by plasma,
          // but since there should be only a single instance of StatusNotifier per app,
          // model.Id _should_ be enough for any sane implementation of tray icon
          const name = model.Id;
          const title =
            model.ToolTipTitle !== "" ? model.ToolTipTitle : model.Title;
          const icon = model.IconName;
          if (panelWidgets.find((item) => item.name === name)) continue;
          // console.error(name, title, icon)
          panelWidgets.push({
            id: -1,
            name: name,
            title: title,
            icon: icon,
            inTray: true,
          });
        }
        // normal plasmoids in tray
        if (model.itemType === "Plasmoid") {
          const applet = model.applet ?? null;
          const id = applet?.plasmoid.id ?? -1;
          const name = applet?.plasmoid.pluginName ?? "";
          const title = applet?.plasmoid.title ?? "";
          const icon = applet?.plasmoid.icon ?? "";
          if (panelWidgets.find((item) => item.id === id)) continue;
          // console.error(name, title, icon)
          panelWidgets.push({
            id: id,
            name: name,
            title: title,
            icon: icon,
            inTray: true,
          });
        }
      }
    }
  }
  // find the expand tray arrow
  if (grid instanceof GridLayout) {
    for (let i in grid.children) {
      const item = grid.children[i];
      if (!(item instanceof GridView)) {
        const name = "org.kde.plasma.systemtray.expand";
        if (panelWidgets.find((item) => item.name === name)) continue;
        const title = item.subText || "Show hidden icons";
        panelWidgets.push({
          id: -1,
          name: name,
          title: title,
          icon: "arrow-down",
          inTray: true,
        });
      }
    }
  }
  return panelWidgets;
}

function getSystemTrayState(applet, plasmaVersion) {
  if (!applet) {
    return null
  }
  let systemTrayState = null
  if (plasmaVersion.isGreaterThan("6.3.5")) {
    systemTrayState = "systemTrayState" in applet && (applet.systemTrayState)
  } else {
    systemTrayState = "internalSystray" in applet && (applet.internalSystray.systemTrayState)
  }
  return systemTrayState
}

function getWidgetProperties(item, pcTypes, hovered, plasmaVersion) {
  let name = "";
  let id = -1;
  let expanded = false;
  let needsAttention = false;
  let busy = false;
  if (!item) return { name, id };
  if (item.applet?.plasmoid?.pluginName) {
    const applet = item.applet;
    name = applet.plasmoid.pluginName;
    id = applet.plasmoid.id ?? -1;
    if (applet.compactRepresentationItem !== null) {
      expanded = applet.expanded
    } else {
      expanded = getSystemTrayState(applet, plasmaVersion)?.expanded ?? false
    }
    needsAttention = pcTypes.NeedsAttentionStatus === applet.plasmoid.status ?? null;
    busy = applet.plasmoid.busy
  } else {
    for (let i in item.children) {
      if (!item?.children[i]?.model) continue;
      const model = item.children[i].model;
      if (model.itemType === "StatusNotifier") {
        name = model.Id;
        needsAttention = pcTypes.NeedsAttentionStatus === model.status;
        break;
      } else if (model.itemType === "Plasmoid") {
        const applet = model.applet;
        name = applet.plasmoid.pluginName ?? "";
        id = applet.plasmoid.id ?? -1;
        expanded = applet.compactRepresentationItem !== null && applet.expanded;
        needsAttention = pcTypes.NeedsAttentionStatus === applet.plasmoid.status;
        busy = applet.plasmoid.busy
        break;
      }
    }
  }
  return { name, id, expanded, needsAttention, busy, hovered};
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
  "hoverColor",
];

var themeScopes = [
  "View",
  "Window",
  "Button",
  "Selection",
  "Tooltip",
  "Complementary",
  "Header",
];

function getWidgetAsocIdx(id, name, config) {
  // console.log("getWidgetAsocIdx()")
  return config.findIndex((item) => item.id == id && item.name == name);
}

function getCustomCfg(widgetName, widgetId, configurationOverrides) {
  if (!widgetId) return null;
  var custom = {};
  configurationOverrides.associations = clearOldWidgetConfig(
    configurationOverrides.associations,
  );
  let asocIndex = getWidgetAsocIdx(
    widgetId,
    widgetName,
    configurationOverrides.associations,
  );
  if (asocIndex !== -1) {
    const overrideNames =
      configurationOverrides.associations[asocIndex].presets;

    for (let overrideName of overrideNames) {
      if (!(overrideName in configurationOverrides.overrides)) continue;
      const current = configurationOverrides.overrides[overrideName];
      custom = getEffectiveSettings(current, custom);
    }
  }
  if (Object.keys(custom).length !== 0) {
    return custom;
  }
  return null;
}

function getGlobalSettings(itemType) {
  let globalSettings = {};
  if (itemType === Enums.ItemType.PanelBgItem) {
    globalSettings = panelSettings;
  } else if (
    itemType === Enums.ItemType.TrayItem ||
    itemType === Enums.ItemType.TrayArrow
  ) {
    globalSettings = trayWidgetSettings;
  } else {
    globalSettings = widgetSettings;
  }
  return globalSettings;
}

function getEffectiveSettings(customSettings, globalSettings) {
  let effectiveSettings = JSON.parse(JSON.stringify(customSettings));
  for (var key in customSettings) {
    if (
      typeof customSettings[key] === "object" &&
      customSettings[key] !== null &&
      globalSettings.hasOwnProperty(key)
    ) {
      effectiveSettings[key] = getEffectiveSettings(
        customSettings[key],
        globalSettings[key],
      );
    }
    if (customSettings[key].hasOwnProperty("enabled")) {
      if (!customSettings[key].enabled && globalSettings.hasOwnProperty(key)) {
        effectiveSettings[key] = globalSettings[key];
      }
    }
  }
  return effectiveSettings;
}

function getElementStateConfig(config, state) {
  if (!config) {
    return null
  }
  let stateConfig = config.normal;

  if (state.busy && config.busy.enabled) {
      stateConfig = Utils.getEffectiveSettings(config.busy, stateConfig);
  }

  if (state.needsAttention && config.needsAttention.enabled) {
      stateConfig = Utils.getEffectiveSettings(config.needsAttention, stateConfig);
  }

  if (state.hovered && config.hovered.enabled) {
      stateConfig = Utils.getEffectiveSettings(config.hovered, stateConfig);
  }

  if (state.expanded && config.expanded.enabled) {
      stateConfig = Utils.getEffectiveSettings(config.expanded, stateConfig);
  }
  return stateConfig;
}

function getItemCfg(
  itemType,
  widgetName,
  widgetId,
  config,
  globalOverrides,
  busy,
  needsAttention,
  hovered,
  expanded
) {
  let output = { override: false };
  let state = { busy, needsAttention, hovered, expanded }
  let globalOverrideConfig = getCustomCfg(widgetName, widgetId, globalOverrides)
  let globalOverride = getElementStateConfig(globalOverrideConfig, state);
  let presetOverride = getElementStateConfig(getCustomCfg(
    widgetName,
    widgetId,
    config.configurationOverrides,
  ), state);

  output.settings = getElementStateConfig(getGlobalSettings(itemType), state)

  if (presetOverride) {
    output.settings = getEffectiveSettings(presetOverride, output.settings);
  }

  if (globalOverride) {
    if (globalOverrideConfig.disabledFallback) {
      output.settings = getEffectiveSettings(globalOverride, output.settings);
    } else {
      output.settings = globalOverride
    }
  }
  return output;
}

function scaleSaturation(color, saturation) {
  return Qt.hsla(color.hslHue, saturation, color.hslLightness, color.a);
}

function scaleLightness(color, lightness) {
  return Qt.hsla(color.hslHue, color.hslSaturation, lightness, color.a);
}

function hexToRgb(hex) {
  var result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
  return result
    ? {
        r: parseInt(result[1], 16),
        g: parseInt(result[2], 16),
        b: parseInt(result[3], 16),
      }
    : null;
}

function rgbToQtColor(rgb) {
  return Qt.rgba(rgb.r / 255, rgb.g / 255, rgb.b / 255, 1);
}

function fixArraysAsObjects(config) {
  for (var key in config) {
    // skip overrides because they are intentionally saved as key-value and
    // may be empty or intentionally named with numbers by the user
    if (key === "overrides") {
      continue
    }
    if (typeof config[key] === "object" && config[key] !== null) {
      if (!Array.isArray(config[key])) {
        const isArrayInDisguise = Object.keys(config[key]).every(
          k => !isNaN(Number(k))
        );
        if (isArrayInDisguise) {
          config[key] = Object.values(config[key]);
        } else {
          fixArraysAsObjects(config[key]);
        }
      } else {
        fixArraysAsObjects(config[key]);
      }
    }
  }
}

function mergeConfigs(sourceConfig, newConfig) {
  fixArraysAsObjects(newConfig)
  for (var key in sourceConfig) {
    if (Array.isArray(sourceConfig[key])) {
      if (!newConfig.hasOwnProperty(key)) {
        newConfig[key] = sourceConfig[key].slice();
      }
    } else if (typeof sourceConfig[key] === "object" && sourceConfig[key] !== null) {
      if (!newConfig.hasOwnProperty(key)) {
        newConfig[key] = {};
      }
      mergeConfigs(sourceConfig[key], newConfig[key]);
    } else {
      if (!newConfig.hasOwnProperty(key)) {
        newConfig[key] = sourceConfig[key];
      }
    }
  }
  return newConfig;
}

function stringify(config) {
  return JSON.stringify(config, null, null);
}

function loadPreset(presetContent, item, ignoredConfigs, defaults, store) {
  for (let key in presetContent) {
    let val = presetContent[key];
    const cfgKey = "cfg_" + key;
    if (
      ignoredConfigs.some(function (k) {
        return key.includes(k);
      })
    )
      continue;
    if (key === "globalSettings") {
      val = val
    }
    const valStr = stringify(val);
    if (store) {
      if (item[key]) item[key] = valStr;
    } else {
      if (item[cfgKey]) item[cfgKey] = valStr;
    }
    // }
  }
}

function getPresetName(panelState, presetAutoloading) {
  if (presetAutoloading.hasOwnProperty("enabled") && !presetAutoloading.enabled)
    return null;
  // loop until we find a the currently active 'true' panel state with a configured preset
  // normal is our fallback so does not need active state
  const priority = [
    "fullscreenWindow",
    "maximized",
    "touchingWindow",
    "activeWindow",
    "visibleWindows",
    "floating",
    "activity",
    "normal",
  ];
  let preset = null
  for (let state of priority) {
    if ((panelState[state] || state === "normal") && presetAutoloading[state]) {
      if (state === "activity") {
        preset = presetAutoloading.activity[panelState[state]]
      } else {
        preset = presetAutoloading[state]
      }
      if (preset) break
    }
  }
  return preset || presetAutoloading.normal;
}

function getGlobalPosition(rect, panelElement) {
  return rect.mapToItem(panelElement, 0, 0, rect.width, rect.height);
}

function getUnifyBgTypes(itemTypes) {
  // 0: default or middle | 1: start | 2: end
  let areas = [[]]
  for (let i = 0; i < itemTypes.length; i++) {
    const item = itemTypes[i]
    if (!item) continue

    areas[areas.length - 1].push(item)
    if ( (itemTypes.length > i + 1 && itemTypes[i+1]?.type === 1) || itemTypes[i]?.type === 3) {
        areas[areas.length] = []
    }
  }
  // remove invalid areas
  areas = removeInvalidAreas(areas)
  areas.forEach(area => shrinkAreaIfNeeded(area));
  // shrinking may leave invalid areas
  areas = removeInvalidAreas(areas)
  areas = setMiddleAreaType(areas)
  return Array.prototype.concat.apply([], areas)
}

function setMiddleAreaType(areas) {
  areas.forEach((area) => {
    return area.forEach((item, index) => {
      if (index !== area.length - 1 && index !== 0) {
        item.type = 2
      }
    });
  })
  return areas
}

function removeInvalidAreas(areas) {
  return areas.filter(area => {
    return area.length > 1 && area[0].type === 1 && area[area.length - 1].type === 3
  })
}

function shrinkAreaIfNeeded(area) {
  let lo = 0
  let hi = area.length - 1
  while (lo < hi) {
    if (!area[0].visible) {
      // shift start to next item
      area[1].type = area[0].type
      area.shift()
    }
    if (!area[area.length - 1].visible) {
      // shift end to next item
      area[area.length - 2].type = area[area.length - 1].type
      area.pop()
    }
    lo++
    hi--
  }
  return area
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
}
if (${panelSettings.screen.enabled}) {
  panel.screen = ${panelSettings.screen.value}
}
`;
  return setPanelModeScript;
}

function getForceFgWidgetConfig(id, name, config) {
  return config.find((item) => item.id == id && item.name == name);
}

function clearOldWidgetConfig(config) {
  if (Array.isArray(config)) {
    return config;
  } else return [];
}

function fixV2UnifiedWidgetConfig(config) {
  config.forEach(widget => {
    if (widget.unifyBgType === 2) {
      widget.unifyBgType = 3
    }
  })
  return config
}

function getWidgetConfigIdx(id, name, config) {
  // console.log("getWidgetConfigIdx()")
  return config.findIndex((item) => item.id == id && item.name == name);
}

function makeEven(n) {
  return n - (n % 2);
}

function parseValue(rawValue) {
  try {
    return JSON.parse(rawValue);
  } catch (e) {
    if (rawValue.toLowerCase() === "true") {
      return true;
    }
    if (rawValue.toLowerCase() === "false") {
      return false;
    }
    if (!isNaN(rawValue)) {
      return Number(rawValue);
    }

    return rawValue;
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
  console.log(`editing property path: '${path}' value: '${value}'`);
  value = parseValue(value);
  const keys = path.replace(/\[/g, ".").replace(/\]/g, "").split(".");
  let current = object;

  for (let i = 0; i < keys.length - 1; i++) {
    const key = keys[i];
    if (!current.hasOwnProperty(key)) return;
    current = current[key];
    if (typeof current !== "object" || current === null) return;
  }

  const lastKey = keys[keys.length - 1];

  // no new keys unless it's an array
  if (!current.hasOwnProperty(lastKey) && !Array.isArray(current)) return;

  if (Array.isArray(current)) {
    const index = parseInt(lastKey, 10);
    // add to array if it's the next index
    if (index === current.length) {
      current.push(value);
    } else if (index < current.length) {
      current[index] = value;
    } else if (Array.isArray(value)) {
      current[lastKey] = value;
    } else {
      return;
    }
  } else if (
    typeof current[lastKey] === "object" &&
    current[lastKey] !== null
  ) {
    // override only if the new value is an object
    if (typeof value === "object" && value !== null) {
      current[lastKey] = value;
    } else {
      return;
    }
  } else {
    current[lastKey] = value;
  }
}

// https://stackoverflow.com/questions/28507619/how-to-create-delay-function-in-qml
function delay(interval, callback, parentItem) {
  let timer = Qt.createQmlObject("import QtQuick; Timer {}", parentItem);
  timer.interval = interval;
  timer.repeat = false;
  timer.triggered.connect(callback);
  timer.triggered.connect(function release() {
    timer.triggered.disconnect(callback);
    timer.triggered.disconnect(release);
    timer.destroy();
  });
  timer.start();
}

function fixElementSettingsV3(elementSettings) {
  for (let key of ["panel", "widgets", "trayWidgets"]) {
    if (!("key" in elementSettings)) {
      continue
    }
    const current = elementSettings[key];
    if ("normal" in current) {
        continue;
    }
    elementSettings[key] = {};
    elementSettings[key].normal = current;
  }
}

function fixConfigurationOverridesV3(configurationOverrides) {
  if (!configurationOverrides) {
    return
  }
  if (Object.keys(configurationOverrides)) {
    Object.keys(configurationOverrides).forEach(key => {

      if (!("normal" in configurationOverrides[key])) {
        const current = configurationOverrides[key]
        configurationOverrides[key] = {}
        configurationOverrides[key].normal = current
        configurationOverrides[key].disabledFallback = current.disabledFallback ?? true
      }
    })
  }
}

function fixGlobalSettingsV3(globalSettings) {
  if (!globalSettings || !Object.keys.length) {
    return
  }
  fixElementSettingsV3(globalSettings)
  let floatingDialogs = false;
  if (globalSettings?.panel?.normal?.floatingDialogs !== undefined && "floatingDialogs" in globalSettings.panel.normal.floatingDialogs) {
      floatingDialogs = globalSettings.panel.normal.floatingDialogs;
      delete globalSettings.panel.normal.floatingDialogs;
  }
  let nativePanelBackground = true;
  let nativePanelOpacity = 1.0;
  let nativePanelShadow = true;
  if ("nativePanelBackground" in globalSettings && !("nativePanel" in globalSettings)) {
      nativePanelBackground = globalSettings.nativePanelBackground?.enabled ?? true;
      nativePanelOpacity = globalSettings.nativePanelBackground?.opacity ?? 1.0;
      nativePanelShadow = globalSettings.nativePanelBackground?.shadow ?? true;
      globalSettings.nativePanel = {
          background: {}
      };
      globalSettings.nativePanel.background.enabled = nativePanelBackground;
      globalSettings.nativePanel.background.opacity = nativePanelOpacity;
      globalSettings.nativePanel.background.shadow = nativePanelShadow;
      globalSettings.nativePanel.floatingDialogs = floatingDialogs;
  }
  fixConfigurationOverridesV3(globalSettings.configurationOverrides?.overrides ?? null)
}

// a rudimentary way to parse gdbus GVariant into a valid js object
function parseGVariant(str) {
  str = gVariantTupleToArray(str);
  str = str.trim().replace(/^\([']?/, "") // remove starting ( or ('
    .replace(/[']?[,]?\)$/, ""); // remove ending ,) or ',)

  // remove GVariant typing thingy e.g <(uint32 ...,)> or <@as ...> <...> <[...]>
  str = str.replace(/<[\(]?\s*(.+?)[,]?\s*[\)]?>/g, "$1").replace(/@as |uint32 /g, '');

  if (str === "") return "";
  if (str === "true") return true;
  if (str === "false") return false;
  if (str === "null") return null;
  if (/^-?\d+(\.\d+)?$/.test(str)) return Number(str);

  // try to parse as array or dictionary
  if (/^[\[]?[\{]?.*[\]]?[\}]?$/.test(str)) {
    try {
      return JSON.parse(str.replace(/'null'/g, "null").replace(/'/g, '"'));
    } catch (e) {
      return str;
    }
  }
  return str.replace(/^['"]|['"]$/g, "").trim();
}

// convert GVariant tuples to arrays
function gVariantTupleToArray(str) {
  // convert all tuples like (..., ...) arrays [..., ...]
  return str.replace(/\(([^()]+?)\)/g, (_, inner) => {
    // only replace if it's NOT inside a JSON-style key or between quotes
    if (/^[^:][^']+,[^:][^']+$/.test(inner)) {
      return `[${inner}]`;
    }
    return `(${inner})`;
  });
}

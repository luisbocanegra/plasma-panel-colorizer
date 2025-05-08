const baseColorList = [
  "#ED8796",
  "#A6DA95",
  "#EED49F",
  "#8AADF4",
  "#F5BDE6",
  "#8BD5CA",
  "#f5a97f",
];

const baseGradientList = [
  { color: "#ff0000", position: 0 },
  { color: "#f9f54e", position: 0.25 },
  { color: "#21fd00", position: 0.5 },
  { color: "#0e1eff", position: 0.75 },
  { color: "#fd12ff", position: 1 }
]

const baseGradientConfig = {
  stops: baseGradientList,
  orientation: 0
}

const baseImageConfig = {
  source: "",
  fillMode: 2
}

const baseAnimation = {
  enabled: false,
  interval: 3000,
  smoothing: 800,
};

const basePanelBgColor = {
  enabled: true,
  lightnessValue: 0.5,
  saturationValue: 0.5,
  alpha: 1,
  systemColor: "backgroundColor",
  systemColorSet: "View",
  custom: "#013eff",
  list: baseColorList,
  followColor: 0,
  saturationEnabled: false,
  lightnessEnabled: false,
  animation: baseAnimation,
  sourceType: 1,
  gradient: baseGradientConfig,
  image: baseImageConfig
};

const baseBgColor = {
  enabled: false,
  lightnessValue: 0.5,
  saturationValue: 0.5,
  alpha: 1,
  systemColor: "backgroundColor",
  systemColorSet: "View",
  custom: "#013eff",
  list: baseColorList,
  followColor: 0,
  saturationEnabled: false,
  lightnessEnabled: false,
  animation: baseAnimation,
  sourceType: 1,
  gradient: baseGradientConfig,
  image: baseImageConfig
};

const baseFgColor = {
  enabled: false,
  lightnessValue: 0.5,
  saturationValue: 0.5,
  alpha: 1,
  systemColor: "highlightColor",
  systemColorSet: "View",
  custom: "#fc0000",
  list: baseColorList,
  followColor: 0,
  saturationEnabled: false,
  lightnessEnabled: false,
  animation: baseAnimation,
  sourceType: 1,
};

const baseBorderColor = {
  lightnessValue: 0.5,
  saturationValue: 0.5,
  alpha: 1,
  systemColor: "highlightColor",
  systemColorSet: "View",
  custom: "#ff6c06",
  list: baseColorList,
  followColor: 0,
  saturationEnabled: false,
  lightnessEnabled: false,
  animation: baseAnimation,
  sourceType: 1,
  enabled: true,
};

const baseShadowColor = {
  lightnessValue: 0.5,
  saturationValue: 0.5,
  alpha: 1,
  systemColor: "backgroundColor",
  systemColorSet: "View",
  custom: "#282828",
  list: baseColorList,
  followColor: 0,
  saturationEnabled: false,
  lightnessEnabled: false,
  animation: baseAnimation,
  sourceType: 1,
  enabled: true,
};

const baseShadow = {
  enabled: false,
  color: baseShadowColor,
  size: 5,
  xOffset: 0,
  yOffset: 0,
};

const baseShadowConfig = {
  background: baseShadow,
  foreground: baseShadow,
};

const baseRadius = {
  enabled: false,
  corner: {
    topLeft: 5,
    topRight: 5,
    bottomRight: 5,
    bottomLeft: 5,
  },
};

const baseMargin = {
  enabled: false,
  side: {
    right: 0,
    left: 0,
    top: 0,
    bottom: 0,
  },
};

const baseBorder = {
  enabled: false,
  customSides: false,
  custom: {
    widths: {
      left: 0,
      bottom: 3,
      right: 0,
      top: 0,
    },
    margin: baseMargin,
    radius: baseRadius,
  },
  width: 0,
  color: baseBorderColor,
};

const basePadding = {
  enabled: false,
  side: {
    right: 0,
    left: 0,
    top: 0,
    bottom: 0,
  },
};

const basePanelConfig = {
  enabled: false,
  blurBehind: false,
  backgroundColor: basePanelBgColor,
  foregroundColor: baseFgColor,
  radius: baseRadius,
  margin: baseMargin,
  padding: basePadding,
  border: baseBorder,
  borderSecondary: baseBorder,
  shadow: baseShadowConfig,
  floatingDialogs: false,
};

const baseWidgetConfig = {
  enabled: true,
  blurBehind: false,
  backgroundColor: baseBgColor,
  foregroundColor: baseFgColor,
  radius: baseRadius,
  margin: baseMargin,
  spacing: 4,
  border: baseBorder,
  borderSecondary: baseBorder,
  shadow: baseShadowConfig,
};

const baseTrayConfig = {
  enabled: false,
  blurBehind: false,
  backgroundColor: baseBgColor,
  foregroundColor: baseFgColor,
  radius: baseRadius,
  margin: baseMargin,
  border: baseBorder,
  borderSecondary: baseBorder,
  shadow: baseShadowConfig,
};

const baseOverrideConfig = {
  blurBehind: false,
  backgroundColor: baseBgColor,
  foregroundColor: baseFgColor,
  radius: baseRadius,
  margin: baseMargin,
  spacing: 4,
  border: baseBorder,
  borderSecondary: baseBorder,
  shadow: baseShadowConfig,
  enabled: true,
  disabledFallback: true,
};

const baseStockPanelSettings = {
  screen: {
    enabled: false,
    value: 0,
  },
  position: {
    enabled: false,
    value: "top",
  },
  alignment: {
    enabled: false,
    value: "center",
  },
  lengthMode: {
    enabled: false,
    value: "fill",
  },
  visibility: {
    enabled: false,
    value: "none",
  },
  opacity: {
    enabled: false,
    value: "adaptive",
  },
  floating: {
    enabled: false,
    value: false,
  },
  thickness: {
    enabled: false,
    value: 48,
  },
  visible: {
    enabled: false,
    value: true,
  },
};

const defaultConfig = {
  panel: basePanelConfig,
  widgets: baseWidgetConfig,
  trayWidgets: baseTrayConfig,
  nativePanelBackground: {
    enabled: true,
    opacity: 1.0,
    shadow: true,
  },
  stockPanelSettings: baseStockPanelSettings,
  configurationOverrides: {
    overrides: {},
    associations: [],
  },
  unifiedBackground: [],
};

const ignoredConfigs = [
  "isEnabled",
  "hideWidget",
  "enableDebug",
  "panelWidgets",
  "objectName",
  "lastPreset",
  "presetAutoloading",
  "configurationOverrides",
  "widgetClickMode",
  "switchPresets",
  "switchPresetsIndex",
  "enableDBusService",
  "pythonExecutable",
  "forceForegroundColor",
  "animatePropertyChanges",
  "animationDuration",
  "editModeGridSettings",
];

const editModeGridSettings = {
  enabled: true,
  spacing: 4,
  majorLineEvery: 0,
  background: { color: "#00ffff", alpha: 0.25 },
  minorLine: { color: "#000000", alpha: 1 },
  majorLine: { color: "#ff0000", alpha: 0 },
  mayorLineEvery: 2,
};

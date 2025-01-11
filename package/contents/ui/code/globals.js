const baseColorList = [
  "#ED8796",
  "#A6DA95",
  "#EED49F",
  "#8AADF4",
  "#F5BDE6",
  "#8BD5CA",
  "#f5a97f"
]

const baseAnimation = {
  "enabled": false,
  "interval": 3000,
  "smoothing": 800
}

const basePanelBgColor = {
  "enabled": true,
  "lightnessValue": 0.5,
  "saturationValue": 0.5,
  "alpha": 1,
  "systemColor": "backgroundColor",
  "systemColorSet": "View",
  "custom": "#013eff",
  "list": baseColorList,
  "followColor": 0,
  "saturationEnabled": false,
  "lightnessEnabled": false,
  "animation": baseAnimation,
  "sourceType": 1,
}

const baseBgColor = {
  "enabled": false,
  "lightnessValue": 0.5,
  "saturationValue": 0.5,
  "alpha": 1,
  "systemColor": "backgroundColor",
  "systemColorSet": "View",
  "custom": "#013eff",
  "list": baseColorList,
  "followColor": 0,
  "saturationEnabled": false,
  "lightnessEnabled": false,
  "animation": baseAnimation,
  "sourceType": 1,
}

const baseFgColor = {
  "enabled": false,
  "lightnessValue": 0.5,
  "saturationValue": 0.5,
  "alpha": 1,
  "systemColor": "highlightColor",
  "systemColorSet": "View",
  "custom": "#fc0000",
  "list": baseColorList,
  "followColor": 0,
  "saturationEnabled": false,
  "lightnessEnabled": false,
  "animation": baseAnimation,
  "sourceType": 1,
}

const baseBorderColor = {
  "lightnessValue": 0.5,
  "saturationValue": 0.5,
  "alpha": 1,
  "systemColor": "highlightColor",
  "systemColorSet": "View",
  "custom": "#ff6c06",
  "list": baseColorList,
  "followColor": 0,
  "saturationEnabled": false,
  "lightnessEnabled": false,
  "animation": baseAnimation,
  "sourceType": 1,
  "enabled": true
}

const baseShadowColor = {
  "lightnessValue": 0.5,
  "saturationValue": 0.5,
  "alpha": 1,
  "systemColor": "backgroundColor",
  "systemColorSet": "View",
  "custom": "#282828",
  "list": baseColorList,
  "followColor": 0,
  "saturationEnabled": false,
  "lightnessEnabled": false,
  "animation": baseAnimation,
  "sourceType": 1,
  "enabled": true
}

const baseShadow = {
  "enabled": false,
  "color": baseShadowColor,
  "size": 5,
  "xOffset": 0,
  "yOffset": 0
}

const baseShadowConfig = {
  "background": baseShadow,
  "foreground": baseShadow
}

const baseRadius = {
  "enabled": false,
  "corner": {
    "topLeft": 5,
    "topRight": 5,
    "bottomRight": 5,
    "bottomLeft": 5
  }
}

const baseMargin = {
  "enabled": false,
  "side": {
    "right": 0,
    "left": 0,
    "top": 0,
    "bottom": 0
  }
}

const baseBorder = {
  "enabled": false,
  "customSides": false,
  "custom": {
    "widths": {
      "left": 0,
      "bottom": 3,
      "right": 0,
      "top": 0
    },
    "margin": baseMargin,
    "radius": baseRadius
  },
  "width": 0,
  "color": baseBorderColor
}

const basePadding = {
  "enabled": false,
  "side": {
    "right": 0,
    "left": 0,
    "top": 0,
    "bottom": 0
  },
}

const basePanelConfig = {
  "enabled": false,
  "blurBehind": false,
  "backgroundColor": basePanelBgColor,
  "foregroundColor": baseFgColor,
  "radius": baseRadius,
  "margin": baseMargin,
  "padding": basePadding,
  "border": baseBorder,
  "shadow": baseShadowConfig,
}

const baseWidgetConfig = {
  "enabled": true,
  "blurBehind": false,
  "backgroundColor": baseBgColor,
  "foregroundColor": baseFgColor,
  "radius": baseRadius,
  "margin": baseMargin,
  "spacing": 3,
  "border": baseBorder,
  "shadow": baseShadowConfig,
}

const baseTrayConfig = {
  "enabled": false,
  "blurBehind": false,
  "backgroundColor": baseBgColor,
  "foregroundColor": baseFgColor,
  "radius": baseRadius,
  "margin": baseMargin,
  "border": baseBorder,
  "shadow": baseShadowConfig,
}

const baseOverrideConfig = {
  "blurBehind": false,
  "backgroundColor": baseBgColor,
  "foregroundColor": baseFgColor,
  "radius": baseRadius,
  "margin": baseMargin,
  "spacing": 3,
  "border": baseBorder,
  "shadow": baseShadowConfig,
  "enabled": true,
  "disabledFallback": true
}

const baseStockPanelSettings = {
  "position": {
    "enabled": false,
    "value": "top"
  },
  "alignment": {
    "enabled": false,
    "value": "center"
  },
  "lengthMode": {
    "enabled": false,
    "value": "fill"
  },
  "visibility": {
    "enabled": false,
    "value": "none"
  },
  "opacity": {
    "enabled": false,
    "value": "adaptive"
  },
  "floating": {
    "enabled": false,
    "value": false
  },
  "thickness": {
    "enabled": false,
    "value": 48
  }
}

const defaultConfig = {
  "panel": basePanelConfig,
  "widgets": baseWidgetConfig,
  "trayWidgets": baseTrayConfig,
  "nativePanelBackground": {
    "enabled": true,
    "opacity": 1.0
  },
  "stockPanelSettings": baseStockPanelSettings,
  "configurationOverrides": {
    "overrides": {},
    "associations": []
  },
  "unifiedBackground": []
}

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
  "dBusPollingRate",
  "pythonExecutable"
]

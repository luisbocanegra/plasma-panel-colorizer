import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "code/globals.js" as Globals
import "components" as Components
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid

KCM.SimpleKCM {
    id: root

    property alias cfg_isEnabled: headerComponent.isEnabled
    property string cfg_globalSettings
    property var globalSettings: JSON.parse(cfg_globalSettings)
    property var config: globalSettings.stockPanelSettings
    property bool loaded: false

    function updateConfig() {
        globalSettings.stockPanelSettings = config;
        cfg_globalSettings = JSON.stringify(globalSettings, null, null);
    }

    onConfigChanged: {
        // fix 1.0.0 old config format
        if (loaded)
            return;

        if (typeof config.position !== "object") {
            console.warn("fix 1.0.0 old config format");
            config = Globals.baseStockPanelSettings;
            updateConfig();
        }
        loaded = true;
    }

    ColumnLayout {
        Kirigami.InlineMessage {
            Layout.fillWidth: true
            text: i18n("Changing panel position is currently unstable and may cause Plasma to crash when moving panels between non-parallel edges (e.g from top to left).")
            visible: true
            type: Kirigami.MessageType.Warning
        }

        Kirigami.InlineMessage {
            Layout.fillWidth: true
            text: i18n("Opacity and Screen options require <b>Plasma 6.3</b> or newer.<br>Opacity depends on the current Plasma Theme, for finer control or full transparency use <b>Panel Opacity</b> and <b>Native panel background</b> options in <b>Appearance</b> tab instead.")
            visible: true
            type: Kirigami.MessageType.Information
        }

        Kirigami.FormLayout {
            enabled: cfg_isEnabled

            Kirigami.Separator {
                Kirigami.FormData.isSection: true
                Kirigami.FormData.label: i18n("Screen")
            }

            CheckBox {
                id: screenEnabled
                Kirigami.FormData.label: i18n("Enabled:")
                checked: config.screen.enabled
                onCheckedChanged: {
                    config.screen.enabled = checked;
                    updateConfig();
                }
            }

            SpinBox {
                id: screen

                Kirigami.FormData.label: i18n("Screen:")
                from: 0
                to: Qt.application.screens.length - 1
                value: config.screen.value
                onValueChanged: {
                    config.screen.value = value;
                    updateConfig();
                }
                enabled: screenEnabled.checked
            }

            Kirigami.Separator {
                Kirigami.FormData.isSection: true
                Kirigami.FormData.label: i18n("Position")
            }

            CheckBox {
                id: positionEnabled

                Kirigami.FormData.label: i18n("Enabled:")
                checked: config.position.enabled
                onCheckedChanged: {
                    config.position.enabled = checked;
                    updateConfig();
                }
            }

            ComboBox {
                Kirigami.FormData.label: i18n("Position:")
                model: [
                    {
                        "name": i18n("Top"),
                        "value": "top"
                    },
                    {
                        "name": i18n("Bottom"),
                        "value": "bottom"
                    },
                    {
                        "name": i18n("Left"),
                        "value": "left"
                    },
                    {
                        "name": i18n("Right"),
                        "value": "right"
                    }
                ]
                textRole: "name"
                valueRole: "value"
                currentIndex: {
                    let i = 0;
                    for (let item of model) {
                        if (config.position.value === item.value)
                            break;

                        i++;
                    }
                    return i;
                }
                onCurrentValueChanged: {
                    config.position.value = currentValue;
                    updateConfig();
                }
                enabled: positionEnabled.checked
            }

            Kirigami.Separator {
                Kirigami.FormData.isSection: true
                Kirigami.FormData.label: i18n("Alignment")
            }

            CheckBox {
                id: alignmentEnabled

                Kirigami.FormData.label: i18n("Enabled:")
                checked: config.alignment.enabled
                onCheckedChanged: {
                    config.alignment.enabled = checked;
                    updateConfig();
                }
            }

            ComboBox {
                Kirigami.FormData.label: i18n("Alignment:")
                model: [
                    {
                        "name": i18n("Center"),
                        "value": "center"
                    },
                    {
                        "name": i18n("Left"),
                        "value": "left"
                    },
                    {
                        "name": i18n("Right"),
                        "value": "right"
                    }
                ]
                textRole: "name"
                valueRole: "value"
                currentIndex: {
                    let index = 0;
                    for (let item of model) {
                        if (config.alignment.value === item.value)
                            break;

                        index++;
                    }
                    return index;
                }
                onCurrentValueChanged: {
                    config.alignment.value = currentValue;
                    updateConfig();
                }
                enabled: alignmentEnabled.checked
            }

            Kirigami.Separator {
                Kirigami.FormData.isSection: true
                Kirigami.FormData.label: i18n("Length mode")
            }

            CheckBox {
                id: lengthModeEnabled

                Kirigami.FormData.label: i18n("Enabled:")
                checked: config.lengthMode.enabled
                onCheckedChanged: {
                    config.lengthMode.enabled = checked;
                    updateConfig();
                }
            }

            ComboBox {
                Kirigami.FormData.label: i18n("Mode:")
                model: [
                    {
                        "name": i18n("Fill"),
                        "value": "fill"
                    },
                    {
                        "name": i18n("Fit content"),
                        "value": "fit"
                    },
                    {
                        "name": i18n("Custom"),
                        "value": "custom"
                    }
                ]
                textRole: "name"
                valueRole: "value"
                currentIndex: {
                    let index = 0;
                    for (let item of model) {
                        if (config.lengthMode.value === item.value)
                            break;

                        index++;
                    }
                    return index;
                }
                onCurrentValueChanged: {
                    config.lengthMode.value = currentValue;
                    updateConfig();
                }
                enabled: lengthModeEnabled.checked
            }

            Kirigami.Separator {
                Kirigami.FormData.isSection: true
                Kirigami.FormData.label: i18n("Visibility")
            }

            CheckBox {
                id: visibilityEnabled

                Kirigami.FormData.label: i18n("Enabled:")
                checked: config.visibility.enabled
                onCheckedChanged: {
                    config.visibility.enabled = checked;
                    updateConfig();
                }
            }

            ComboBox {
                id: visibilityCombo

                Kirigami.FormData.label: i18n("Mode:")
                model: [
                    {
                        "name": i18n("Always visible"),
                        "value": "none"
                    },
                    {
                        "name": i18n("Auto hide"),
                        "value": "autohide"
                    },
                    {
                        "name": i18n("Dodge windows"),
                        "value": "dodgewindows"
                    },
                    {
                        "name": i18n("Windows go below"),
                        "value": "windowsgobelow"
                    }
                ]
                textRole: "name"
                valueRole: "value"
                currentIndex: {
                    let index = 0;
                    for (let item of model) {
                        if (config.visibility.value === item.value)
                            break;

                        index++;
                    }
                    return index;
                }
                onCurrentValueChanged: {
                    config.visibility.value = currentValue;
                    updateConfig();
                }
                enabled: visibilityEnabled.checked
            }

            Kirigami.Separator {
                Kirigami.FormData.isSection: true
                Kirigami.FormData.label: i18n("Opacity")
            }

            CheckBox {
                id: opacityEnabled

                Kirigami.FormData.label: i18n("Enabled:")
                checked: config.opacity.enabled
                onCheckedChanged: {
                    config.opacity.enabled = checked;
                    updateConfig();
                }
            }

            ComboBox {
                Kirigami.FormData.label: i18n("Mode:")
                model: [
                    {
                        "name": i18n("Adaptive"),
                        "value": "adaptive"
                    },
                    {
                        "name": i18n("Opaque"),
                        "value": "opaque"
                    },
                    {
                        "name": i18n("Translucent"),
                        "value": "translucent"
                    }
                ]
                textRole: "name"
                valueRole: "value"
                currentIndex: {
                    let index = 0;
                    for (let item of model) {
                        if (config.opacity.value === item.value)
                            break;

                        index++;
                    }
                    return index;
                }
                onCurrentValueChanged: {
                    config.opacity.value = currentValue;
                    updateConfig();
                }
                enabled: opacityEnabled.checked
            }

            Kirigami.Separator {
                Kirigami.FormData.isSection: true
                Kirigami.FormData.label: i18n("Floating")
            }

            CheckBox {
                id: floatingEnabled

                Kirigami.FormData.label: i18n("Enabled:")
                checked: config.floating.enabled
                onCheckedChanged: {
                    config.floating.enabled = checked;
                    updateConfig();
                }
            }

            CheckBox {
                id: floating

                Kirigami.FormData.label: i18n("Floating:")
                checked: config.floating.value
                onCheckedChanged: {
                    config.floating.value = checked;
                    updateConfig();
                }
                enabled: floatingEnabled.checked
            }

            Kirigami.Separator {
                Kirigami.FormData.isSection: true
                Kirigami.FormData.label: i18n("Thickness")
            }

            CheckBox {
                id: thicknessEnabled

                Kirigami.FormData.label: i18n("Enabled:")
                checked: config.thickness.enabled
                onCheckedChanged: {
                    config.thickness.enabled = checked;
                    updateConfig();
                }
            }

            SpinBox {
                id: thickness

                Kirigami.FormData.label: i18n("Thickness:")
                from: 0
                to: 999
                value: config.thickness.value
                onValueChanged: {
                    config.thickness.value = value;
                    updateConfig();
                }
                enabled: thicknessEnabled.checked
            }

            Kirigami.Separator {
                Kirigami.FormData.isSection: true
                Kirigami.FormData.label: i18n("Show/Hide")
            }

            CheckBox {
                id: visibleEnabled

                Kirigami.FormData.label: i18n("Enabled:")
                checked: config.visible.enabled
                onCheckedChanged: {
                    config.visible.enabled = checked;
                    updateConfig();
                }
            }

            CheckBox {
                id: visible

                Kirigami.FormData.label: i18n("Show:")
                checked: config.visible.value
                onCheckedChanged: {
                    config.visible.value = checked;
                    updateConfig();
                }
                enabled: visibleEnabled.checked
            }
        }

        Kirigami.InlineMessage {
            Layout.fillWidth: true
            text: i18n("WARNING: Use with caution, if you hide the panel and have not configured preset auto-loading or know how to switch presets using D-Bus (or have disabled it), you will have no way to make it visible again without manually removing the configuration, use the command below in terminal/tty then log out or reboot, it will renove the configuratiob from all Panel Colorizer instances so make sure to save the others first") + ":<br><strong><code>sed -i '/^globalSettings={\"panel\"/d' \"$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc\"</code></strong> " + i18n("If you have D-Bus enabled is it recommended that you use that with shortcuts instead. Consult the README to learn more or see the General tab for some examples.")
            visible: true
            type: Kirigami.MessageType.Warning
            actions: [
                Kirigami.Action {
                    icon.name: "view-readermode-symbolic"
                    text: "D-Bus usage"
                    onTriggered: {
                        Qt.openUrlExternally("https://github.com/luisbocanegra/plasma-panel-colorizer?tab=readme-ov-file#advanced-commandline-usage-with-d-bus-version-200-or-later");
                    }
                }
            ]
        }
    }

    header: ColumnLayout {
        Components.Header {
            id: headerComponent

            Layout.leftMargin: Kirigami.Units.mediumSpacing
            Layout.rightMargin: Kirigami.Units.mediumSpacing
        }
    }
}

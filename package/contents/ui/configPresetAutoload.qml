import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import org.kde.plasma.plasma5support as P5Support
import "components" as Components
import "code/utils.js" as Utils
import "code/enum.js" as Enum

KCM.SimpleKCM {
    id:root
    property alias cfg_isEnabled: headerComponent.isEnabled
    property string presetsDir: StandardPaths.writableLocation(
                    StandardPaths.HomeLocation).toString().substring(7) + "/.config/panel-colorizer/presets"
    property string cratePresetsDirCmd: "mkdir -p " + presetsDir
    property string presetsBuiltinDir: Qt.resolvedUrl("./presets").toString().substring(7) + "/"
    property string toolsDir: Qt.resolvedUrl("./tools").toString().substring(7) + "/"
    property string listUserPresetsCmd: "'" + toolsDir + "list_presets.sh' '" + presetsDir + "'"
    property string listBuiltinPresetsCmd: "'" + toolsDir + "list_presets.sh' '" + presetsBuiltinDir + "' b"
    property string listPresetsCmd: listBuiltinPresetsCmd+";"+listUserPresetsCmd

    property string cfg_presetAutoloading
    property var autoLoadConfig: JSON.parse(cfg_presetAutoloading)

    property alias cfg_widgetClickMode: widgetClickModeCombo.currentIndex
    readonly property list<string> widgetClickModes: ["Toggle Panel Colorizer", "Switch presets", "Show popup"]

    property string cfg_switchPresets
    property var switchPresets: JSON.parse(cfg_switchPresets)

    property var presetsList: []

    function updateConfig() {
        cfg_presetAutoloading = JSON.stringify(autoLoadConfig, null, null)
        cfg_switchPresets = JSON.stringify(switchPresets, null, null)
    }

    ListModel {
        id: presetsModel
    }

    RunCommand {
        id: runCommand
    }

    Connections {
        target: runCommand
        function onExited(cmd, exitCode, exitStatus, stdout, stderr) {
            if (exitCode!==0) {
                console.error(cmd, exitCode, exitStatus, stdout, stderr)
                return
            }
            // console.log(stdout);
            if(cmd === listPresetsCmd) {
                if (stdout.length === 0) return
                presetsModel.append(
                    {
                        "name": i18n("Do nothing"),
                        "value": "",
                    }
                )

                const out = stdout.trim().split("\n")
                for (const line of out) {
                    const parts = line.split(":")
                    const path = parts[parts.length -1]
                    let name = path.split("/")
                    name = name[name.length-1]
                    const dir = parts[1]
                    console.log(dir)
                    const preset = {
                        "name": name,
                        "value": dir,
                    }
                    presetsModel.append(
                        preset
                    )
                    presetsList.push(preset)
                }
            }
            if (presetsList.length && switchPresets.length) {
                switchPresets = pruneMissingPresets(switchPresets)
            }
        }
    }

    function pruneMissingPresets(switchPresets) {
        return switchPresets.filter(saved => presetsList.some(p => p.value === saved))
    }

    function getIndex(model, savedValue) {
        for (let i = 0; i < model.count; i++) {
            if (model.get(i).value === savedValue) {
                return i;
            }
        }
        return 0;
    }

    Component.onCompleted: {
        runCommand.run(cratePresetsDirCmd)
        runCommand.run(listPresetsCmd)
    }

    header: ColumnLayout {
        Components.Header {
            id: headerComponent
            Layout.leftMargin: Kirigami.Units.mediumSpacing
            Layout.rightMargin: Kirigami.Units.mediumSpacing
        }
    }

    ColumnLayout {
        enabled: cfg_isEnabled
        Kirigami.InlineMessage {
            Layout.fillWidth: true
            text: i18n("Disable preset auto-loading when making changes to presets, unsaved preset settings will be lost when presets change!")
            visible: true
            type: Kirigami.MessageType.Information
        }
        Label {
            text: i18n("Switch between different panel presets based on the Panel and window states")
            Layout.maximumWidth: root.width - (Kirigami.Units.gridUnit * 2)
            wrapMode: Text.Wrap
        }

        Kirigami.FormLayout {

            Kirigami.Separator {
                Kirigami.FormData.isSection: true
                Kirigami.FormData.label: i18n("Environment")
                Layout.fillWidth: true
            }

            CheckBox {
                id: enabledCheckbox
                Kirigami.FormData.label: i18n("Enabled:")
                checked: autoLoadConfig.enabled
                onCheckedChanged: {
                    autoLoadConfig.enabled = checked
                    updateConfig()
                }
            }
            Kirigami.ContextualHelpButton {
                toolTipText: i18n("Priorities go in descending order. E.g. if both <b>Maximized window is shown</b> and <b>Panel touching window</b> have a preset selected, and there is a maximized window on the screen, the <b>Maximized</b> preset will be applied.")
            }
            ComboBox {
                model: presetsModel
                textRole: "name"
                Kirigami.FormData.label: i18n("Fullscreen window:")
                onCurrentIndexChanged: {
                    autoLoadConfig.fullscreenWindow = model.get(currentIndex)["value"]
                    updateConfig()
                }
                currentIndex: getIndex(model, autoLoadConfig.fullscreenWindow)
                enabled: enabledCheckbox.checked
            }

            ComboBox {
                model: presetsModel
                textRole: "name"
                Kirigami.FormData.label: i18n("Maximized window:")
                onCurrentIndexChanged: {
                    autoLoadConfig.maximized = model.get(currentIndex)["value"]
                    updateConfig()
                }
                currentIndex: getIndex(model, autoLoadConfig.maximized)
                enabled: enabledCheckbox.checked
            }

            CheckBox {
                // Kirigami.FormData.label: i18n("Active window only:")
                text: i18n("Active window only")
                checked: autoLoadConfig.maximizedFilterByActive
                onCheckedChanged: {
                    autoLoadConfig.maximizedFilterByActive = checked
                    updateConfig()
                }
                enabled: (autoLoadConfig.maximized ?? "" !== "") && enabledCheckbox.checked
            }

            ComboBox {
                model: presetsModel
                textRole: "name"
                Kirigami.FormData.label: i18n("Window touching panel:")
                onCurrentIndexChanged: {
                    autoLoadConfig.touchingWindow = model.get(currentIndex)["value"]
                    updateConfig()
                }
                currentIndex: getIndex(model, autoLoadConfig.touchingWindow)
                enabled: enabledCheckbox.checked
            }

            ComboBox {
                model: presetsModel
                textRole: "name"
                Kirigami.FormData.label: i18n("At least one window is shown:")
                onCurrentIndexChanged: {
                    autoLoadConfig.visibleWindows = model.get(currentIndex)["value"]
                    updateConfig()
                }
                currentIndex: getIndex(model, autoLoadConfig.visibleWindows)
                enabled: enabledCheckbox.checked
            }

            ComboBox {
                model: presetsModel
                textRole: "name"
                Kirigami.FormData.label: i18n("Floating panel:")
                onCurrentIndexChanged: {
                    autoLoadConfig.floating = model.get(currentIndex)["value"]
                    updateConfig()
                }
                currentIndex: getIndex(model, autoLoadConfig.floating)
                enabled: enabledCheckbox.checked
            }

            ComboBox {
                model: presetsModel
                textRole: "name"
                Kirigami.FormData.label: i18n("Normal:")
                onCurrentIndexChanged: {
                    autoLoadConfig.normal = model.get(currentIndex)["value"]
                    updateConfig()
                }
                currentIndex: getIndex(model, autoLoadConfig.normal)
                enabled: enabledCheckbox.checked
            }

            Kirigami.Separator {
                Kirigami.FormData.isSection: true
                Kirigami.FormData.label: i18n("Widget Click")
                Layout.fillWidth: true
            }

            ComboBox {
                id: widgetClickModeCombo
                Kirigami.FormData.label: "Action:"
                model: widgetClickModes
            }

            ColumnLayout {
                Layout.fillWidth: true
                ScrollView {
                    enabled: cfg_widgetClickMode === Enum.WidgetClickModes.SwitchPresets
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.min(implicitHeight+20, 200)
                    ListView {
                        id: listView
                        model: presetsModel
                        Layout.preferredWidth: Math.min(width+50, 100)
                        reuseItems: true
                        clip: true
                        focus: true
                        activeFocusOnTab: true
                        keyNavigationEnabled: true
                        delegate: RowLayout {
                            width: ListView.view.width
                            CheckBox {
                                id: presetCheckbox
                                text: model.name
                                checked: switchPresets.includes(model.value)
                                Layout.rightMargin: Kirigami.Units.smallSpacing * 4
                                onCheckedChanged: {
                                    if (checked) {
                                        if (!switchPresets.includes(model.value)) {
                                            switchPresets.push(model.value)
                                        }
                                    } else {
                                        switchPresets = switchPresets.filter(p => p !== model.value)
                                    }
                                    updateConfig()
                                }
                            }
                        }
                        highlight: Item {}
                        highlightMoveDuration: 0
                        highlightResizeDuration: 0
                    }
                }
            }
        }
    }
}

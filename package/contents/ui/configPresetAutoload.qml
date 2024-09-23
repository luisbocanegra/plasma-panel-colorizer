import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import org.kde.plasma.plasma5support as P5Support
import "components" as Components

KCM.SimpleKCM {
    id:root
    property bool cfg_isEnabled
    property string presetsDir: StandardPaths.writableLocation(
                    StandardPaths.HomeLocation).toString().substring(7) + "/.config/panel-colorizer/"
    property string cratePresetsDirCmd: "mkdir -p " + presetsDir
    property string listPresetsCmd: "find "+presetsDir+" -type f -print0 | while IFS= read -r -d '' file; do basename \"$file\"; done | sort"

    property string cfg_presetAutoloading
    property var autoLoadConfig: JSON.parse(cfg_presetAutoloading)

    function updateConfig() {
        cfg_presetAutoloading = JSON.stringify(autoLoadConfig, null, null)
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
            // console.log(cmd);
            if (exitCode!==0) return
            // console.log(stdout);
            var presets = []
            if(cmd === listPresetsCmd) {
                if (stdout.length < 1) return
                presetsModel.append(
                    {
                        "name": i18n("Do nothing"),
                        "value": ""
                    }
                )
                presets = stdout.trim().split("\n")
                for (let i = 0; i < presets.length; i++) {
                    presets[i]
                    presetsModel.append(
                        {
                            "name": presets[i],
                            "value": presets[i],
                        }
                    )
                }
            }
        }
    }

    function getIndex(model, savedValue) {
        for (let i = 0; i < model.count; i++) {
            if (model.get(i).value === savedValue) {
                return i;
            }
        }
        return 0;
    }

    function dumpProps(obj) {
        console.error("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
        for (var k of Object.keys(obj)) {
            print(k + "=" + obj[k]+"\n")
        }
    }

    Component.onCompleted: {
        runCommand.run(cratePresetsDirCmd)
        runCommand.run(listPresetsCmd)
    }

    header: RowLayout {
        RowLayout {
            Layout.leftMargin: Kirigami.Units.mediumSpacing
            Layout.rightMargin: Kirigami.Units.smallSpacing
            Item {
                Layout.fillWidth: true
            }
            RowLayout {
                Layout.alignment: Qt.AlignRight
                Label {
                    text: i18n("Last preset loaded:")
                }
                Label {
                    text: plasmoid.configuration.lastPreset || "None"
                    font.weight: Font.DemiBold
                }
            }
        }
    }

    ColumnLayout {
        visible: cfg_isEnabled
        Label {
            text: i18n("Here you can switch between different panel presets based on the Panel and window states below.")
            Layout.maximumWidth: root.width - (Kirigami.Units.gridUnit * 2)
            wrapMode: Text.Wrap
        }

        Label {
            text: i18n("Priorities go in descending order. E.g. if both <b>Maximized window is shown</b> and <b>Panel touching window</b> have a preset selected, and there is a maximized window on the screen, the <b>Maximized</b> preset will be applied.")
            Layout.maximumWidth: root.width - (Kirigami.Units.gridUnit * 2)
            wrapMode: Text.Wrap
        }
        Kirigami.FormLayout {

            ComboBox {
                model: presetsModel
                textRole: "name"
                Kirigami.FormData.label: i18n("Maximized window is shown:")
                onCurrentIndexChanged: {
                    autoLoadConfig.maximized = model.get(currentIndex)["value"]
                    updateConfig()
                }
                currentIndex: getIndex(model, autoLoadConfig.maximized)
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
            }
        }
    }

    Components.CategoryDisabled {
        visible: !cfg_isEnabled
    }
}

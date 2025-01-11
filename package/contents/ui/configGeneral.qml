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
import "code/globals.js" as Globals

KCM.SimpleKCM {
    id:root
    property bool cfg_hideWidget: hideWidget.checked
    property alias cfg_isEnabled: headerComponent.isEnabled
    property alias cfg_enableDebug: enableDebug.checked
    property alias cfg_enableDBusService: enableDBusService.checked
    property alias cfg_pythonExecutable: pythonExecutable.text
    property alias cfg_dBusPollingRate: dBusPollingRate.value

    property string presetsDir: StandardPaths.writableLocation(
                    StandardPaths.HomeLocation).toString().substring(7) + "/.config/panel-colorizer/presets"
    property string presetsBuiltinDir: Qt.resolvedUrl("./presets").toString().substring(7) + "/"

    property string dbusName: Plasmoid.metaData.pluginId + ".c" + Plasmoid.containment.id + ".w" + Plasmoid.id

    header: ColumnLayout {
        Components.Header {
            id: headerComponent
            Layout.leftMargin: Kirigami.Units.mediumSpacing
            Layout.rightMargin: Kirigami.Units.mediumSpacing
        }
    }

    ColumnLayout {
        Kirigami.FormLayout {
            id: form
            CheckBox {
                Kirigami.FormData.label: i18n("Hide widget:")
                id: hideWidget
                checked: cfg_hideWidget
                onCheckedChanged: cfg_hideWidget = checked
                text: i18n("visible in Panel Edit Mode")
            }
            CheckBox {
                Kirigami.FormData.label: i18n("Debug mode:")
                id: enableDebug
                checked: cfg_enableDebug
                onCheckedChanged: cfg_enableDebug = checked
                text: i18n("Show debugging information")
            }

            Kirigami.Separator {
                Kirigami.FormData.isSection: true
                Kirigami.FormData.label: i18n("D-Bus Service")
                Layout.fillWidth: true
            }

            CheckBox {
                Kirigami.FormData.label: i18n("Enabled:")
                id: enableDBusService
                checked: cfg_enableDBusService
                onCheckedChanged: cfg_enableDBusService = checked
                text: i18n("D-Bus name:") + " " + dbusName
            }

            Label {
                text: i18n("Each Panel Colorizer instance has its D-Bus name.")
                wrapMode: Text.WordWrap
                Layout.preferredWidth: 400
                opacity: 0.6
            }

            TextField {
                Kirigami.FormData.label: i18n("Python 3 executable:")
                id: pythonExecutable
                placeholderText: qsTr("Python executable e.g. python, python3")
                enabled: enableDBusService.checked
            }

            Label {
                text: i18n("Required to run the D-Bus service in the background")
                wrapMode: Text.WordWrap
                Layout.preferredWidth: 400
                opacity: 0.6
            }

            SpinBox {
                Kirigami.FormData.label: i18n("Polling rate:")
                from: 10
                to: 9999
                stepSize: 100
                id: dBusPollingRate
            }

            Label {
                text: i18n("How fast the widget reacts to D-Bus changes")
                wrapMode: Text.WordWrap
                Layout.preferredWidth: 400
                opacity: 0.6
            }


            Label {
                Kirigami.FormData.label: i18n("Usage:")
                text: i18n("Apply a preset:")
            }

            TextArea {
                text: "qdbus6 " + dbusName + " /preset preset /path/to/preset/dir/"
                readOnly: true
                wrapMode: Text.WordWrap
                Layout.preferredWidth: 400
            }

            Label {
                text: i18n("Preview and switch presets using fzf + qdbus6 + jq:")
            }

            TextArea {
                text: "find " + presetsBuiltinDir + " "+ presetsDir +" -mindepth 1 -prune -type d | fzf --preview 'qdbus6 " + dbusName + " /preset preset {} && jq --color-output . {}/settings.json'"
                readOnly: true
                wrapMode: Text.WordWrap
                Layout.preferredWidth: 400
            }
        }
    }
}

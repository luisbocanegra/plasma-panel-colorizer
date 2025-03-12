import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "components" as Components
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid

KCM.SimpleKCM {
    id: root

    property bool cfg_hideWidget: hideWidget.checked
    property alias cfg_isEnabled: headerComponent.isEnabled
    property alias cfg_enableDebug: enableDebug.checked
    property alias cfg_enableDBusService: enableDBusService.checked
    property alias cfg_pythonExecutable: pythonExecutable.text
    property alias cfg_animatePropertyChanges: animatePropertyChanges.checked
    property alias cfg_animationDuration: animationDuration.value
    property string cfg_editModeGridSettings
    property var editModeGridSettings: JSON.parse(cfg_editModeGridSettings)
    property string presetsDir: StandardPaths.writableLocation(StandardPaths.HomeLocation).toString().substring(7) + "/.config/panel-colorizer/presets"
    property string presetsBuiltinDir: Qt.resolvedUrl("./presets").toString().substring(7) + "/"
    property string dbusName: Plasmoid.metaData.pluginId + ".c" + Plasmoid.containment.id + ".w" + Plasmoid.id

    function updateConfig() {
        cfg_editModeGridSettings = JSON.stringify(editModeGridSettings, null, null);
    }

    ColumnLayout {
        Kirigami.FormLayout {
            id: form

            CheckBox {
                id: hideWidget

                Kirigami.FormData.label: i18n("Hide widget:")
                checked: cfg_hideWidget
                onCheckedChanged: cfg_hideWidget = checked
                text: i18n("visible in Panel Edit Mode")
            }

            CheckBox {
                id: enableDebug

                Kirigami.FormData.label: i18n("Debug mode:")
                checked: cfg_enableDebug
                onCheckedChanged: cfg_enableDebug = checked
                text: i18n("Show debugging information")
            }

            Kirigami.Separator {
                Kirigami.FormData.isSection: true
                Kirigami.FormData.label: i18n("Grid")
                Layout.fillWidth: true
            }

            CheckBox {
                id: editGridEnabled

                Kirigami.FormData.label: i18n("Enabled")
                checked: root.editModeGridSettings.enabled
                onCheckedChanged: {
                    root.editModeGridSettings.enabled = checked;
                    root.updateConfig();
                }
                text: i18n("Visible while configuring")
            }

            RowLayout {
                enabled: editGridEnabled.checked
                Kirigami.FormData.label: i18n("Background")

                Components.ColorButton {
                    id: bgColorBtn

                    showAlphaChannel: false
                    dialogTitle: bgColorBtn.Kirigami.FormData.label
                    color: root.editModeGridSettings.background.color
                    onAccepted: color => {
                        root.editModeGridSettings.background.color = color.toString();
                        root.updateConfig();
                    }
                }

                Label {
                    text: i18n("Alpha:")
                }

                Components.SpinBoxDecimal {
                    Layout.preferredWidth: root.Kirigami.Units.gridUnit * 5
                    from: 0
                    to: 1
                    value: root.editModeGridSettings.background.alpha ?? 0
                    onValueChanged: {
                        root.editModeGridSettings.background.alpha = value;
                        root.updateConfig();
                    }
                }
            }

            RowLayout {
                enabled: editGridEnabled.checked
                Kirigami.FormData.label: i18n("Minor line:")

                Components.ColorButton {
                    id: minorLineColorBtn

                    showAlphaChannel: false
                    dialogTitle: minorLineColorBtn.Kirigami.FormData.label
                    color: root.editModeGridSettings.minorLine.color
                    onAccepted: color => {
                        root.editModeGridSettings.minorLine.color = color.toString();
                        root.updateConfig();
                    }
                }

                Label {
                    text: i18n("Alpha:")
                }

                Components.SpinBoxDecimal {
                    Layout.preferredWidth: root.Kirigami.Units.gridUnit * 5
                    from: 0
                    to: 1
                    value: root.editModeGridSettings.minorLine.alpha ?? 0
                    onValueChanged: {
                        root.editModeGridSettings.minorLine.alpha = value;
                        root.updateConfig();
                    }
                }

                Label {
                    text: i18n("spacing")
                }

                SpinBox {
                    from: 1
                    to: 99999
                    stepSize: 1
                    value: root.editModeGridSettings.spacing
                    onValueModified: {
                        root.editModeGridSettings.spacing = value;
                        root.updateConfig();
                    }
                }
            }

            RowLayout {
                enabled: editGridEnabled.checked
                Kirigami.FormData.label: i18n("Major line:")

                Components.ColorButton {
                    id: majorLineColorBtn

                    showAlphaChannel: false
                    dialogTitle: majorLineColorBtn.Kirigami.FormData.label
                    color: root.editModeGridSettings.majorLine.color
                    onAccepted: color => {
                        root.editModeGridSettings.majorLine.color = color.toString();
                        root.updateConfig();
                    }
                    enabled: majorLineEverySpinbox.value !== 0
                }

                Label {
                    text: i18n("Alpha:")
                }

                Components.SpinBoxDecimal {
                    Layout.preferredWidth: root.Kirigami.Units.gridUnit * 5
                    from: 0
                    to: 1
                    value: root.editModeGridSettings.majorLine.alpha ?? 0
                    onValueChanged: {
                        root.editModeGridSettings.majorLine.alpha = value;
                        root.updateConfig();
                    }
                    enabled: majorLineEverySpinbox.value !== 0
                }

                Label {
                    text: i18n("every")
                }

                SpinBox {
                    id: majorLineEverySpinbox

                    from: 0
                    to: 99999
                    stepSize: 1
                    value: root.editModeGridSettings.majorLineEvery
                    onValueModified: {
                        root.editModeGridSettings.majorLineEvery = value;
                        root.updateConfig();
                    }
                }
            }

            Kirigami.Separator {
                Kirigami.FormData.isSection: true
                Kirigami.FormData.label: i18n("Property change animations")
                Layout.fillWidth: true
            }

            CheckBox {
                id: animatePropertyChanges

                Kirigami.FormData.label: i18n("Enabled:")
                onCheckedChanged: cfg_animatePropertyChanges = checked
            }

            SpinBox {
                id: animationDuration

                Kirigami.FormData.label: i18n("Duration:")
                from: 0
                to: 9999
                stepSize: 50
                enabled: animatePropertyChanges.checked
            }

            Kirigami.Separator {
                Kirigami.FormData.isSection: true
                Kirigami.FormData.label: i18n("D-Bus Service")
                Layout.fillWidth: true
            }

            CheckBox {
                id: enableDBusService

                Kirigami.FormData.label: i18n("Enabled:")
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
                id: pythonExecutable

                Kirigami.FormData.label: i18n("Python 3 executable:")
                placeholderText: qsTr("Python executable e.g. python, python3")
                enabled: enableDBusService.checked
            }

            Label {
                text: i18n("Required to run the D-Bus service in the background")
                wrapMode: Text.WordWrap
                Layout.preferredWidth: 400
                opacity: 0.6
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
                enabled: enableDBusService.checked
            }

            Label {
                text: i18n("Preview and switch presets using fzf + qdbus6 + jq:")
            }

            TextArea {
                text: "find " + presetsBuiltinDir + " " + presetsDir + " -mindepth 1 -prune -type d | fzf --preview 'qdbus6 " + dbusName + " /preset preset {} && jq --color-output . {}/settings.json'"
                readOnly: true
                wrapMode: Text.WordWrap
                Layout.preferredWidth: 400
                enabled: enableDBusService.checked
            }

            Label {
                text: i18n("Hide all panels")
            }

            TextArea {
                text: `dbus-send --session --type=signal /preset luisbocanegra.panel.colorizer.all.property string:'stockPanelSettings.visible {"enabled": true, "value": false}'`
                readOnly: true
                wrapMode: Text.WordWrap
                Layout.preferredWidth: 400
                enabled: enableDBusService.checked
            }

            Label {
                text: i18n("Show all panels")
            }

            TextArea {
                text: `dbus-send --session --type=signal /preset luisbocanegra.panel.colorizer.all.property string:'stockPanelSettings.visible {"enabled": true, "value": true}'`
                readOnly: true
                wrapMode: Text.WordWrap
                Layout.preferredWidth: 400
                enabled: enableDBusService.checked
            }
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

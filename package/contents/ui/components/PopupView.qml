import QtCore
import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.plasmoid
import "../"

ColumnLayout {
    id: popup
    property var main
    Layout.minimumWidth: Kirigami.Units.gridUnit * 25
    Layout.minimumHeight: Kirigami.Units.gridUnit * 25
    Layout.maximumWidth: Kirigami.Units.gridUnit * 25
    Layout.maximumHeight: Kirigami.Units.gridUnit * 25

    property string presetsDir: StandardPaths.writableLocation(StandardPaths.HomeLocation).toString().substring(7) + "/.config/panel-colorizer/presets"
    property string cratePresetsDirCmd: "mkdir -p " + presetsDir
    property string presetsBuiltinDir: Qt.resolvedUrl("../presets").toString().substring(7) + "/"
    property string toolsDir: Qt.resolvedUrl("../tools").toString().substring(7) + "/"
    property string listUserPresetsCmd: "'" + toolsDir + "list_presets.sh' '" + presetsDir + "'"
    property string listBuiltinPresetsCmd: "'" + toolsDir + "list_presets.sh' '" + presetsBuiltinDir + "' b"
    property string listPresetsCmd: listBuiltinPresetsCmd + ";" + listUserPresetsCmd

    ListModel {
        id: presetsModel
    }

    RunCommand {
        id: listPresets
    }

    Component.onCompleted: {
        listPresets.run(listPresetsCmd);
    }

    Connections {
        target: listPresets
        function onExited(cmd, exitCode, exitStatus, stdout, stderr) {
            if (exitCode !== 0) {
                console.error(cmd, exitCode, exitStatus, stdout, stderr);
                return;
            }
            if (cmd === popup.listPresetsCmd) {
                if (stdout.length === 0)
                    return;
                const out = stdout.trim().split("\n");
                for (const line of out) {
                    let builtin = false;
                    const parts = line.split(":");
                    const path = parts[parts.length - 1];
                    let name = path.split("/");
                    name = name[name.length - 1];
                    const dir = parts[1];
                    if (line.startsWith("b:")) {
                        builtin = true;
                    }
                    presetsModel.append({
                        "name": name,
                        "value": dir
                    });
                }
            }
        }
    }
    ColumnLayout {
        visible: popup.main.runningLatest
        PlasmaComponents.Label {
            text: i18n("Select a preset")
            Layout.fillWidth: true
            font.weight: Font.DemiBold
            Layout.leftMargin: Kirigami.Units.smallSpacing
        }

        ListView {
            id: listView
            clip: true
            // Layout.preferredWidth: Kirigami.Units.gridUnit * 10
            // Layout.preferredHeight: Kirigami.Units.gridUnit * 12
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: presetsModel
            delegate: PlasmaComponents.ItemDelegate {
                id: presetDelegate
                width: ListView.view.width
                required property string name
                required property string value
                contentItem: RowLayout {
                    spacing: Kirigami.Units.smallSpacing
                    PlasmaComponents.Label {
                        Layout.fillWidth: true
                        text: presetDelegate.name
                        textFormat: Text.PlainText
                        elide: Text.ElideRight
                    }
                }

                onClicked: {
                    popup.main.applyPreset(value);
                }
            }
        }
    }

    ColumnLayout {
        visible: !popup.main.runningLatest
        PlasmaExtras.PlaceholderMessage {
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            Layout.margins: Kirigami.Units.gridUnit
            iconName: "dialog-warning"
            text: i18n("Running outdated version of %1", Plasmoid.metaData.name)
        }

        PlasmaComponents.Label {
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            Layout.margins: Kirigami.Units.gridUnit
            text: i18n("Running version of the widget (%1) is different to the one on disk (%2), please log out and back in (or restart plasmashell user unit) to ensure things work correctly!", Plasmoid.metaData.version, popup.main.localVersion.version)
            Layout.fillWidth: true
            wrapMode: Text.Wrap
        }
    }
}

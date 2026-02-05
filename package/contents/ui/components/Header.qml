import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import ".."
import "../code/version.js" as VersionUtil

ColumnLayout {
    id: root
    property alias isEnabled: isEnabledCheckbox.checked
    property string lastPresetDir: plasmoid.configuration.lastPreset
    property string lastPresetName: {
        let name = lastPresetDir.split("/");
        return name[name.length - 1] || i18n("None");
    }
    property var localVersion: new VersionUtil.Version("999.999.999") // to assume latest
    property string metadataFile: Qt.resolvedUrl("../../../metadata.json").toString().substring(7)
    property string localVersionCmd: `cat '${metadataFile}' | grep \\"Version | sed 's/.* //;s/[",]//g'`
    property bool ready: false
    spacing: 0
    RowLayout {
        spacing: 0
        Layout.leftMargin: Kirigami.Units.mediumSpacing
        RowLayout {
            Label {
                text: i18n("Enable %1:", Plasmoid.metaData.name)
            }

            CheckBox {
                id: isEnabledCheckbox
            }
        }

        Item {
            Layout.fillWidth: true
        }

        RowLayout {
            Layout.rightMargin: Kirigami.Units.smallSpacing

            Label {
                text: i18n("Last preset loaded:")
            }

            Label {
                text: lastPresetName
                font.weight: Font.DemiBold
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignRight

            Label {
                text: i18n("Version:")
            }

            Label {
                text: Plasmoid.metaData.version
                font.weight: Font.DemiBold
            }
        }

        ToolButton {
            id: linksButton

            icon.name: "application-menu"
            onClicked: {
                if (linksMenu.visible)
                    linksMenu.dismiss();
                else
                    linksMenu.popup(this, x, y + height);
            }
        }

        Menu {
            id: linksMenu

            Action {
                text: i18n("Changelog")
                onTriggered: Qt.openUrlExternally("https://github.com/luisbocanegra/plasma-panel-colorizer/blob/main/CHANGELOG.md")
                icon.name: "view-calendar-list-symbolic"
            }

            Action {
                text: i18n("Releases")
                onTriggered: Qt.openUrlExternally("https://github.com/luisbocanegra/plasma-panel-colorizer/releases")
                icon.name: "update-none-symbolic"
            }

            Action {
                text: "Discord"
                icon.source: Qt.resolvedUrl("../../icons/discord.svg")
                onTriggered: Qt.openUrlExternally("https://discord.gg/ZqD75dzKTe")
            }

            Action {
                text: "Matrix"
                icon.name: Qt.resolvedUrl("../../icons/matrix_logo.svg").toString().replace("file://", "")
                onTriggered: Qt.openUrlExternally("https://matrix.to/#/#kde-plasma-panel-colorizer:matrix.org")
            }

            MenuSeparator {}

            Menu {
                title: i18n("Home page")
                icon.name: "globe"

                Action {
                    text: "GitHub"
                    onTriggered: Qt.openUrlExternally("https://github.com/luisbocanegra/plasma-panel-colorizer")
                }

                Action {
                    text: i18n("KDE Store")
                    onTriggered: Qt.openUrlExternally("https://store.kde.org/p/2130967")
                }
            }

            Menu {
                title: i18n("Issues")
                icon.source: Qt.resolvedUrl("../../icons/github.svg")

                Action {
                    text: i18n("Current issues")
                    onTriggered: Qt.openUrlExternally("https://github.com/luisbocanegra/plasma-panel-colorizer/issues?q=sort%3Aupdated-desc+is%3Aissue+is%3Aopen")
                }

                Action {
                    text: i18n("Report a bug")
                    onTriggered: Qt.openUrlExternally("https://github.com/luisbocanegra/plasma-panel-colorizer/issues/new?assignees=&labels=bug&projects=&template=bug_report.md&title=%5BBug%5D%3A+")
                }

                Action {
                    text: i18n("Request a feature")
                    onTriggered: Qt.openUrlExternally("https://github.com/luisbocanegra/plasma-panel-colorizer/issues/new?assignees=&labels=enhancement&projects=&template=feature_request.md&title=%5BFeature+Request%5D%3A+")
                }
            }

            Menu {
                title: i18n("Help")
                icon.name: "question-symbolic"

                Action {
                    text: i18n("FAQ")
                    onTriggered: Qt.openUrlExternally("https://github.com/luisbocanegra/plasma-panel-colorizer?tab=readme-ov-file#faq")
                }

                Action {
                    text: i18n("GitHub Discussions")
                    onTriggered: Qt.openUrlExternally("https://github.com/luisbocanegra/plasma-panel-colorizer/discussions")
                }

                Action {
                    text: i18n("Send an email")
                    onTriggered: Qt.openUrlExternally("mailto:luisbocanegra17b@gmail.com")
                }
            }

            Action {
                text: i18n("Translate")
                onTriggered: Qt.openUrlExternally("https://github.com/luisbocanegra/plasma-panel-colorizer/tree/main/package/translate")
                icon.name: "translate-symbolic"
            }

            MenuSeparator {}

            Menu {
                id: donateMenu
                title: i18n("Donate")
                icon.name: "emblem-favorite-symbolic"

                Instantiator {
                    model: [
                        {
                            label: "GitHub Sponsors",
                            url: "https://github.com/sponsors/luisbocanegra"
                        },
                        {
                            label: "Ko-fi",
                            url: "https://ko-fi.com/luisbocanegra"
                        },
                        {
                            label: "Patreon",
                            url: "https://www.patreon.com/luisbocanegra"
                        },
                        {
                            label: "PayPal",
                            url: "https://www.paypal.com/donate/?hosted_button_id=Y5TMH3Z4YZRDA"
                        },
                        {
                            label: "Liberapay",
                            url: "https://liberapay.com/luisbocanegra"
                        },
                        {
                            label: "Buy Me A Coffee",
                            url: "https://buymeacoffee.com/luisbocanegra"
                        },
                    ]
                    delegate: MenuItem {
                        required property var modelData
                        text: modelData.label
                        onTriggered: Qt.openUrlExternally(modelData.url)
                    }
                    onObjectAdded: (index, object) => donateMenu.insertItem(index, object)
                }
            }

            Action {
                text: i18n("More projects")
                onTriggered: Qt.openUrlExternally("https://github.com/luisbocanegra?tab=repositories&type=source")
                icon.name: "starred"
            }
        }
    }
    Kirigami.InlineMessage {
        id: warningResources
        Layout.fillWidth: true
        text: i18n("Running version of the widget (%1) is different to the one on disk (%2), please log out and back in (or restart plasmashell user unit) to ensure things work correctly!", Plasmoid.metaData.version, root.localVersion.version)
        visible: !root.localVersion.isEqual(Plasmoid.metaData.version) && root.ready
        type: Kirigami.MessageType.Warning
        Layout.bottomMargin: Kirigami.Units.mediumSpacing
        Layout.leftMargin: Kirigami.Units.mediumSpacing
        Layout.rightMargin: Kirigami.Units.mediumSpacing
    }
    RunCommand {
        id: runCommand
        onExited: (cmd, exitCode, exitStatus, stdout, stderr) => {
            if (exitCode !== 0) {
                console.error(cmd, exitCode, exitStatus, stdout, stderr);
                return;
            }
            if (stdout) {
                root.localVersion = new VersionUtil.Version(stdout.trim());
                root.ready = true;
            }
        }
    }
    Component.onCompleted: {
        runCommand.run(root.localVersionCmd);
    }
}

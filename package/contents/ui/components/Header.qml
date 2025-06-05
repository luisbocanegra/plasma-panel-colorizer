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
        return name[name.length - 1] || "None";
    }
    property var localVersion: new VersionUtil.Version("999.999.999") // to assume latest
    property string metadataFile: Qt.resolvedUrl("../../../metadata.json").toString().substring(7)
    property string localVersionCmd: `cat '${metadataFile}' | grep \\"Version | sed 's/.* //;s/[",]//g'`
    property bool ready: false
    spacing: 0
    RowLayout {
        Layout.leftMargin: Kirigami.Units.mediumSpacing
        RowLayout {
            Label {
                text: i18n("Enable %1:", Plasmoid.metaData.name)
            }

            CheckBox {
                id: isEnabledCheckbox

                Kirigami.Theme.inherit: false
                text: checked ? "" : i18n("Disabled")

                Binding {
                    target: isEnabledCheckbox
                    property: "Kirigami.Theme.textColor"
                    value: Kirigami.Theme.neutralTextColor
                    when: !isEnabledCheckbox.checked
                }
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

        Menu {
            id: menu

            y: linksButton.height
            x: linksButton.x

            Action {
                text: "Changelog"
                onTriggered: Qt.openUrlExternally("https://github.com/luisbocanegra/plasma-panel-colorizer/blob/main/CHANGELOG.md")
                icon.name: "view-calendar-list-symbolic"
            }

            Action {
                text: "Releases"
                onTriggered: Qt.openUrlExternally("https://github.com/luisbocanegra/plasma-panel-colorizer/releases")
                icon.name: "update-none-symbolic"
            }

            Action {
                text: "Matrix chat"
                icon.name: Qt.resolvedUrl("../../icons/matrix_logo.svg").toString().replace("file://", "")
                onTriggered: Qt.openUrlExternally("https://matrix.to/#/#kde-plasma-panel-colorizer:matrix.org")
            }

            MenuSeparator {}

            Menu {
                title: "Home page"
                icon.name: "globe"

                Action {
                    text: "GitHub"
                    onTriggered: Qt.openUrlExternally("https://github.com/luisbocanegra/plasma-panel-colorizer")
                }

                Action {
                    text: "KDE Store"
                    onTriggered: Qt.openUrlExternally("https://store.kde.org/p/2130967")
                }
            }

            Menu {
                title: "Issues"
                icon.name: "project-open-symbolic"

                Action {
                    text: "Current issues"
                    onTriggered: Qt.openUrlExternally("https://github.com/luisbocanegra/plasma-panel-colorizer/issues?q=sort%3Aupdated-desc+is%3Aissue+is%3Aopen")
                }

                Action {
                    text: "Report a bug"
                    onTriggered: Qt.openUrlExternally("https://github.com/luisbocanegra/plasma-panel-colorizer/issues/new?assignees=&labels=bug&projects=&template=bug_report.md&title=%5BBug%5D%3A+")
                }

                Action {
                    text: "Request a feature"
                    onTriggered: Qt.openUrlExternally("https://github.com/luisbocanegra/plasma-panel-colorizer/issues/new?assignees=&labels=enhancement&projects=&template=feature_request.md&title=%5BFeature+Request%5D%3A+")
                }
            }

            Menu {
                title: "Help"
                icon.name: "question-symbolic"

                Action {
                    text: "FAQ"
                    onTriggered: Qt.openUrlExternally("https://github.com/luisbocanegra/plasma-panel-colorizer?tab=readme-ov-file#faq")
                }

                Action {
                    text: "Discussions"
                    onTriggered: Qt.openUrlExternally("https://github.com/luisbocanegra/plasma-panel-colorizer/discussions")
                }

                Action {
                    text: "Send an email"
                    onTriggered: Qt.openUrlExternally("mailto:luisbocanegra17b@gmail.com")
                }
            }

            MenuSeparator {}

            Menu {
                title: "Donate"
                icon.name: "love"

                Action {
                    text: "GitHub sponsors"
                    onTriggered: Qt.openUrlExternally("https://github.com/sponsors/luisbocanegra")
                }

                Action {
                    text: "Ko-fi"
                    onTriggered: Qt.openUrlExternally("https://ko-fi.com/luisbocanegra")
                }

                Action {
                    text: "Paypal"
                    onTriggered: Qt.openUrlExternally("https://www.paypal.com/donate/?hosted_button_id=Y5TMH3Z4YZRDA")
                }
            }

            Action {
                text: "My other projects"
                onTriggered: Qt.openUrlExternally("https://github.com/luisbocanegra?tab=repositories&type=source")
                icon.name: "starred"
            }
        }

        ToolButton {
            id: linksButton

            icon.name: "application-menu"
            onClicked: {
                if (menu.opened)
                    menu.close();
                else
                    menu.open();
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

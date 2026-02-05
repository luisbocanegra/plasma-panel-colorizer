import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid

ColumnLayout {
    id: root
    Kirigami.Heading {
        text: i18n("Thank you for using %1!", Plasmoid.metaData.name)
        Layout.fillWidth: true
        wrapMode: Text.Wrap
        font.bold: true
    }

    Label {
        text: i18n("If you enjoy using the plugin please consider sponsoring or donating so I can dedicate more time to maintain and improve this and <a href=\"https://github.com/luisbocanegra?tab=repositories&q=&type=source&language=&sort=stargazers\">my other projects</a>.")
        Layout.fillWidth: true
        wrapMode: Text.Wrap
        onLinkActivated: link => Qt.openUrlExternally(link)
    }

    Flow {
        Layout.fillWidth: true
        spacing: Kirigami.Units.largeSpacing
        Repeater {
            model: [
                {
                    label: "GitHub Sponsors",
                    icon: Qt.resolvedUrl("../../icons/githubsponsors.svg"),
                    url: "https://github.com/sponsors/luisbocanegra",
                    backgroundColor: "#29313C"
                },
                {
                    label: "Ko-fi",
                    icon: Qt.resolvedUrl("../../icons/kofi.svg"),
                    url: "https://ko-fi.com/luisbocanegra",
                    backgroundColor: "#72a4f2"
                },
                {
                    label: "Buy Me A Coffee",
                    icon: Qt.resolvedUrl("../../icons/buymeacoffee.svg"),
                    url: "https://buymeacoffee.com/luisbocanegra",
                    backgroundColor: "#FF7F41"
                },
                {
                    label: "Liberapay",
                    icon: Qt.resolvedUrl("../../icons/liberapay.svg"),
                    url: "https://liberapay.com/luisbocanegra",
                    backgroundColor: "#F6C915"
                },
                {
                    label: "PayPal",
                    icon: Qt.resolvedUrl("../../icons/paypal.svg"),
                    url: "https://www.paypal.com/donate/?hosted_button_id=Y5TMH3Z4YZRDA",
                    backgroundColor: "#002991"
                },
                {
                    label: "Patreon",
                    icon: Qt.resolvedUrl("../../icons/patreon.svg"),
                    url: "https://www.patreon.com/luisbocanegra",
                    backgroundColor: "#000000"
                },
            ]
            delegate: ColoredButton {
                required property var modelData
                icon.name: modelData.icon
                text: modelData.label
                url: modelData.url
                backgroundColor: modelData.backgroundColor
            }
        }
    }

    Kirigami.Heading {
        Layout.topMargin: Kirigami.Units.smallSpacing
        Layout.fillWidth: true
        wrapMode: Text.Wrap
        text: i18n("You can also")
        font.bold: true
    }

    Flow {
        Layout.fillWidth: true
        spacing: Kirigami.Units.largeSpacing
        Repeater {
            model: [
                {
                    label: i18n("Star the project on GitHub"),
                    icon: Qt.resolvedUrl("../../icons/githubstar.svg"),
                    url: "https://github.com/luisbocanegra/plasma-panel-colorizer",
                    backgroundColor: "#29313C"
                },
                {
                    label: i18n("Rate in the KDE Store"),
                    icon: Qt.resolvedUrl("../../icons/kde.svg"),
                    url: "https://store.kde.org/p/2130967",
                    backgroundColor: "#2C9AFD"
                },
                {
                    label: i18n("Translate %1 to your language", Plasmoid.metaData.name),
                    icon: "translate-symbolic",
                    url: "https://github.com/luisbocanegra/plasma-panel-colorizer/tree/main/package/translate",
                    backgroundColor: root.Kirigami.Theme.linkBackgroundColor
                }
            ]
            delegate: ColoredButton {
                property color f: Kirigami.Theme.linkBackgroundColor
                required property var modelData
                icon.source: modelData.icon
                text: modelData.label
                url: modelData.url
                backgroundColor: modelData.backgroundColor
            }
        }
    }
}

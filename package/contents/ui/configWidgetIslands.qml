pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import "components" as Components

KCM.SimpleKCM {
    id: root

    property alias cfg_isEnabled: headerComponent.isEnabled
    property alias cfg_islandsEnabled: islandsEnabled.checked
    property alias cfg_islandSeparatorPairing: islandSeparatorPairing.checked
    property alias cfg_islandSeparatorWidget: islandSeparatorWidget.text
    property alias cfg_blacklistIslandSeparator: blacklistIslandSeparator.checked

    ColumnLayout {
        enabled: root.cfg_isEnabled

        ColumnLayout {
            Layout.margins: Kirigami.Units.largeSpacing
            spacing: Kirigami.Units.smallSpacing
            Label {
                Layout.fillWidth: true
                text: i18n("Create widget islands by placing separator widgets around them.")
                wrapMode: Label.WordWrap
                font.features: {
                    "tnum": 1
                }
            }
            Label {
                Layout.fillWidth: true
                text: i18n("<strong>How to use</strong><br>1. Add the widget that will act as islands separator to the panel(by default the Plasma's Panel Spacer widget will be used)<br>2. Select the separator widget below<br>3. Add as many separators as you need and move them to create islands.")
                wrapMode: Label.WordWrap
                font.features: {
                    "tnum": 1
                }
            }
            Label {
                Layout.fillWidth: true
                text: i18n("<strong>Notes</strong><br>- Widget custom background or border is required for this option to have a visible effect.<br>- If the widgets in your panel have different thickness, add margins to the widgets custom background in the Appearance tab.")
                wrapMode: Label.WordWrap
                font.features: {
                    "tnum": 1
                }
            }
            Label {
                Layout.fillWidth: true
                text: i18n("<strong>Need a separator widget?</strong><br>- <a href=\"%1\">Panel Colorizer Islands Separator</a> visible only in Edit Mode.<br>- <a href=\"%2\">Advanced Separator</a> always visible and configurable.", "https://github.com/luisbocanegra/plasma-panel-colorizer-islands-separator", "https://github.com/luisbocanegra/plasma-advanced-separator")
                wrapMode: Label.WordWrap
                onLinkActivated: url => Qt.openUrlExternally(url)
                font.features: {
                    "tnum": 1
                }
            }
        }

        Components.WidgetIslandsHint {
            Layout.alignment: Qt.AlignHCenter
        }

        Kirigami.FormLayout {
            CheckBox {
                id: islandsEnabled
                Kirigami.FormData.label: i18n("Enabled:")
                Layout.alignment: Qt.AlignTop
            }

            RowLayout {
                Kirigami.FormData.label: i18n("Separator widget:")
                Layout.preferredWidth: 300
                TextField {
                    id: islandSeparatorWidget
                    Layout.fillWidth: true
                    placeholderText: "auto"
                }
                Button {
                    icon.name: widgetsCard.visible ? "arrow-up" : "arrow-down"
                    onClicked: {
                        widgetsCard.visible = !widgetsCard.visible;
                    }
                    checkable: true
                    checked: widgetsCard.visible
                    Layout.fillHeight: true
                }
                Kirigami.ContextualHelpButton {
                    toolTipText: i18n("Select the widget that will act as separator for the islands.<br><br>Note that the separator widget itself does not need to be visible for it to work, so you can use an invisible spacer/separator for example.")
                }
            }

            Kirigami.AbstractCard {
                id: widgetsCard
                implicitHeight: 200
                visible: false
                Layout.fillWidth: true
                contentItem: ScrollView {
                    clip: true
                    ListView {
                        model: {
                            let uniqueWidgets = [
                                {
                                    name: "org.kde.plasma.panelspacer",
                                    title: "Panel Spacer",
                                    inTray: false
                                }
                            ];
                            for (let widget of JSON.parse(Plasmoid.configuration.panelWidgets).filter(w => !w.inTray)) {
                                if (!uniqueWidgets.find(w => w.name === widget.name)) {
                                    uniqueWidgets.push(widget);
                                }
                            }
                            return uniqueWidgets;
                        }
                        delegate: ItemDelegate {
                            id: delegate
                            required property var modelData
                            // required property Item root
                            width: ListView.view.width
                            text: modelData.title
                            contentItem: Label {
                                text: delegate.text
                                wrapMode: Label.WrapAnywhere
                                Layout.fillWidth: true
                                font: Kirigami.Theme.smallFont
                            }
                            ToolTip.visible: false
                            onClicked: root.cfg_islandSeparatorWidget = modelData.name
                        }
                    }
                }
            }

            RowLayout {
                Kirigami.FormData.label: i18n("Require two separators per island:")
                Kirigami.FormData.buddyFor: islandSeparatorPairing
                CheckBox {
                    id: islandSeparatorPairing
                    Layout.alignment: Qt.AlignTop
                    enabled: root.cfg_islandsEnabled
                }

                Kirigami.ContextualHelpButton {
                    toolTipText: i18n("Always require two separators for a group of widgets to become an island. By default, an arrangement of<br>%1 creates two islands.<br><br>Enabling this option makes it so that islands do not share separators, so for example an arrangement of<br>%2 is required to create two islands.<br><br>Enable this if your islands separator is not a panel spacer and you want to explicitly define the start and end of each island.", "<strong>widgets|separator|widgets</strong>", "<strong>separator|widgets|separator|separator|widgets|separator</strong>")
                }
            }
            RowLayout {
                Kirigami.FormData.label: i18n("Blacklist separator widgets:")
                Kirigami.FormData.buddyFor: blacklistIslandSeparator
                CheckBox {
                    id: blacklistIslandSeparator
                    Layout.alignment: Qt.AlignTop
                    enabled: root.cfg_islandsEnabled
                }

                Kirigami.ContextualHelpButton {
                    toolTipText: i18n("Disable customization from separator widgets")
                }
            }
        }
    }

    header: ColumnLayout {
        readonly property int spacings: Kirigami.Units.largeSpacing
        Layout.margins: spacings
        Components.Header {
            id: headerComponent
        }
    }
}

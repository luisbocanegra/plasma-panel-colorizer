pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "code/globals.js" as Globals
import "components" as Components
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid

KCM.SimpleKCM {
    id: appearanceRoot
    property alias parentLayout: parentLayout

    property int currentTab
    property int currentState
    property string cfg_globalSettings
    property alias cfg_isEnabled: headerComponent.isEnabled
    property bool ready: false
    property var settingsItem: null
    property var followVisbility: {
        "widgets": {
            "background": {
                "panel": true,
                "widget": false,
                "tray": false
            },
            "foreground": {
                "panel": true,
                "widget": true,
                "tray": false
            }
        },
        "panel": {
            "background": {
                "panel": false,
                "widget": false,
                "tray": false
            },
            "foreground": {
                "panel": true,
                "widget": false,
                "tray": false
            }
        },
        "trayWidgets": {
            "background": {
                "panel": true,
                "widget": true,
                "tray": false
            },
            "foreground": {
                "panel": true,
                "widget": true,
                "tray": true
            }
        }
    }

    ColumnLayout {
        id: layout
        enabled: cfg_isEnabled
        width: appearanceRoot.availableWidth
        height: Math.max(implicitHeight, appearanceRoot.availableHeight)
        spacing: 0

        Kirigami.InlineMessage {
            Layout.fillWidth: true
            text: i18n("Not getting the expected result? Make sure you're editing the correct element.<br>Custom blur not working? Try reinstalling/rebuilding the C++ plugin using the latest source, <a href=\"https://github.com/luisbocanegra/plasma-panel-colorizer#build-from-source-with-c-plugin\">see instructions</a>.")
            visible: true
            type: Kirigami.MessageType.Information
            onLinkActivated: Qt.openUrlExternally(link)
        }

        Button {
            text: i18n("Restore default (removes all customizations)")
            icon.name: "kt-restore-defaults-symbolic"
            onClicked: {
                cfg_globalSettings = JSON.stringify(Globals.defaultConfig);
            }
            Layout.fillWidth: true
        }

        Item {
            Layout.preferredHeight: Kirigami.Units.largeSpacing
        }

        Kirigami.FormLayout {
            id: parentLayout

            Layout.fillWidth: true
            RowLayout {
                Kirigami.FormData.label: i18n("Element:")
                ComboBox {
                    id: targetComponent
                    textRole: "name"
                    valueRole: "value"
                    model: [
                        {
                            "name": i18n("Panel"),
                            "value": "panel"
                        },
                        {
                            "name": i18n("Widgets"),
                            "value": "widgets"
                        },
                        {
                            "name": i18n("Tray widgets"),
                            "value": "trayWidgets"
                        }
                    ]
                }
                Kirigami.ContextualHelpButton {
                    toolTipText: i18n("Part of the panel on which the options below will be applied.")
                }
            }
            ColumnLayout {
                Components.PanelElementHint {
                    target: targetComponent.currentIndex
                }
            }
        }

        Component {
            id: settingsComp
            Components.FormWidgetSettings {
                currentTab: appearanceRoot.currentTab
                configString: appearanceRoot.cfg_globalSettings
                handleString: true
                elementState: appearanceRoot.currentState
                elementName: targetComponent.currentValue
                elementFriendlyName: targetComponent.currentText
                followVisbility: appearanceRoot.followVisbility[targetComponent.currentValue]
                onElementStateChanged: appearanceRoot.currentState = elementState
                onTabChanged: currentTab => {
                    appearanceRoot.currentTab = currentTab;
                }
                onUpdateConfigString: (newString, newConfig) => {
                    if (!appearanceRoot.ready) {
                        return;
                    }
                    Qt.callLater(() => {
                        console.error("Components.FormWidgetSettings, Updated config string");
                        appearanceRoot.cfg_globalSettings = JSON.stringify(newConfig);
                    });
                }
            }
        }

        Component.onCompleted: {
            Qt.callLater(() => {
                appearanceRoot.settingsItem = settingsComp.createObject(layout);
                appearanceRoot.ready = true;
            });
        }
        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true
            visible: !appearanceRoot.settingsItem
            Kirigami.LoadingPlaceholder {
                anchors.centerIn: parent
            }
        }
    }

    Component.onDestruction: {
        if (appearanceRoot.settingsItem) {
            appearanceRoot.settingsItem.destroy();
            appearanceRoot.settingsItem = null;
        }
    }

    Connections {
        target: Qt.application
        function onAboutToQuit() {
            if (appearanceRoot.settingsItem) {
                appearanceRoot.settingsItem.destroy();
                appearanceRoot.settingsItem = null;
            }
        }
    }

    header: ColumnLayout {
        Components.Header {
            id: headerComponent
        }
    }
}

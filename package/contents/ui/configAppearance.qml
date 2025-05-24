import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "code/utils.js" as Utils
import "code/globals.js" as Globals
import "components" as Components
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid

KCM.SimpleKCM {
    id: root

    property int currentTab
    property int currentState
    property string cfg_globalSettings
    property alias cfg_isEnabled: headerComponent.isEnabled
    property bool ready: false
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
        enabled: cfg_isEnabled
        Component.onCompleted: {
            Utils.delay(500, () => {
                componentLoader.sourceComponent = settingsComp;
                root.ready = true;
            }, root);
        }

        Kirigami.InlineMessage {
            Layout.fillWidth: true
            text: i18n("Not getting the expected result? Make sure you're editing the correct element.")
            visible: true
            type: Kirigami.MessageType.Information
        }

        Button {
            text: i18n("Restore default (removes all customizations)")
            icon.name: "kt-restore-defaults-symbolic"
            onClicked: {
                cfg_globalSettings = JSON.stringify(Globals.defaultConfig);
                componentLoader.sourceComponent = null;
                componentLoader.sourceComponent = settingsComp;
            }
            Layout.fillWidth: true
        }

        Kirigami.FormLayout {
            id: parentLayout

            Layout.fillWidth: true

            ComboBox {
                id: targetComponent

                Kirigami.FormData.label: i18n("Element:")
                textRole: "name"
                valueRole: "value"
                onActivated: {
                    componentLoader.sourceComponent = null;
                    if (!root.ready)
                        return;

                    componentLoader.sourceComponent = settingsComp;
                }

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
        }

        Loader {
            id: componentLoader

            asynchronous: true
            sourceComponent: null
            Layout.fillWidth: true
            onLoaded: {
                item.configString = cfg_globalSettings;
                item.onUpdateConfigString.connect((newString, config) => {
                    cfg_globalSettings = newString;
                });
                item.currentTab = root.currentTab;
                item.handleString = true;
                item.elementState = root.currentState;
                item.elementName = targetComponent.currentValue;
                item.elementFriendlyName = targetComponent.currentText;
                item.followVisbility = root.followVisbility[targetComponent.currentValue];
                item.tabChanged.connect(currentTab => {
                    root.currentTab = currentTab;
                });
                item.elementStateChanged.connect(() => {
                    root.currentState = item.elementState;
                    componentLoader.sourceComponent = null;
                    componentLoader.sourceComponent = settingsComp;
                });
            }
        }

        Component {
            id: settingsComp

            Components.FormWidgetSettings {}
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

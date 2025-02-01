import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import "components" as Components
import "code/utils.js" as Utils

KCM.SimpleKCM {
    id: root

    property int currentTab
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
            "background" : {
                "panel": false,
                "widget": false,
                "tray": false
            },
            "foreground" : {
                "panel": true,
                "widget": false,
                "tray": false
            }
        },
        "trayWidgets": {
            "background" : {
                "panel": true,
                "widget": true,
                "tray": false
            },
            "foreground" : {
                "panel": true,
                "widget": true,
                "tray": true
            },
        }
    }

    header: ColumnLayout {
        Components.Header {
            id: headerComponent
            Layout.leftMargin: Kirigami.Units.mediumSpacing
            Layout.rightMargin: Kirigami.Units.mediumSpacing
        }
    }

    ColumnLayout {
        enabled: cfg_isEnabled
        Kirigami.InlineMessage {
            Layout.fillWidth: true
            text: i18n("Not getting the expected result? Make sure you're editing the correct element.")
            visible: true
            type: Kirigami.MessageType.Information
        }
        Kirigami.FormLayout {
            id: parentLayout
            Layout.fillWidth: true
            ComboBox {
                Kirigami.FormData.label: i18n("Element:")
                id: targetComponent
                textRole: "name"
                valueRole: "value"
                model: ListModel {
                    ListElement { name: "Panel"; value: "panel" }
                    ListElement { name: "Widgets"; value: "widgets" }
                    ListElement { name: "Tray elements"; value: "trayWidgets" }
                }
                onCurrentValueChanged: {
                    componentLoader.sourceComponent = null
                    if (!root.ready) return
                    componentLoader.sourceComponent = settingsComp
                }
            }
        }
        Component.onCompleted: {
            Utils.delay(500, () => {
                componentLoader.sourceComponent = settingsComp
                root.ready = true
            }, root)
        }
        Loader {
            asynchronous: true
            id: componentLoader
            sourceComponent: null
            Layout.fillWidth: true
            onLoaded: {
                item.configString = cfg_globalSettings
                item.onUpdateConfigString.connect((newString, config) => {
                    cfg_globalSettings = newString
                })
                item.currentTab = root.currentTab
                item.handleString = true
                item.keyName = targetComponent.currentValue
                item.keyFriendlyName = targetComponent.currentText
                item.followVisbility = root.followVisbility[targetComponent.currentValue]
                item.tabChanged.connect((currentTab) => {
                    root.currentTab = currentTab
                })
            }
        }

        Component {
            id: settingsComp
            Components.FormWidgetSettings {}
        }
    }
}

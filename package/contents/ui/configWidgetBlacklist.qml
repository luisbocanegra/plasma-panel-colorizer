import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import "components" as Components

KCM.SimpleKCM {
    id:root
    property string cfg_blacklist: ""
    property string cfg_panelWidgets

    ListModel {
        id: widgetsModel
    }

    function initWidgets(){
        const lines = cfg_panelWidgets.trim().split("|")
        for (let i in lines) {
            if (lines[i].length < 1) continue
            const parts = lines[i].split(",")
            const name = parts[0]
            const title = parts[1]
            const icon = parts[2]
            widgetsModel.append({"name": name, "title": title, "icon": icon, "enabled": false})
        }
    }

    function updateWidgetsModel(){
        let widgeList = []
        const forceRecolorList = cfg_blacklist.trim().split("|")
        for (let i = 0; i < widgetsModel.count; i++) {
            let widget = widgetsModel.get(i)
            for (let j in forceRecolorList) {
                if(widget.name.includes(forceRecolorList[j])) {
                    widgetsModel.set(i, {"enabled": true})
                }
            }
        }
    }

    function updateWidgetsString(){
        var newString = ""
        for (let i = 0; i < widgetsModel.count; i++) {
            let widget = widgetsModel.get(i)
            if (widget.enabled) {
                newString += widget.name + "|"
            }
        }
        cfg_blacklist = newString
    }

    Component.onCompleted: {
        initWidgets()
        updateWidgetsModel()
    }

    header: RowLayout {
        RowLayout {
            Layout.leftMargin: Kirigami.Units.mediumSpacing
            Layout.rightMargin: Kirigami.Units.smallSpacing
            Item {
                Layout.fillWidth: true
            }
            RowLayout {
                Layout.alignment: Qt.AlignRight
                Label {
                    text: i18n("Last preset loaded:")
                }
                Label {
                    text: plasmoid.configuration.lastPreset || "None"
                    font.weight: Font.DemiBold
                }
            }
        }
    }

    ColumnLayout {
        Label {
            Layout.alignment: Qt.AlignHCenter
            text: i18n("Unchecked widgets will not be colorized.")
            Layout.maximumWidth: widgetCards.width
            wrapMode: Text.Wrap
        }

    Kirigami.FormLayout {

        ColumnLayout {
            id: widgetCards
            Repeater {
                model: widgetsModel
                delegate: Kirigami.AbstractCard {
                    contentItem: RowLayout {
                        Kirigami.Icon {
                            width: Kirigami.Units.gridUnit
                            height: width
                            source: widgetsModel.get(index).icon
                        }
                        ColumnLayout {
                            Label {
                                text: widgetsModel.get(index).title
                            }
                            Label {
                                text: widgetsModel.get(index).name
                                opacity: 0.6
                            }
                        }
                        Item {
                            Layout.fillWidth: true
                        }
                        Button {
                            checkable: true
                            checked: widgetsModel.get(index).enabled
                            icon.name: checked ? "edit-delete-remove-symbolic" : "checkmark-symbolic"
                            onCheckedChanged: {
                                widgetsModel.set(index, {"enabled": checked})
                                updateWidgetsString()
                            }
                        }
                    }
                }
            }
        }
    }
    }
}

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import "components" as Components

KCM.SimpleKCM {
    id:root
    property string cfg_blacklist: blacklist.text
    property string cfg_panelWidgets

    ListModel {
        id: widgetsModel
    }

    function initWidgets(){
        const lines = cfg_panelWidgets.trim().split("\n")
        for (let i in lines) {
            const parts = lines[i].split("|")
            const name = parts[0]
            const title = parts[1]
            const icon = parts[2]
            widgetsModel.append({"name": name, "title": title, "icon": icon, "enabled": false})
        }
    }

    function updateWidgetsModel(){
        let widgeList = []
        const forceRecolorList = cfg_blacklist.trim().split("\n")
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
                newString += widget.name + "\n"
            }
        }
        cfg_blacklist = newString
    }

    Component.onCompleted: {
        initWidgets()
        updateWidgetsModel()
    }

    Kirigami.FormLayout {

        
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: "Blacklist"
        }

        Label {
            text: i18n("Widget selected below will not be colorized")
            opacity: 0.7
            Layout.maximumWidth: widgetCards.width
            wrapMode: Text.Wrap
        }

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
                            icon.name: checked ? "checkmark-symbolic" : "edit-delete-remove-symbolic"
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

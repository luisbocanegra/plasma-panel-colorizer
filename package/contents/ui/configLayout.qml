import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import "components" as Components

KCM.SimpleKCM {
    id:root
    property bool cfg_isEnabled: isEnabled.checked
    property bool cfg_layoutEnabled: layoutEnabled.checked
    property int cfg_widgetBgHMargin: widgetBgHMargin.value
    property int cfg_widgetBgVMargin: widgetBgVMargin.value
    property string cfg_marginRules: ""
    property int cfg_panelSpacing: panelSpacing.value
    property string cfg_panelWidgets

    ListModel {
        id: widgetsModel
    }

    function initWidgets(){
        widgetsModel.clear()
        const lines = cfg_panelWidgets.trim().split("|")
        for (let i in lines) {
            if (lines[i].length < 1) continue
            const parts = lines[i].split(",")
            const name = parts[0]
            const title = parts[1]
            const icon = parts[2]
            widgetsModel.append(
                {
                    "name": name,
                    "title": title,
                    "icon": icon,
                    "enabled": false,
                    "vExtraMargin": 0,
                    "hExtraMargin": 0
                }
            )
        }
    }

    function updateWidgetsModel(){
        let widgeList = []
        const forceRecolorList = cfg_marginRules.split("|")
        for (let i = 0; i < widgetsModel.count; i++) {
            let widget = widgetsModel.get(i)
            // if (widget.length < 1) continue
            let name = ""
            let vMargin = 0
            let hMargin = 0 
            for (let j in forceRecolorList) {
                if (forceRecolorList[j].length < 1) continue
                const parts = forceRecolorList[j].split(",")
                //console.error(widget.name, parts.join(" "));
                name = parts[0]
                if(widget.name.includes(name)) {
                    vMargin = parseInt(parts[1])
                    hMargin = parseInt(parts[2])
                    widgetsModel.set(i, {"vExtraMargin": vMargin, "hExtraMargin": hMargin})
                    break
                }
            }
        }
    }

    function updateWidgetsString(){
        console.log("UPDATING STRING");
        console.log("current:", cfg_marginRules);
        var currentWidgets = new Map()

        cfg_marginRules.trim().split("|").forEach(function(item) {
            if (item) {
                var parts = item.split(",");
                currentWidgets.set(parts[0], parts.slice(1).join(","));
            }
        })

        for (let i = 0; i < widgetsModel.count; i++) {
            let widget = widgetsModel.get(i)
            const widgetMargins = widget.vExtraMargin + "," + widget.hExtraMargin
            currentWidgets.set(widget.name, widgetMargins)
        }
        cfg_marginRules = Array.from(currentWidgets).map(([k, v]) => k + "," + v).join("|")
        console.log("new:", cfg_marginRules)
    }

    Component.onCompleted: {
        initWidgets()
        updateWidgetsModel()
    }

    header: RowLayout {
        RowLayout {
            Layout.leftMargin: Kirigami.Units.mediumSpacing
            Layout.rightMargin: Kirigami.Units.smallSpacing
            RowLayout {
                Layout.alignment: Qt.AlignRight
                Label {
                    text: i18n("Enabled:")
                }
                CheckBox {
                    id: layoutEnabled
                    checked: cfg_layoutEnabled
                    onCheckedChanged: cfg_layoutEnabled = checked
                }
            }
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
        Kirigami.FormLayout {
            enabled: cfg_layoutEnabled
            visible: cfg_isEnabled

            Kirigami.Separator {
                Kirigami.FormData.isSection: true
                Kirigami.FormData.label: i18n("Background margin")
            }

            SpinBox {
                Kirigami.FormData.label: i18n("Spacing:")
                id: panelSpacing
                from: 0
                to: 999
                stepSize: 1
                value: cfg_panelSpacing
                onValueModified: {
                    cfg_panelSpacing = value
                }
            }

            SpinBox {
                Kirigami.FormData.label: i18n("Vertical:")
                id: widgetBgVMargin
                from: 0
                to: 999
                stepSize: 1
                value: cfg_widgetBgVMargin
                onValueModified: {
                    cfg_widgetBgVMargin = value
                }
            }

            SpinBox {
                Kirigami.FormData.label: i18n("Horizontal:")
                id: widgetBgHMargin
                from: 0
                to: 999
                stepSize: 1
                value: cfg_widgetBgHMargin
                onValueModified: {
                    cfg_widgetBgHMargin = value
                }
            }

            Label {
                text: i18n("Extra horizontal/vertical margins per widget:")
                Layout.maximumWidth: widgetCards.width
                wrapMode: Text.Wrap
            }
        }

        Kirigami.FormLayout {
            // Layout.preferredWidth: 500
            // Layout.alignment: Qt.AlignHCenter
            RowLayout {
                Layout.preferredWidth: widgetCards.width
                Layout.minimumWidth: 100
                Button {
                    text: i18n("Restore default rules")
                    icon.name: "kt-restore-defaults-symbolic"
                    onClicked: {
                        cfg_marginRules = plasmoid.configuration.marginRulesDefault
                        initWidgets()
                        updateWidgetsModel()
                    }
                    Layout.fillWidth: true
                }
                KCM.ContextualHelpButton {
                    toolTipText: "Since version <strong>0.5.0</strong> partial widget names e.g. <i>clock</i> are no longer allowed.<br><br>If margins are not applied properly you can use this option to restore the default which has the correct format"
                }
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
                            source: model.icon
                            // active: compact.containsMouse
                        }
                        ColumnLayout {
                            // anchors.fill: parent
                            Label {
                                text: model.title
                            }
                            Label {
                                text: model.name
                                opacity: 0.6
                            }
                        }
                        Item {
                            Layout.fillWidth: true
                        }

                        ColumnLayout {
                            RowLayout {
                                Layout.alignment: Qt.AlignRight
                                Label {
                                    text: i18n("V:")
                                }
                                SpinBox {
                                    from: -999
                                    to: 999
                                    value: model.vExtraMargin
                                    onValueChanged: {
                                        widgetsModel.set(index, {"vExtraMargin": value})
                                        updateWidgetsString()
                                    }
                                }
                            }
                            RowLayout {
                                Layout.alignment: Qt.AlignRight
                                Label {
                                    text: i18n("H:")
                                }
                                SpinBox {
                                    from: -999
                                    to: 999
                                    value: model.hExtraMargin
                                    onValueChanged: {
                                        widgetsModel.set(index, {"hExtraMargin": value})
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
    }

    Components.CategoryDisabled {
        visible: !cfg_isEnabled
    }
}


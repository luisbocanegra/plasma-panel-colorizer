import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import org.kde.kcmutils
import "components" as Components

KCM.SimpleKCM {
    id:root
    property bool cfg_fgBlacklistedColorEnabled: fgBlacklistedColorEnabled.checked
    property int cfg_fgBlacklistedColorMode: plasmoid.configuration.fgBlacklistedColorMode
    property alias cfg_fgBlacklistedColorModeTheme: fgBlacklistedColorModeTheme.currentIndex
    property alias cfg_fgBlacklistedColorModeThemeVariant: fgBlacklistedColorModeThemeVariant.currentIndex
    property string cfg_blacklistedFgColor: blacklistedFgColor.color

    property string cfg_blacklist: ""
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
            widgetsModel.append({"name": name, "title": title, "icon": icon, "enabled": false})
        }
    }

    function updateWidgetsModel(){
        let widgeList = []
        const blacklist = cfg_blacklist.trim().split("|")
        console.log(cfg_blacklist);
        for (let i = 0; i < widgetsModel.count; i++) {
            let widget = widgetsModel.get(i)
            for (var j of blacklist) {
                if (j === "") continue
                if(widget.name.includes(j)) {
                    widgetsModel.set(i, {"enabled": true})
                }
            }
        }
    }

    function updateWidgetsString(){
        console.log("UPDATING STRING");
        console.log("current:", cfg_blacklist);
        var currentWidgets = new Set(cfg_blacklist.trim().split("|"))

        for (let i = 0; i < widgetsModel.count; i++) {
            const widget = widgetsModel.get(i)
            if (widget.enabled) {
                currentWidgets.add(widget.name)
            } else {
                currentWidgets.delete(widget.name)
            }
        }
        cfg_blacklist = Array.from(currentWidgets).join("|")
        console.log("new:", cfg_blacklist)
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

        Kirigami.FormLayout {
        CheckBox {
            Kirigami.FormData.label: i18n("Custom color:")
            id: fgBlacklistedColorEnabled
            checked: cfg_fgBlacklistedColorEnabled 
            onCheckedChanged: cfg_fgBlacklistedColorEnabled = checked
        }

        RadioButton {
            Kirigami.FormData.label: i18n("Source:")
            text: i18n("Custom")
            id: fgsingleColorRadio
            ButtonGroup.group: fgcolorModeGroup
            property int index: 0
            checked: plasmoid.configuration.fgBlacklistedColorMode === index
        }
        RadioButton {
            text: i18n("System")
            id: fgaccentColorRadio
            ButtonGroup.group: fgcolorModeGroup
            property int index: 1
            checked: plasmoid.configuration.fgBlacklistedColorMode === index
        }

        ButtonGroup {
            id: fgcolorModeGroup
            onCheckedButtonChanged: {
                if (checkedButton) {
                    cfg_fgBlacklistedColorMode = checkedButton.index
                }
            }
        }

        Components.ColorButton {
            id: blacklistedFgColor
            showAlphaChannel: false
            dialogTitle: i18n("Blacklisted text/icons")
            color: cfg_blacklistedFgColor
            visible: fgsingleColorRadio.checked
            enabled: fgBlacklistedColorEnabled.checked
            onAccepted: {
                cfg_blacklistedFgColor = color
            }
        }

        ComboBox {
            id: fgBlacklistedColorModeTheme
            Kirigami.FormData.label: i18n("Color:")
            model: [
                i18n("Text"),
                i18n("Disabled Text"),
                i18n("Highlighted Text"),
                i18n("Active Text"),
                i18n("Link"),
                i18n("Visited Link"),
                i18n("Negative Text"),
                i18n("Neutral Text"),
                i18n("Positive Text"),
                i18n("Background"),
                i18n("Highlight"),
                i18n("Active Background"),
                i18n("Link Background"),
                i18n("Visited Link Background"),
                i18n("Negative Background"),
                i18n("Neutral Background"),
                i18n("Positive Background"),
                i18n("Alternate Background"),
                i18n("Focus"),
                i18n("Hover")
            ]
            visible: fgaccentColorRadio.checked
            enabled: fgBlacklistedColorEnabled.checked
        }
        ComboBox {
            id: fgBlacklistedColorModeThemeVariant
            Kirigami.FormData.label: i18n("Color set:")
            model: [i18n("View"), i18n("Window"), i18n("Button"), i18n("Selection"), i18n("Tooltip"), i18n("Complementary"), i18n("Header")]
            visible: fgaccentColorRadio.checked
            enabled: fgBlacklistedColorEnabled.checked
        }
        }


        Label {
            Layout.alignment: Qt.AlignHCenter
            text: i18n("Unchecked widgets will not be colorized.")
            Layout.maximumWidth: widgetCards.width
            wrapMode: Text.Wrap
        }

    Kirigami.FormLayout {
        RowLayout {
            Layout.preferredWidth: widgetCards.width
            Layout.minimumWidth: 100
            Button {
                text: i18n("Restore default blacklist")
                icon.name: "kt-restore-defaults-symbolic"
                onClicked: {
                    cfg_blacklist = plasmoid.configuration.blacklistDefault
                    initWidgets()
                    updateWidgetsModel()
                }
                Layout.fillWidth: true
            }
            KCM.ContextualHelpButton {
                toolTipText: "Since version <strong>0.5.0</strong> partial widget names e.g. <i>spacer</i> are no longer allowed.<br><br>If widgets are not blacklisted properly you can use this option to restore the default which has the correct format"
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
                        }
                        ColumnLayout {
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
                        Button {
                            id: checkBtn
                            checkable: true
                            checked: model.enabled
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

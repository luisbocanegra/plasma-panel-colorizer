pragma ComponentBehavior: Bound
import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.iconthemes as KIconThemes
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import "components" as Components
import "code/statusNotifierItemIconRules.js" as SNIIconRules

KCM.ScrollViewKCM {
    id: root
    padding: 0
    headerPaddingEnabled: false
    implicitWidth: Kirigami.Units.gridUnit * 15
    implicitHeight: Kirigami.Units.gridUnit * 30
    property alias cfg_systemTrayIconsReplacementEnabled: systemTrayIconsReplacementEnabled.checked
    property string cfg_systemTrayIconUserReplacements
    property alias cfg_systemTrayIconBuiltinReplacementsEnabled: systemTrayIconBuiltinReplacementsEnabled.checked
    property alias cfg_logSystemTrayIconChanges: logSystemTrayIconChanges.checked
    property bool isLoading: trayIconReplacementsModel.isLoading
    property alias cfg_isEnabled: headerComponent.isEnabled
    property var panelColorizer: null

    property string configDir: StandardPaths.writableLocation(StandardPaths.HomeLocation).toString().substring(7) + "/.config/panel-colorizer/"
    property string importCmd: "cat '" + configDir + "trayIconReplacements.json'"
    property string crateConfigDirCmd: "mkdir -p " + configDir

    readonly property Kirigami.Action addContextMenuAction: Kirigami.Action {
        icon.name: "list-add-symbolic"
        text: i18n("Add new")
        onTriggered: trayIconReplacementsModel.addItem()
    }
    readonly property Kirigami.Action clearAction: Kirigami.Action {
        icon.name: "edit-delete-symbolic"
        text: i18n("Remove all")
        onTriggered: trayIconReplacementsModel.clear()
    }
    readonly property Kirigami.Action sortAction: Kirigami.Action {
        icon.name: "view-sort-ascending-name"
        text: i18n("Sort")
        onTriggered: trayIconReplacementsModel.sortRules()
    }

    function updateConfig() {
        let rules = new Array();
        for (let i = 0; i < trayIconReplacementsModel.model.count; i++) {
            let item = trayIconReplacementsModel.model.get(i);
            rules.push({
                "description": item.description,
                "match": item.match,
                "icon": item.icon,
                "enabled": item.enabled
            });
        }
        cfg_systemTrayIconUserReplacements = JSON.stringify(rules);
    }

    TrayIconReplacementsModel {
        id: trayIconReplacementsModel
        onUpdated: () => {
            root.updateConfig();
        }
    }

    TrayIconReplacementsModel {
        id: trayIconBuiltinReplacementsModel
    }

    Component.onCompleted: {
        trayIconReplacementsModel.initModel(cfg_systemTrayIconUserReplacements);
        trayIconBuiltinReplacementsModel.initModel(JSON.stringify(SNIIconRules.rules));
        try {
            panelColorizer = Qt.createQmlObject("import org.kde.plasma.panelcolorizer 1.0; PanelColorizer { id: panelColorizer }", root);
        } catch (e) {
            console.warn("QML Plugin org.kde.plasma.panelcolorizer not found.");
        }
    }

    RunCommand {
        id: runCommand
    }

    Connections {
        function onExited(cmd, exitCode, exitStatus, stdout, stderr) {
            if (exitCode !== 0)
                return;

            if (cmd.startsWith("cat")) {
                const content = stdout.trim();
                try {
                    trayIconReplacementsModel.initModel(content);
                } catch (e) {
                    console.error(e);
                }
            }
        }

        target: runCommand
    }

    header: ColumnLayout {
        spacing: 0
        Components.Header {
            id: headerComponent
        }
        Kirigami.Separator {
            Layout.fillWidth: true
        }
        Kirigami.InlineMessage {
            Layout.fillWidth: true
            text: i18n("Replace System Tray icons with icons from the current icon theme or a local file. The built-in rules icons are part of <a href=\"https://github.com/PapirusDevelopmentTeam/papirus-icon-theme\">Papirus icon theme</a>.")
            visible: true
            type: Kirigami.MessageType.Information
            spacing: 0
            Layout.margins: Kirigami.Units.mediumSpacing
        }
        Kirigami.InlineMessage {
            Layout.fillWidth: true
            text: i18n("C++ plugin not found, this feature will not work. Install the plugin and reboot or restart plasmashell to be able to use it <a href=\"https://github.com/luisbocanegra/plasma-panel-colorizer?tab=readme-ov-file#manually\">Install instructions</a>.")
            visible: root.panelColorizer === null
            type: Kirigami.MessageType.Error
            spacing: 0
            Layout.margins: Kirigami.Units.mediumSpacing
        }
        Kirigami.InlineMessage {
            Layout.fillWidth: true
            text: i18n("The installed version of the C++ plugin doesn't support this feature, update the plugin and reboot or restart plasmashell to be able to use it <a href=\"https://github.com/luisbocanegra/plasma-panel-colorizer?tab=readme-ov-file#manually\">Install instructions</a>.")
            visible: root.panelColorizer && (typeof root.panelColorizer?.getIconHash !== "function")
            type: Kirigami.MessageType.Error
            spacing: 0
            Layout.margins: Kirigami.Units.mediumSpacing
        }
        Kirigami.FormLayout {
            enabled: root.cfg_isEnabled
            RowLayout {
                Kirigami.FormData.label: i18n("Enable")
                CheckBox {
                    id: systemTrayIconsReplacementEnabled
                }
            }
            RowLayout {
                Kirigami.FormData.label: i18n("Log icon changes:")
                CheckBox {
                    id: logSystemTrayIconChanges
                }
                Kirigami.ContextualHelpButton {
                    toolTipText: i18n("Icon hashes will be printed to the system log")
                }
            }

            RowLayout {
                enabled: root.cfg_systemTrayIconsReplacementEnabled
                Kirigami.FormData.label: i18n("Enable built-in rules:")
                CheckBox {
                    id: systemTrayIconBuiltinReplacementsEnabled
                }
                ToolButton {
                    id: showBuiltInRules
                    text: i18n("Show")
                    checkable: true
                }
            }
        }

        ToolButton {
            id: showHowToLabel
            text: i18n("How to use")
            checkable: true
            Layout.alignment: Qt.AlignHCenter
            Layout.margins: Kirigami.Units.mediumSpacing
        }
        Label {
            text: "1. Enable <b>Log icon changes</b> above<br>2. Run <b>journalctl -f</b> from terminal<br>3. Hover the System tray entry or trigger an icon change<br>4. Copy the icon SHA1 (long string of numbers and letters), title or name <br>5. Add a new rule with the SHA1/title/name and your icon name or icon file"
            wrapMode: Label.WordWrap
            font.features: {
                "tnum": 1
            }
            visible: showHowToLabel.checked
            Layout.margins: Kirigami.Units.mediumSpacing
            Layout.fillWidth: true
        }
        Label {
            text: "<b>Note</b>: There are some rules without icon as there was no matching one in Papirus, you can override those with your own icons by copying the rule to <b>User Replacements</b>"
            wrapMode: Label.WordWrap
            visible: showHowToLabel.checked
            Layout.margins: Kirigami.Units.mediumSpacing
            Layout.fillWidth: true
        }
        Label {
            text: "<b>Note</b>: Some applications like Signal are missing accumulated notification icons, contribution of missing icons via GitHub pull request or issue is very welcome, please do so by providing the the description + SHA1/title/name + icon-name from Papirus (panel/status icons only if no matching icon exists, otherwise it can be omitted)</b>"
            wrapMode: Label.WordWrap
            visible: showHowToLabel.checked
            Layout.margins: Kirigami.Units.mediumSpacing
            Layout.fillWidth: true
        }
        Components.SettingImportExport {
            onExportConfirmed: {
                runCommand.run(root.crateConfigDirCmd);
                runCommand.run("echo '" + root.cfg_systemTrayIconUserReplacements + "' > '" + root.configDir + "trayIconReplacements.json'");
            }
            onImportConfirmed: runCommand.run(root.importCmd)
            Layout.margins: Kirigami.Units.mediumSpacing
            enabled: root.cfg_isEnabled && root.cfg_systemTrayIconsReplacementEnabled
        }
    }
    view: ListView {
        id: list
        enabled: root.cfg_isEnabled && root.cfg_systemTrayIconsReplacementEnabled
        model: showBuiltInRules.checked ? trayIconBuiltinReplacementsModel.model : trayIconReplacementsModel.model
        headerPositioning: ListView.OverlayHeader
        header: Kirigami.InlineViewHeader {
            width: list.width
            text: showBuiltInRules.checked ? i18n("Built-in Rules (read only)") : i18n("User Rules")
            actions: {
                if (showBuiltInRules.checked) {
                    return [];
                }
                return [root.sortAction, root.clearAction, root.addContextMenuAction];
            }
        }
        delegate: Item {
            id: itemDelegate
            readonly property var view: ListView.view
            required property string match
            required property string icon
            required property string description
            required property bool enabled
            required property int index
            implicitWidth: ListView.view.width
            implicitHeight: delegate.height
            ItemDelegate {
                id: delegate
                implicitWidth: itemDelegate.implicitWidth
                // There's no need for a list item to ever be selected
                down: false
                highlighted: false
                background: Item {}
                contentItem: RowLayout {
                    spacing: Kirigami.Units.smallSpacing

                    Kirigami.ListItemDragHandle {
                        visible: itemDelegate.view.count > 1
                        listItem: delegate
                        listView: itemDelegate.view
                        onMoveRequested: (oldIndex, newIndex) => {
                            trayIconReplacementsModel.moveItem(oldIndex, newIndex, 1);
                        }
                        enabled: !showBuiltInRules.checked
                    }

                    ToolButton {
                        icon.name: itemDelegate.enabled ? "checkmark-symbolic" : "dialog-close-symbolic"
                        checkable: true
                        checked: itemDelegate.enabled
                        highlighted: itemDelegate.enabled
                        onCheckedChanged: {
                            if (root.isLoading || showBuiltInRules.checked)
                                return;
                            trayIconReplacementsModel.updateItem(itemDelegate.index, "enabled", checked);
                        }
                        Layout.fillHeight: true
                        Layout.preferredWidth: height
                        ToolTip.delay: 1000
                        ToolTip.visible: hovered
                        ToolTip.text: i18n("Whether or not this replacement is enabled")
                        enabled: !showBuiltInRules.checked
                    }

                    TextField {
                        text: itemDelegate.description
                        placeholderText: i18n("Description (optional)")
                        ToolTip.delay: 1000
                        ToolTip.visible: hovered
                        ToolTip.text: i18n("Description")
                        onTextChanged: {
                            if (root.isLoading || showBuiltInRules.checked)
                                return;
                            trayIconReplacementsModel.updateItem(itemDelegate.index, "description", text);
                        }
                        Layout.preferredWidth: 300
                        enabled: itemDelegate.enabled
                        readOnly: showBuiltInRules.checked
                    }

                    TextField {
                        id: matchTextField
                        Layout.fillWidth: true
                        text: itemDelegate.match
                        font.family: "monospace"
                        color: Kirigami.Theme.textColor
                        placeholderText: i18n("SHA1, string or regex to match")
                        ToolTip.delay: 1000
                        ToolTip.visible: hovered
                        ToolTip.text: i18n("Icon SHA1, title or name of the target tray item")
                        onTextChanged: {
                            if (root.isLoading || showBuiltInRules.checked)
                                return;
                            trayIconReplacementsModel.updateItem(itemDelegate.index, "match", text);
                        }
                        enabled: itemDelegate.enabled
                        readOnly: showBuiltInRules.checked
                    }

                    TextField {
                        text: itemDelegate.icon
                        placeholderText: i18n("Custom icon")
                        ToolTip.delay: 1000
                        ToolTip.visible: hovered
                        ToolTip.text: i18n("Icon name or file")
                        onTextChanged: {
                            if (root.isLoading || showBuiltInRules.checked)
                                return;
                            trayIconReplacementsModel.updateItem(itemDelegate.index, "icon", text);
                        }
                        Layout.preferredWidth: 300
                        enabled: itemDelegate.enabled
                        readOnly: showBuiltInRules.checked
                    }

                    ToolButton {
                        id: iconButton
                        hoverEnabled: true
                        ToolTip.delay: Kirigami.Units.toolTipDelay
                        ToolTip.text: i18n("Edit icon")
                        ToolTip.visible: iconButton.hovered && itemDelegate.icon.length > 0
                        enabled: itemDelegate.enabled
                        contentItem: Item {
                            implicitHeight: Kirigami.Units.gridUnit * 2
                            Kirigami.Icon {
                                source: itemDelegate.icon
                                fallback: "unknown"
                                anchors.centerIn: parent
                                implicitHeight: Kirigami.Units.iconSizes.smallMedium
                                implicitWidth: Kirigami.Units.iconSizes.smallMedium
                            }
                        }
                        KIconThemes.IconDialog {
                            id: iconDialog
                            onIconNameChanged: {
                                itemDelegate.icon = iconName;
                            }
                        }

                        onPressed: {
                            if (showBuiltInRules.checked) {
                                return;
                            }
                            if (iconMenu.opened) {
                                iconMenu.close();
                            } else {
                                iconMenu.open();
                            }
                        }

                        Menu {
                            id: iconMenu

                            // Appear below the button
                            y: parent.height

                            MenuItem {
                                text: i18nc("@item:inmenu Open icon chooser dialog", "Choose…")
                                icon.name: "document-open-folder"
                                onClicked: iconDialog.open()
                            }
                            MenuItem {
                                text: i18nc("@action:inmenu", "Remove icon")
                                icon.name: "delete"
                                enabled: itemDelegate.icon !== ""
                                onClicked: itemDelegate.icon = ""
                            }
                        }
                    }

                    Button {
                        id: copyRuleButton
                        icon.name: showBuiltInRules.checked ? "edit-copy-symbolic" : "edit-duplicate-symbolic"
                        onClicked: {
                            let rule = {
                                "description": itemDelegate.description,
                                "match": itemDelegate.match,
                                "icon": itemDelegate.icon,
                                "enabled": itemDelegate.enabled
                            };
                            if (showBuiltInRules.checked) {
                                trayIconReplacementsModel.appendRule(rule);
                            } else {
                                trayIconReplacementsModel.insertRule(itemDelegate.index + 1, rule);
                            }
                        }
                        hoverEnabled: true
                        ToolTip.delay: Kirigami.Units.toolTipDelay
                        ToolTip.text: showBuiltInRules.checked ? i18n("Copy to User Rules") : i18n("Copy rule")
                        ToolTip.visible: copyRuleButton.hovered
                    }

                    Button {
                        icon.name: "delete-symbolic"
                        onClicked: trayIconReplacementsModel.removeItem(itemDelegate.index)
                        enabled: !showBuiltInRules.checked
                    }
                }
            }
        }
    }
}

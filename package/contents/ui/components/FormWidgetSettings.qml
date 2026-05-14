import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import "../code/enum.js" as Enum
import "../code/utils.js" as Utils
import "../code/version.js" as VersionUtil
import ".."

ColumnLayout {
    id: root
    spacing: 0

    property bool isSection: true
    // wether read from the string or existing config object
    property bool handleString: false
    // key to extract config from
    property string elementName
    property string elementFriendlyName

    property int elementState: Enum.WidgetStates.Normal
    property string stateFriendlyName

    // internal config objects to be sent, both string and json
    property string configString: "{}"
    property var config: handleString ? JSON.parse(configString) : undefined

    property bool showFontConfig: elementName === "" || elementName === "widgets"

    readonly property bool vertical: {
        if (Plasmoid.formFactor == PlasmaCore.Types.Vertical) {
            return true;
        }
        return false;
    }

    property string stateName: {
        if (elementState === Enum.WidgetStates.Normal) {
            return "normal";
        } else if (elementState === Enum.WidgetStates.Busy) {
            return "busy";
        } else if (elementState === Enum.WidgetStates.NeedsAttention) {
            return "needsAttention";
        } else if (elementState === Enum.WidgetStates.Hovered) {
            return "hovered";
        } else if (elementState === Enum.WidgetStates.Expanded) {
            return "expanded";
        }
        return "";
    }

    signal reloaded

    function reload() {
        if (!ready) {
            return;
        }
        console.error("FormWidgetSettings reload()");
        configLocal = JSON.parse(JSON.stringify(elementName ? config[elementName][stateName] : config[stateName]));
        reloaded();
    }

    onStateNameChanged: reload()
    onElementNameChanged: reload()

    property var configLocal: {
        return elementName ? config[elementName][stateName] : config[stateName];
    }

    property alias isEnabled: isEnabled.checked
    property int currentTab
    property bool ready: false
    property bool showBlurMessage: false
    property var followVisbility: {
        "background": {
            "panel": false,
            "widget": false,
            "tray": false
        },
        "foreground": {
            "panel": false,
            "widget": false,
            "tray": false
        }
    }

    property var plasmaVersion: new VersionUtil.Version("999.999.999") // to assume latest
    RunCommand {
        id: runCommand
        onExited: (cmd, exitCode, exitStatus, stdout, stderr) => {
            if (exitCode !== 0) {
                console.error(cmd, exitCode, exitStatus, stdout, stderr);
                return;
            }
            if (stdout) {
                const parts = stdout.split(" ");
                if (parts.length < 2)
                    return;
                root.plasmaVersion = new VersionUtil.Version(parts[1]);
            }
        }
    }

    signal updateConfigString(string configString, var config)
    signal tabChanged(int currentTab)

    Timer {
        id: delayedUpdateTimer
        interval: 100
        repeat: false
        onTriggered: {
            Qt.callLater(() => {
                if (elementName) {
                    config[elementName][stateName] = configLocal;
                } else {
                    config[stateName] = configLocal;
                }
                updateConfigString(JSON.stringify(config, null, null), config);
            });
        }
    }

    function updateConfig() {
        if (!ready) {
            return;
        }
        if (delayedUpdateTimer.running) {
            delayedUpdateTimer.restart();
        } else {
            delayedUpdateTimer.start();
        }
    }

    onCurrentTabChanged: {
        tabChanged(currentTab);
    }
    Component.onCompleted: {
        Utils.delay(50, () => ready = true, root);
        runCommand.exec('plasmashell --version');
    }

    Kirigami.FormLayout {
        id: mainForm
        // required to align with parent form
        property alias formLayout: root
        Layout.fillWidth: true

        RowLayout {
            Kirigami.FormData.label: i18n("Native panel:")
            visible: elementName === "panel" && root.elementState === Enum.WidgetStates.Normal
            CheckBox {
                id: nativePanelBackgroundCheckbox
                text: i18n("Background")
                checked: config.nativePanel.background.enabled
                onCheckedChanged: {
                    config.nativePanel.background.enabled = checked;
                    updateConfig();
                }
            }

            Kirigami.ContextualHelpButton {
                toolTipText: i18n("Disable to make panel fully transparent, removes contrast and blur effects.")
            }
        }
        Label {
            visible: (!!!root.config?.nativePanel?.background?.enabled) && elementName === "panel" && root.elementState === Enum.WidgetStates.Normal
            text: i18n("⚠️ Disabling this breaks the panel clickable area and applet dialogs positioning when the panel is in floating mode! See <a href=\"%1\">#80</a>.", "https://github.com/luisbocanegra/plasma-panel-colorizer/issues/80")
            onLinkActivated: link => Qt.openUrlExternally(link)
            font: Kirigami.Theme.smallFont
            color: Kirigami.Theme.neutralTextColor
            wrapMode: Label.Wrap
            Layout.maximumWidth: 400
            Layout.alignment: Qt.AlignTop
            HoverHandler {
                cursorShape: Qt.PointingHandCursor
            }
        }
        RowLayout {
            visible: elementName === "panel" && root.elementState === Enum.WidgetStates.Normal
            CheckBox {
                id: nativePanelBackgroundShadowCheckbox
                text: i18n("Shadow")
                enabled: nativePanelBackgroundCheckbox.checked

                checked: config.nativePanel.background.shadow
                onCheckedChanged: {
                    config.nativePanel.background.shadow = checked;
                    updateConfig();
                }
            }
            Kirigami.ContextualHelpButton {
                toolTipText: i18n("The shadow from the Plasma theme")
            }
        }

        DoubleSpinBoxCompat {
            id: widgetOpacity
            visible: root.elementName !== "panel"
            Kirigami.FormData.label: i18n("Opacity:")
            from: 0 * multiplier
            to: 1 * multiplier
            value: (root.configLocal.opacity ?? 0) * multiplier
            onValueModified: {
                root.configLocal.opacity = value / widgetOpacity.multiplier;
                root.updateConfig();
            }
        }

        RowLayout {
            visible: elementName === "panel" && root.elementState === Enum.WidgetStates.Normal
            Label {
                text: i18n("Opacity:")
            }
            DoubleSpinBoxCompat {
                id: opacitySpinbox
                enabled: nativePanelBackgroundCheckbox.checked
                from: 0 * multiplier
                to: 1 * multiplier
                value: (config.nativePanel.background.opacity ?? 0) * multiplier
                onValueModified: {
                    config.nativePanel.background.opacity = value / opacitySpinbox.multiplier;
                    updateConfig();
                }
            }
            Kirigami.ContextualHelpButton {
                toolTipText: i18n("Set to 0 to keep the mask required for custom background blur.")
            }
        }

        Item {
            // spacing between controls
            visible: root.elementName === "panel" && root.elementState === Enum.WidgetStates.Normal
            height: 0.5 * Kirigami.Units.gridUnit
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Floating applets:")
            CheckBox {
                id: floatingDialogsEnabledCheckbox
                text: i18n("Allow changes (Plasma 6.4.0 and later)")
                checked: config.nativePanel.floatingDialogsAllowOverride
                onCheckedChanged: {
                    config.nativePanel.floatingDialogsAllowOverride = checked;
                    updateConfig();
                }
            }
            Kirigami.ContextualHelpButton {
                toolTipText: i18n("Since version 6.4.0, Plasma now has a built-in <b>Floating panel and applets</b> option, enabling this overrides that option.\n⚠️Changing <b>Floating</b> from the panel configuration will not work with this is enabled!")
            }
            visible: root.plasmaVersion.isGreaterThan("6.3.5") && elementName === "panel" && root.elementState === Enum.WidgetStates.Normal
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Wide expand button:")
            CheckBox {
                checked: config.trayWidgets.wideTrayArrow
                onCheckedChanged: {
                    config.trayWidgets.wideTrayArrow = checked;
                    updateConfig();
                }
            }
            Kirigami.ContextualHelpButton {
                toolTipText: i18n("Make the System Tray expand button use the same size as the other tray items")
            }
            visible: elementName === "trayWidgets"
        }

        RowLayout {
            visible: root.elementName === "trayWidgets"
            Kirigami.FormData.label: root.vertical ? i18n("Custom cell height:") : i18n("Custom cell width:")
            CheckBox {
                checked: root.config.trayWidgets.customCellSizeEnabled
                onCheckedChanged: {
                    root.config.trayWidgets.customCellSizeEnabled = checked;
                    root.updateConfig();
                }
            }

            SpinBox {
                id: trayCellSize
                from: 20
                to: 64
                stepSize: 2
                value: root.config.trayWidgets.customCellSize
                onValueModified: {
                    root.config.trayWidgets.customCellSize = value;
                    root.updateConfig();
                }
                enabled: root.config.trayWidgets.customCellSizeEnabled
            }
        }

        CheckBox {
            text: i18n("Force floating applets")
            checked: config.nativePanel.floatingDialogs
            onCheckedChanged: {
                config.nativePanel.floatingDialogs = checked;
                updateConfig();
            }
            visible: elementName === "panel" && root.elementState === Enum.WidgetStates.Normal && (floatingDialogsEnabledCheckbox.checked || root.plasmaVersion.isLowerThan("6.4.0"))
        }

        ColumnLayout {
            Kirigami.FormData.label: i18n("Floating panel:")
            Kirigami.FormData.buddyFor: flattenOnDeFloatCheckbox
            Kirigami.FormData.labelAlignment: Qt.AlignTop
            spacing: Kirigami.Units.smallSpacing
            visible: root.elementName === "panel" && root.elementState === Enum.WidgetStates.Normal
            CheckBox {
                id: flattenOnDeFloatCheckbox
                text: i18n("Remove custom background rounded corners and borders on screen edge when panel is not floating")
                checked: root.configLocal.flattenOnDeFloat
                onCheckedChanged: {
                    root.configLocal.flattenOnDeFloat = checked;
                    root.updateConfig();
                }
                Layout.maximumWidth: 400
            }

            CheckBox {
                text: i18n("Resize panel length when panel enters/exits floating state (instead of just moving)")
                checked: root.config.nativePanel.fillAreaOnDeFloat
                onCheckedChanged: {
                    root.config.nativePanel.fillAreaOnDeFloat = checked;
                    root.updateConfig();
                }
                Layout.maximumWidth: 400
                visible: root.plasmaVersion.isGreaterThan("6.3.5") && root.elementName === "panel" && root.elementState === Enum.WidgetStates.Normal
            }
        }

        CheckBox {
            Kirigami.FormData.label: i18n("Hide panel:")
            text: i18n("When there are no widgets visible")
            checked: root.config.nativePanel.hideWhenNoWidgetsAreVisible
            onCheckedChanged: {
                root.config.nativePanel.hideWhenNoWidgetsAreVisible = checked;
                root.updateConfig();
            }
            visible: root.elementName === "panel" && root.elementState === Enum.WidgetStates.Normal
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Customization")
            Layout.fillWidth: true
        }

        RowLayout {
            Kirigami.FormData.label: i18n("State:")
            ComboBox {
                id: targetState
                textRole: "name"
                valueRole: "value"
                onActivated: {
                    if (currentValue !== root.elementState && root.ready) {
                        root.elementState = currentValue;
                    }
                }

                currentIndex: {
                    let newValue = indexOfValue(root.elementState);
                    return newValue !== -1 ? newValue : 0;
                }

                onOptionsChanged: {
                    model = options;
                    if (root.ready) {
                        let newValue = indexOfValue(root.elementState);
                        currentIndex = newValue !== -1 ? newValue : 0;
                    }
                }

                property var options: {
                    let options = [
                        {
                            "name": i18n("Normal"),
                            "value": Enum.WidgetStates.Normal
                        },
                        {
                            "name": i18n("Hover"),
                            "value": Enum.WidgetStates.Hovered
                        }
                    ];
                    if (root.elementName !== "panel") {
                        options = options.concat([
                            {
                                "name": i18n("Expanded"),
                                "value": Enum.WidgetStates.Expanded
                            },
                            {
                                "name": i18n("Needs attention"),
                                "value": Enum.WidgetStates.NeedsAttention
                            },
                            {
                                "name": i18n("Busy"),
                                "value": Enum.WidgetStates.Busy
                            }
                        ]);
                    }
                    return options;
                }
                model: options
            }
            Kirigami.ContextualHelpButton {
                toolTipText: i18n("Change element appearance based on their state, configuration is stacked on top of the current appearance")
            }
        }

        ColumnLayout {
            WidgetStateHint {
                widgetState: targetState.currentIndex
            }
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Enable:")
            CheckBox {
                id: isEnabled
                checked: configLocal.enabled
                onCheckedChanged: {
                    configLocal.enabled = checked;
                    updateConfig();
                }
            }
        }

        Item {
            // spacing between controls
            height: Kirigami.Units.gridUnit
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Blur custom background (Beta)")
            CheckBox {
                id: blurCheckbox
                enabled: isEnabled.checked

                checked: configLocal.blurBehind
                onCheckedChanged: {
                    configLocal.blurBehind = checked;
                    updateConfig();
                }
            }

            Kirigami.ContextualHelpButton {
                toolTipText: i18n("Draw a custom blur mask behind the custom background(s).<br><strong>Native panel background must be enabled with opacity of 0 for this to work as intended.</strong>")
            }
        }

        Label {
            visible: !plasmoid.configuration.pluginFound
            text: i18n("C++ plugin not found, this feature will not work. Install the plugin and reboot or restart plasmashell to be able to use it. See <a href=\"%1\">install instructions</a>.", "https://github.com/luisbocanegra/plasma-panel-colorizer?tab=readme-ov-file#manually")
            onLinkActivated: link => Qt.openUrlExternally(link)
            font: Kirigami.Theme.smallFont
            wrapMode: Label.Wrap
            Layout.maximumWidth: 400
            Layout.alignment: Qt.AlignTop
            HoverHandler {
                cursorShape: Qt.PointingHandCursor
            }
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Clipping (Experimental)")
            visible: root.showFontConfig
            CheckBox {
                enabled: isEnabled.checked

                checked: root.configLocal.backgroundClipping
                onCheckedChanged: {
                    root.configLocal.backgroundClipping = checked;
                    root.updateConfig();
                }
            }
        }

        Label {
            visible: root.showFontConfig
            text: i18n("Clip the widget content to the custom background radius.<br>Clipping widgets against the panel is not supported yet, see <a href=\"%1\">#275</a>.", "https://github.com/luisbocanegra/plasma-panel-colorizer/issues/275")
            onLinkActivated: link => Qt.openUrlExternally(link)
            font: Kirigami.Theme.smallFont
            wrapMode: Label.Wrap
            Layout.maximumWidth: 400
            Layout.alignment: Qt.AlignTop
            HoverHandler {
                cursorShape: Qt.PointingHandCursor
            }
        }
        Component.onCompleted: function () {
            if (typeof appearanceRoot !== "undefined") {
                twinFormLayouts.push(appearanceRoot.parentLayout);
            }
        }
    }

    Kirigami.NavigationTabBar {
        enabled: root.isEnabled
        Layout.maximumWidth: parentLayout.width
        Layout.alignment: Qt.AlignHCenter
        maximumContentWidth: {
            const minDelegateWidth = Kirigami.Units.gridUnit * 6;
            // Always have at least the width of 5 items, so that small amounts of actions look natural.
            return minDelegateWidth * Math.max(visibleActions.length, 5);
        }
        actions: [
            Kirigami.Action {
                icon.name: "color-picker"
                text: i18n("Color")
                checked: currentTab === 0
                onTriggered: currentTab = 0
            },
            Kirigami.Action {
                icon.name: "rectangle-shape-symbolic"
                text: i18n("Shape")
                checked: currentTab === 1
                onTriggered: currentTab = 1
            },
            Kirigami.Action {
                icon.name: "bordertool-symbolic"
                text: i18n("Border")
                checked: currentTab === 2
                onTriggered: currentTab = 2
            },
            Kirigami.Action {
                icon.name: "kstars_horizon-symbolic"
                text: i18n("Shadow")
                checked: currentTab === 3
                onTriggered: currentTab = 3
            },
            Kirigami.Action {
                icon.name: "font-symbolic"
                text: i18n("Font")
                checked: currentTab === 4
                onTriggered: currentTab = 4
                visible: root.elementName === "" || root.elementName === "widgets"
            }
        ]
    }

    Kirigami.FormLayout {
        // required to align with parent form
        property alias formLayout: root
        twinFormLayouts: parentLayout
        Layout.fillWidth: true

        enabled: root.isEnabled

        RowLayout {
            Kirigami.FormData.label: i18n("Spacing:")
            visible: elementName === "widgets" && currentTab === 1 && root.elementState === Enum.WidgetStates.Normal

            SpinBox {
                id: spacingCheckbox

                value: configLocal.spacing || 0
                from: 0
                to: 999
                onValueModified: {
                    if (!enabled || !root.ready)
                        return;

                    configLocal.spacing = value;
                    updateConfig();
                }
            }

            Button {
                visible: spacingCheckbox.value % 2 !== 0 && spacingCheckbox.visible
                icon.name: "dialog-warning-symbolic"
                ToolTip.text: i18n("<strong>Odd spacing</strong> values will be automatically converted to <strong>evens</strong> if <strong>Widget Islands</strong> feature is used.")
                highlighted: true
                hoverEnabled: true
                ToolTip.visible: hovered
            }
        }

        CheckBox {
            id: customFont
            Kirigami.FormData.label: i18n("Custom font:")
            text: i18n("Enable")
            checked: root.configLocal.fontConfig.enabled
            onCheckedChanged: {
                if (!root.ready)
                    return;
                root.configLocal.fontConfig.enabled = checked;
                root.updateConfig();
            }
            visible: (root.showFontConfig) && root.currentTab === 4
        }
        Label {
            visible: (root.showFontConfig) && root.currentTab === 4
            text: i18n("A plasmashell restart is required to restore the original values after disabling any font setting. <a href=\"#\">Restart now</a>.")
            onLinkActivated: {
                runCommand.exec("systemctl restart --user plasma-plasmashell");
            }
            font: Kirigami.Theme.smallFont
            color: Kirigami.Theme.disabledTextColor
            wrapMode: Label.Wrap
            Layout.maximumWidth: 400
            HoverHandler {
                cursorShape: Qt.PointingHandCursor
            }
        }
        // preview
        TextArea {
            visible: (root.showFontConfig) && root.currentTab === 4
            text: i18n("12345678900\nABCDEFGHIJKLMNOPQRSTUVWXYZ\nabcdefghijklmnopqrstuvwxyz")
            Kirigami.SpellCheck.enabled: false
            function reload() {
                font.family = root.configLocal.fontConfig.font.familyOverride ? root.configLocal.fontConfig.font.family : Kirigami.Theme.defaultFont.family;
                font.italic = root.configLocal.fontConfig.font.italicOverride ? root.configLocal.fontConfig.font.italic : Kirigami.Theme.defaultFont.italic;
                font.underline = root.configLocal.fontConfig.font.underlineOverride ? root.configLocal.fontConfig.font.underline : Kirigami.Theme.defaultFont.underline;
                font.weight = root.configLocal.fontConfig.font.weightOverride ? root.configLocal.fontConfig.font.weight : Kirigami.Theme.defaultFont.weight;
                font.pointSize = root.configLocal.fontConfig.font.pointSizeOverride ? root.configLocal.fontConfig.font.pointSize : Kirigami.Theme.defaultFont.pointSize;
            }
            Component.onCompleted: {
                root.updateConfigString.connect(() => {
                    reload();
                });
            }
        }
        RowLayout {
            Kirigami.FormData.label: i18n("Font family:")
            visible: (root.showFontConfig) && root.currentTab === 4
            enabled: customFont.checked
            CheckBox {
                id: familyOverride
                text: i18n("Override")
                checked: root.configLocal.fontConfig.font.familyOverride
                onCheckedChanged: {
                    if (!root.ready)
                        return;
                    root.configLocal.fontConfig.font.familyOverride = checked;
                    root.updateConfig();
                }
            }
        }

        Component {
            id: fontFamilyPicker
            FontFamilyChooser {
                Layout.fillWidth: true
                height: 200
                enabled: familyOverride.checked
                selectedFont: root.configLocal.fontConfig.font.family
                onFontSelected: font => {
                    if (!root.ready)
                        return;
                    root.configLocal.fontConfig.font.family = font;
                    root.updateConfig();
                }
            }
        }

        Loader {
            sourceComponent: fontFamilyPicker
            active: (root.showFontConfig) && root.currentTab === 4
            Layout.fillWidth: true
            visible: active
            onLoaded: {
                item.selectedFont = root.configLocal.fontConfig.font.family;
                item.fontSelected.connect(function (font) {
                    if (!root.ready)
                        return;
                    root.configLocal.fontConfig.font.family = font;
                    root.updateConfig();
                });
            }
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Italic:")
            visible: (root.showFontConfig) && root.currentTab === 4
            enabled: customFont.checked
            CheckBox {
                id: italicOverride
                text: i18n("Override")
                checked: root.configLocal.fontConfig.font.italicOverride
                onCheckedChanged: {
                    if (!root.ready)
                        return;
                    root.configLocal.fontConfig.font.italicOverride = checked;
                    root.updateConfig();
                }
            }
            CheckBox {
                text: i18n("Enable")
                checked: root.configLocal.fontConfig.font.italic
                onCheckedChanged: {
                    if (!root.ready)
                        return;
                    root.configLocal.fontConfig.font.italic = checked;
                    root.updateConfig();
                }
                enabled: italicOverride.checked
            }
        }
        RowLayout {
            Kirigami.FormData.label: i18n("Underline:")
            visible: (root.showFontConfig) && root.currentTab === 4
            enabled: customFont.checked
            CheckBox {
                id: underlineOverride
                text: i18n("Override")
                checked: root.configLocal.fontConfig.font.underlineOverride
                onCheckedChanged: {
                    if (!root.ready)
                        return;
                    root.configLocal.fontConfig.font.underlineOverride = checked;
                    root.updateConfig();
                }
            }
            CheckBox {
                text: i18n("Enable")
                checked: root.configLocal.fontConfig.font.underline
                onCheckedChanged: {
                    if (!root.ready)
                        return;
                    root.configLocal.fontConfig.font.underline = checked;
                    root.updateConfig();
                }
                enabled: underlineOverride.checked
            }
        }
        RowLayout {
            Kirigami.FormData.label: i18n("Font weight:")
            visible: (root.showFontConfig) && root.currentTab === 4
            enabled: customFont.checked
            CheckBox {
                id: weightOverride
                text: i18n("Override")
                checked: root.configLocal.fontConfig.font.weightOverride
                onCheckedChanged: {
                    if (!root.ready)
                        return;
                    root.configLocal.fontConfig.font.weightOverride = checked;
                    root.updateConfig();
                }
            }
            SpinBox {
                from: 100
                to: 1000
                stepSize: 100
                value: root.configLocal.fontConfig.font.weight
                onValueChanged: {
                    if (!root.ready)
                        return;
                    root.configLocal.fontConfig.font.weight = value;
                    root.updateConfig();
                }
                enabled: weightOverride.checked
            }
        }
        RowLayout {
            Kirigami.FormData.label: i18n("Font size:")
            visible: (root.showFontConfig) && root.currentTab === 4
            enabled: customFont.checked
            CheckBox {
                id: pointSizeOverride
                text: i18n("Override")
                checked: root.configLocal.fontConfig.font.pointSizeOverride
                onCheckedChanged: {
                    if (!root.ready)
                        return;
                    root.configLocal.fontConfig.font.pointSizeOverride = checked;
                    root.updateConfig();
                }
            }
            SpinBox {
                from: 1
                to: 1000
                stepSize: 1
                value: root.configLocal.fontConfig.font.pointSize
                onValueChanged: {
                    if (!root.ready)
                        return;
                    root.configLocal.fontConfig.font.pointSize = value;
                    root.updateConfig();
                }
                enabled: pointSizeOverride.checked
            }
        }
        Item {
            // spacing between controls
            visible: (root.showFontConfig)
            height: 0.5 * Kirigami.Units.gridUnit
        }
    }

    FormColors {
        twinFormLayouts: [mainForm]
        enabled: root.isEnabled
        visible: currentTab === 0
        config: root.configLocal.backgroundColor
        onUpdateConfigString: (newString, newConfig) => {
            if (!root.ready)
                return;
            root.configLocal.backgroundColor = newConfig;
            root.updateConfig();
        }
        followOptions: followVisbility.background
        sectionName: i18n("Background Color")
        multiColor: elementName !== "panel"
        supportsGradient: true
        supportsImage: true
    }

    FormColors {
        twinFormLayouts: [mainForm]
        enabled: root.isEnabled
        // the panel does not support foreground customization
        visible: currentTab === 0 && elementName !== "panel"
        config: root.configLocal.foregroundColor
        isSection: true
        onUpdateConfigString: (newString, newConfig) => {
            if (!root.ready)
                return;
            root.configLocal.foregroundColor = newConfig;
            root.updateConfig();
        }
        followOptions: followVisbility.foreground
        sectionName: i18n("Foreground Color")
    }

    FormShape {
        twinFormLayouts: [mainForm]
        enabled: root.isEnabled
        visible: currentTab === 1
        config: root.configLocal
        onUpdateConfigString: (newString, newConfig) => {
            if (!root.ready)
                return;
            root.configLocal = newConfig;
            root.updateConfig();
        }
        elementName: root.elementName
    }

    FormPadding {
        twinFormLayouts: [mainForm]
        enabled: root.isEnabled
        visible: currentTab === 1 && elementName === "panel"
        config: root.configLocal
        onUpdateConfigString: (newString, newConfig) => {
            if (!root.ready)
                return;
            root.configLocal = newConfig;
            root.updateConfig();
        }
    }

    FormBorder {
        twinFormLayouts: [mainForm]
        isSection: true
        sectionName: i18n("Primary Border")
        enabled: root.isEnabled
        visible: currentTab === 2
        config: root.configLocal.border
        onUpdateConfigString: (newString, newConfig) => {
            if (!root.ready)
                return;
            root.configLocal.border = newConfig;
            root.updateConfig();
        }
        elementName: root.elementName
    }

    FormColors {
        twinFormLayouts: [mainForm]
        isSection: false
        enabled: root.isEnabled
        visible: currentTab === 2
        config: root.configLocal.border.color
        onUpdateConfigString: (newString, newConfig) => {
            if (!root.ready)
                return;
            root.configLocal.border.color = newConfig;
            root.updateConfig();
        }
        followOptions: followVisbility.foreground
    }

    FormBorder {
        twinFormLayouts: [mainForm]
        isSection: true
        sectionName: i18n("Secondary Border")
        enabled: root.isEnabled
        visible: currentTab === 2
        config: root.configLocal.borderSecondary
        onUpdateConfigString: (newString, newConfig) => {
            if (!root.ready)
                return;
            root.configLocal.borderSecondary = newConfig;
            root.updateConfig();
        }
        elementName: root.elementName
    }

    FormColors {
        twinFormLayouts: [mainForm]
        isSection: false
        enabled: root.isEnabled
        visible: currentTab === 2
        config: root.configLocal.borderSecondary.color
        onUpdateConfigString: (newString, newConfig) => {
            if (!root.ready)
                return;
            root.configLocal.borderSecondary.color = newConfig;
            root.updateConfig();
        }
        followOptions: followVisbility.foreground
    }

    FormShadow {
        twinFormLayouts: [mainForm]
        enabled: root.isEnabled
        visible: currentTab === 3
        config: root.configLocal.shadow.background
        onUpdateConfigString: (newString, newConfig) => {
            if (!root.ready)
                return;
            root.configLocal.shadow.background = newConfig;
            root.updateConfig();
        }
        sectionName: i18n("Background Shadow")
    }

    FormColors {
        twinFormLayouts: [mainForm]
        enabled: root.isEnabled
        visible: currentTab === 3
        config: root.configLocal.shadow.background.color
        onUpdateConfigString: (newString, newConfig) => {
            if (!root.ready)
                return;
            root.configLocal.shadow.background.color = newConfig;
            root.updateConfig();
        }
        isSection: false
        followOptions: followVisbility.foreground
        sectionName: i18n("Background Shadow Color")
    }

    FormShadow {
        twinFormLayouts: [mainForm]
        enabled: root.isEnabled
        visible: currentTab === 3 && elementName !== "panel"
        config: root.configLocal.shadow.foreground
        onUpdateConfigString: (newString, newConfig) => {
            if (!root.ready)
                return;
            root.configLocal.shadow.foreground = newConfig;
            root.updateConfig();
        }
        sectionName: i18n("Foreground Shadow")
    }

    FormColors {
        twinFormLayouts: [mainForm]
        enabled: root.isEnabled
        visible: currentTab === 3 && elementName !== "panel"
        config: root.configLocal.shadow.foreground.color
        onUpdateConfigString: (newString, newConfig) => {
            if (!root.ready)
                return;
            root.configLocal.shadow.foreground.color = newConfig;
            root.updateConfig();
        }
        isSection: false
        followOptions: followVisbility.foreground
        sectionName: i18n("Foreground Shadow Color")
    }
}

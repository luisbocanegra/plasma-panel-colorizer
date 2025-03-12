import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: shapeRoot

    // required to align with parent form
    property alias formLayout: shapeRoot
    property bool isSection: true
    // wether read from the string or existing config object
    property bool handleString
    // internal config objects to be sent, both string and json
    property string configString: "{}"
    property var config: handleString ? JSON.parse(configString) : undefined

    signal updateConfigString(string configString, var config)

    function updateConfig() {
        configString = JSON.stringify(config, null, null);
        updateConfigString(configString, config);
    }

    twinFormLayouts: parentLayout
    Layout.fillWidth: true

    Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18n("Radius")
    }

    CheckBox {
        id: radiusEnabledCheckbox

        Kirigami.FormData.label: i18n("Enabled:")
        checked: config.radius.enabled
        onCheckedChanged: {
            config.radius.enabled = checked;
            updateConfig();
        }
        Kirigami.Theme.inherit: false
        text: checked ? "" : i18n("Disabled")

        Binding {
            target: radiusEnabledCheckbox
            property: "Kirigami.Theme.textColor"
            value: shapeRoot.Kirigami.Theme.neutralTextColor
            when: !radiusEnabledCheckbox.checked
        }
    }

    GridLayout {
        columns: 2
        rows: 2
        enabled: radiusEnabledCheckbox.checked

        SpinBox {
            id: topLeftRadius

            value: config.radius.corner.topLeft
            from: 0
            to: 99
            onValueModified: {
                config.radius.corner.topLeft = value;
                updateConfig();
            }
        }

        SpinBox {
            id: topRightRadius

            value: config.radius.corner.topRight
            from: 0
            to: 99
            onValueModified: {
                config.radius.corner.topRight = value;
                updateConfig();
            }
        }

        SpinBox {
            id: bottomLeftRadius

            value: config.radius.corner.bottomLeft
            from: 0
            to: 99
            onValueModified: {
                config.radius.corner.bottomLeft = value;
                updateConfig();
            }
        }

        SpinBox {
            id: bottomRightRadius

            value: config.radius.corner.bottomRight
            from: 0
            to: 99
            onValueModified: {
                config.radius.corner.bottomRight = value;
                updateConfig();
            }
        }
    }

    Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18n("Margin")
    }

    CheckBox {
        id: marginEnabledCheckbox

        Kirigami.FormData.label: i18n("Enabled:")
        checked: config.margin.enabled
        onCheckedChanged: {
            config.margin.enabled = checked;
            updateConfig();
        }
        Kirigami.Theme.inherit: false
        text: checked ? "" : i18n("Disabled")

        Binding {
            target: marginEnabledCheckbox
            property: "Kirigami.Theme.textColor"
            value: shapeRoot.Kirigami.Theme.neutralTextColor
            when: !marginEnabledCheckbox.checked
        }
    }

    GridLayout {
        columns: 3
        rows: 3
        enabled: marginEnabledCheckbox.checked

        SpinBox {
            id: topMargin

            value: config.margin.side.top
            from: -99
            to: 99
            Layout.row: 0
            Layout.column: 1
            onValueModified: {
                config.margin.side.top = value;
                updateConfig();
            }
        }

        SpinBox {
            id: bottomMargin

            value: config.margin.side.bottom
            from: -99
            to: 99
            Layout.row: 2
            Layout.column: 1
            onValueModified: {
                config.margin.side.bottom = value;
                updateConfig();
            }
        }

        SpinBox {
            id: leftMargin

            value: config.margin.side.left
            from: -99
            to: 99
            Layout.row: 1
            Layout.column: 0
            onValueModified: {
                config.margin.side.left = value;
                updateConfig();
            }
        }

        SpinBox {
            id: rightMargin

            value: config.margin.side.right
            from: -99
            to: 99
            Layout.row: 1
            Layout.column: 2
            onValueModified: {
                config.margin.side.right = value;
                updateConfig();
            }
        }
    }
}

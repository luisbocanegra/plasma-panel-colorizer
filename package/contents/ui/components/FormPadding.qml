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
        Kirigami.FormData.isSection: isSection
        Kirigami.FormData.label: i18n("Padding")
    }

    CheckBox {
        id: enabledCheckbox

        Kirigami.FormData.label: i18n("Enabled:")
        checked: config.padding.enabled
        onCheckedChanged: {
            config.padding.enabled = checked;
            updateConfig();
        }
    }

    GridLayout {
        enabled: enabledCheckbox.checked
        columns: 3
        rows: 3
        Kirigami.FormData.label: i18n("Padding:")

        SpinBox {
            id: topMargin

            value: config.padding.side.top
            from: 0
            to: 99
            Layout.row: 0
            Layout.column: 1
            onValueModified: {
                config.padding.side.top = value;
                updateConfig();
            }
        }

        SpinBox {
            id: bottomMargin

            value: config.padding.side.bottom
            from: 0
            to: 99
            Layout.row: 2
            Layout.column: 1
            onValueModified: {
                config.padding.side.bottom = value;
                updateConfig();
            }
        }

        SpinBox {
            id: leftMargin

            value: config.padding.side.left
            from: 0
            to: 99
            Layout.row: 1
            Layout.column: 0
            onValueModified: {
                config.padding.side.left = value;
                updateConfig();
            }
        }

        SpinBox {
            id: rightMargin

            value: config.padding.side.right
            from: 0
            to: 99
            Layout.row: 1
            Layout.column: 2
            onValueModified: {
                config.padding.side.right = value;
                updateConfig();
            }
        }
    }
}

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
        updateConfigString(configString, config);
    }

    twinFormLayouts: parentLayout
    Layout.fillWidth: true

    Kirigami.Separator {
        Kirigami.FormData.isSection: isSection
        Kirigami.FormData.label: i18n("Padding")
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Enabled:")
        CheckBox {
            id: enabledCheckbox

            checked: config.padding.enabled
            onCheckedChanged: {
                config.padding.enabled = checked;
                updateConfig();
            }
        }
        RowLayout {
            enabled: enabledCheckbox.checked
            SpinBox {
                id: leftMargin
                value: config.padding.side.left
                from: 0
                to: 99
                onValueModified: {
                    config.padding.side.left = value;
                    updateConfig();
                }
            }
            ColumnLayout {
                SpinBox {
                    id: topMargin
                    value: config.padding.side.top
                    from: 0
                    to: 99
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
                    onValueModified: {
                        config.padding.side.bottom = value;
                        updateConfig();
                    }
                }
            }

            SpinBox {
                id: rightMargin
                value: config.padding.side.right
                from: 0
                to: 99
                onValueModified: {
                    config.padding.side.right = value;
                    updateConfig();
                }
            }
        }
    }
}

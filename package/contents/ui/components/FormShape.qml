import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: shapeRoot
    // required to align with parent form
    property alias formLayout: shapeRoot
    twinFormLayouts: parentLayout
    Layout.fillWidth: true
    property bool isSection: true
    // wether read from the string or existing config object
    property bool handleString
    // internal config objects to be sent, both string and json
    property string configString: "{}"
    property var config: handleString ? JSON.parse(configString) : undefined
    signal updateConfigString(configString: string, config: var)

    function updateConfig() {
        configString = JSON.stringify(config, null, null)
        updateConfigString(configString, config)
    }

    Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18n("Radius")
    }

    CheckBox {
        Kirigami.FormData.label: i18n("Enabled:")
        id: radiusEnabledCheckbox
        checked: config.radiusEnabled
        onCheckedChanged: {
            config.radiusEnabled = checked
            updateConfig()
        }
    }

    GridLayout {
        columns: 2
        rows: 2
        Kirigami.FormData.label: i18n("Radius:")
        SpinBox {
            id: topLeftRadius
            value: config.radius.topLeft
            from: 0
            to: 99
            onValueModified: {
                config.radius.topLeft = value
                updateConfig()
            }
        }
        SpinBox {
            id: topRightRadius
            value: config.radius.topRight
            from: 0
            to: 99
            onValueModified: {
                config.radius.topRight = value
                updateConfig()
            }
        }
        SpinBox {
            id: bottomLeftRadius
            value: config.radius.bottomLeft
            from: 0
            to: 99
            onValueModified: {
                config.radius.bottomLeft = value
                updateConfig()
            }
        }
        SpinBox {
            id: bottomRightRadius
            value: config.radius.bottomRight
            from: 0
            to: 99
            onValueModified: {
                config.radius.bottomRight = value
                updateConfig()
            }
        }
    }

    Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18n("Margin")
    }

    CheckBox {
        Kirigami.FormData.label: i18n("Enabled:")
        id: marginEnabledCheckbox
        checked: config.marginEnabled
        onCheckedChanged: {
            config.marginEnabled = checked
            updateConfig()
        }
    }

    GridLayout {
        columns: 3
        rows: 3
        Kirigami.FormData.label: i18n("Margin:")
        SpinBox {
            id: topMargin
            value: config.margin.top
            from: 0
            to: 99
            Layout.row: 0
            Layout.column: 1
            onValueModified: {
                config.margin.top = value
                updateConfig()
            }
        }
        SpinBox {
            id: bottomMargin
            value: config.margin.bottom
            from: 0
            to: 99
            Layout.row: 2
            Layout.column: 1
            onValueModified: {
                config.margin.bottom = value
                updateConfig()
            }
        }
        SpinBox {
            id: leftMargin
            value: config.margin.left
            from: 0
            to: 99
            Layout.row: 1
            Layout.column: 0
            onValueModified: {
                config.margin.left = value
                updateConfig()
            }
        }

        SpinBox {
            id: rightMargin
            value: config.margin.right
            from: 0
            to: 99
            Layout.row: 1
            Layout.column: 2
            onValueModified: {
                config.margin.right = value
                updateConfig()
            }
        }
    }
}


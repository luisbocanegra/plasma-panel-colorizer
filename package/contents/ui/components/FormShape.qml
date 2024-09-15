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
        Kirigami.FormData.isSection: isSection
        Kirigami.FormData.label: i18n("Shape")
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

    GridLayout {
        columns: 3
        rows: 3
        Kirigami.FormData.label: i18n("Margins:")
        SpinBox {
            id: topMargin
            value: config.margins.top
            from: 0
            to: 99
            Layout.row: 0
            Layout.column: 1
            onValueModified: {
                config.margins.top = value
                updateConfig()
            }
        }
        SpinBox {
            id: bottomMargin
            value: config.margins.bottom
            from: 0
            to: 99
            Layout.row: 2
            Layout.column: 1
            onValueModified: {
                config.margins.bottom = value
                updateConfig()
            }
        }
        SpinBox {
            id: leftMargin
            value: config.margins.left
            from: 0
            to: 99
            Layout.row: 1
            Layout.column: 0
            onValueModified: {
                config.margins.left = value
                updateConfig()
            }
        }

        SpinBox {
            id: rightMargin
            value: config.margins.right
            from: 0
            to: 99
            Layout.row: 1
            Layout.column: 2
            onValueModified: {
                config.margins.right = value
                updateConfig()
            }
        }
    }
}


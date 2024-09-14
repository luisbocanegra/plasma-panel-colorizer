import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

ColumnLayout {
    id: backgroundRoot

    // internal config object
    property var config: JSON.parse(configString)
    // we save as string so we return as that
    property string configString: "{}"
    signal updateConfigString(configString: string, config: var)
    // to hide options that make no sense for panel
    property bool isPanel: false
    // wether or not show color list option
    property bool multiColor: true

    function updateConfig() {
        configString = JSON.stringify(config, null, null)
        console.error(configString)
        updateConfigString(configString, config)
    }

    Component.onCompleted: {
        console.error(configString)
        console.error(JSON.stringify(config, null, null))
    }
    Kirigami.FormLayout {
        // required to align with parent form
        property alias formLayout: backgroundRoot
        twinFormLayouts: parentLayout
        Layout.fillWidth: true

        CheckBox {
            Kirigami.FormData.label: i18n("Blur behind:")
            id: animationCheckbox
            checked: config.blurBehind
            onCheckedChanged: {
                config.blurBehind = checked
                updateConfig()
            }
        }
    }
    Colors {
        id: colorsComp
        config: backgroundRoot.config.backgroundColor
        onUpdateConfigString: (newString, newConfig) => {
            backgroundRoot.config.backgroundColor = newConfig
            backgroundRoot.updateConfig()
        }
    }
    Kirigami.FormLayout {
        // required to align with parent form
        property alias formLayout: backgroundRoot
        twinFormLayouts: parentLayout
        Layout.fillWidth: true

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
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
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Border")
        }
        RowLayout {
            Kirigami.FormData.label: i18n("Custom widths:")
            CheckBox {
                id: borderCustomSidesCheckbox
                checked: config.border.customSides
                onCheckedChanged: {
                    config.border.customSides = checked
                    updateConfig()
                }
            }

            GridLayout {
                columns: 3
                rows: 3
                enabled: borderCustomSidesCheckbox.checked
                SpinBox {
                    id: topBorderWidth
                    value: config.border.custom.widths.top
                    from: 0
                    to: 99
                    Layout.row: 0
                    Layout.column: 1
                    onValueModified: {
                        config.border.custom.widths.top = value
                        updateConfig()
                    }
                }
                SpinBox {
                    id: bottomBorderWidth
                    value: config.border.custom.widths.bottom
                    from: 0
                    to: 99
                    Layout.row: 2
                    Layout.column: 1
                    onValueModified: {
                        config.border.custom.widths.bottom = value
                        updateConfig()
                    }
                }
                SpinBox {
                    id: leftBorderWidth
                    value: config.border.custom.widths.left
                    from: 0
                    to: 99
                    Layout.row: 1
                    Layout.column: 0
                    onValueModified: {
                        config.border.custom.widths.left = value
                        updateConfig()
                    }
                }

                SpinBox {
                    id: rightBorderWidth
                    value: config.border.custom.widths.right
                    from: 0
                    to: 99
                    Layout.row: 1
                    Layout.column: 2
                    onValueModified: {
                        config.border.custom.widths.right = value
                        updateConfig()
                    }
                }
            }
        }

        SpinBox {
            Kirigami.FormData.label: i18n("Width:")
            id: borderWidth
            value: config.border.width
            from: 0
            to: 99
            Layout.row: 1
            Layout.column: 2
            onValueModified: {
                config.border.width = value
                updateConfig()
            }
            enabled: !borderCustomSidesCheckbox.checked
        }
    }

    Colors {
        id: borderColorsComp
        config: backgroundRoot.config.border.color
        isSection: false
        onUpdateConfigString: (newString, newConfig) => {
            backgroundRoot.config.border.color = newConfig
            backgroundRoot.updateConfig()
        }
    }

    Kirigami.FormLayout {
        // required to align with parent form
        property alias formLayout: backgroundRoot
        twinFormLayouts: parentLayout
        Layout.fillWidth: true

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Shadow")
        }

        SpinBox {
            Kirigami.FormData.label: i18n("Size:")
            id: shadowSize
            value: config.shadow.size
            from: 0
            to: 99
            onValueModified: {
                config.shadow.size = value
                updateConfig()
            }
        }

        SpinBox {
            Kirigami.FormData.label: i18n("X offset:")
            id: shadowX
            value: config.shadow.xOffset
            from: -99
            to: 99
            onValueModified: {
                config.shadow.xOffset = value
                updateConfig()
            }
        }

        SpinBox {
            Kirigami.FormData.label: i18n("Y offset:")
            id: shadowY
            value: config.shadow.yOffset
            from: -99
            to: 99
            onValueModified: {
                config.shadow.yOffset = value
                updateConfig()
            }
        }
    }

    Colors {
        id: shadowColorsComp
        config: backgroundRoot.config.shadow.color
        isSection: false
        onUpdateConfigString: (newString, newConfig) => {
            backgroundRoot.config.shadow.color = newConfig
            backgroundRoot.updateConfig()
        }
    }
}

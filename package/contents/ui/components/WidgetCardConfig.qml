import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.AbstractCard {
    id: root
    property var widget
    signal addOverride(widget: string, override: string, index: var)
    signal removeOverride(widget: string, index: int)
    signal clearOverrides(widget: string)
    property var configOverrides: []
    property var overrideAssociations: {}
    property bool showList: false
    property var currentOverrides: overrideAssociations[widget.name] || []
    property var editingIndex: 0

    contentItem: ColumnLayout {
    RowLayout {
        Kirigami.Icon {
            width: Kirigami.Units.gridUnit
            height: width
            source: widget.icon
        }
        ColumnLayout {
            RowLayout {
                Label {
                    text: widget.title
                }
                Rectangle {
                    visible: widget.inTray
                    color: Kirigami.Theme.highlightColor
                    Kirigami.Theme.colorSet: root.Kirigami.Theme["Selection"]
                    radius: parent.height / 2
                    width: label.width + 12
                    height: label.height + 2
                    Kirigami.Theme.inherit: false
                    Label {
                        anchors.centerIn: parent
                        id: label
                        text: i18n("System Tray")
                        color: Kirigami.Theme.textColor
                        Kirigami.Theme.colorSet: root.Kirigami.Theme["Selection"]
                        Kirigami.Theme.inherit: false
                    }
                }
            }
            TextEdit {
                text: widget.name
                opacity: 0.6
                readOnly: true
                color: Kirigami.Theme.textColor
                selectedTextColor: Kirigami.Theme.highlightedTextColor
                selectionColor: Kirigami.Theme.highlightColor
            }
        }
        Item {
            Layout.fillWidth: true
        }

        ColumnLayout {
            Repeater {
                model: currentOverrides
                RowLayout {
                    Layout.alignment: Qt.AlignRight
                    Button {
                        icon.name: "document-edit-symbolic"
                        text: modelData
                        checkable: true
                        checked: showList
                        onClicked: {
                            showList = !showList
                            editingIndex = index
                        }
                    }
                    Button {
                        icon.name: "edit-clear-symbolic"
                        onClicked: {
                            removeOverride(widget.name, index)
                        }
                    }
                }
            }
            RowLayout {
                Layout.alignment: Qt.AlignRight
                Button {
                    icon.name: "edit-clear-all-symbolic"
                    onClicked: {
                        clearOverrides(widget.name)
                    }
                    text: "Clear"
                    visible: currentOverrides.length !== 0
                }
                Button {

                    icon.name: "list-add-symbolic"
                    checkable: true
                    text: i18n("Add")
                    checked: showList && currentOverrides.length === 0
                    onClicked: {
                        showList = !showList
                        editingIndex = null
                    }
                }
            }
        }
    }
        ScrollView {
            visible: showList
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(implicitHeight+20, 300)
            ListView {
                id: listView
                model: configOverrides.filter(override => !currentOverrides.includes(override))
                Layout.fillHeight: true
                reuseItems: true
                clip: true
                focus: true
                activeFocusOnTab: true
                keyNavigationEnabled: true
                delegate: ItemDelegate {
                    property ListView listView: ListView.view
                    width: listView.width
                    text: modelData
                    onClicked: {
                        showList = false
                        addOverride(widget.name, text, root.editingIndex)
                    }
                    Rectangle {
                        color: index & 1 ? "transparent" : Kirigami.Theme.alternateBackgroundColor
                        anchors.fill: parent
                        z: -2
                    }
                }
                highlight: Item {}
                highlightMoveDuration: 0
                highlightResizeDuration: 0
            }
        }
    }
}

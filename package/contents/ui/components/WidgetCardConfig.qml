import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.AbstractCard {
    id: root
    property var widget
    signal updateWidget(name: string, text: string)
    property var configOverrides: []
    property var overrideAssociations: {}
    property bool showList: false
    property string currentGroup: overrideAssociations[widget.name] || ""

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
                        text: "Tray"
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

        Button {
            icon.name: "document-edit-symbolic"
            text: currentGroup
            checkable: true
            checked: showList
            onClicked: {
                showList = !showList
            }
        }
        Button {
            icon.name: "edit-clear-symbolic"
            onClicked: {
                updateWidget(widget.name, "")
                currentGroup = ""
            }
            visible: currentGroup !== ""
        }
    }
        ScrollView {
            visible: showList
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(implicitHeight+20, 300)
            ListView {
                id: listView
                model: configOverrides
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
                        currentGroup = text
                        updateWidget(widget.name, text)
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

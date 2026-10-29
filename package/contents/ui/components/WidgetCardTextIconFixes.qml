import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.AbstractCard {
    id: root
    required property var model
    required property int index
    required property string title
    required property string name
    required property var method
    readonly property int widgetId: model.id
    readonly property string iconName: model.icon
    required property bool inTray
    required property bool reload
    required property bool keepOriginal
    readonly property bool mask: method.mask ?? false
    readonly property bool effect: method.multiEffect ?? false

    signal updateWidget(bool mask, bool effect, bool reload, bool keepOriginal)

    checked: root.mask || root.effect || root.reload || root.keepOriginal

    contentItem: RowLayout {
        Kirigami.Icon {
            Layout.preferredWidth: Kirigami.Units.gridUnit
            Layout.preferredHeight: width
            source: root.iconName
        }

        ColumnLayout {
            Label {
                text: root.title
                Layout.fillWidth: true
                wrapMode: Label.Wrap
            }

            RowLayout {
                TextEdit {
                    text: root.name
                    opacity: 0.6
                    readOnly: true
                    color: Kirigami.Theme.textColor
                    selectedTextColor: Kirigami.Theme.highlightedTextColor
                    selectionColor: Kirigami.Theme.highlightColor
                    font: Kirigami.Theme.smallFont
                }

                TextEdit {
                    text: root.widgetId
                    opacity: 0.6
                    readOnly: true
                    color: Kirigami.Theme.textColor
                    selectedTextColor: Kirigami.Theme.highlightedTextColor
                    selectionColor: Kirigami.Theme.highlightColor
                    font: Kirigami.Theme.smallFont
                }
            }
        }

        Item {
            Layout.fillWidth: true
        }

        Rectangle {
            visible: root.inTray
            color: Kirigami.Theme.highlightColor
            Kirigami.Theme.colorSet: root.Kirigami.Theme["Selection"]
            radius: parent.height / 2
            Layout.preferredWidth: label.width + 12
            Layout.preferredHeight: label.height + 2
            Kirigami.Theme.inherit: false

            Label {
                id: label

                anchors.centerIn: parent
                text: i18n("System Tray")
                color: Kirigami.Theme.textColor
                Kirigami.Theme.colorSet: root.Kirigami.Theme["Selection"]
                Kirigami.Theme.inherit: false
            }
        }

        Button {
            id: keepOriginalCheckbox

            text: i18n("Keep original")
            checkable: true
            checked: root.keepOriginal
            icon.name: checked ? "checkmark-symbolic" : "dialog-close-symbolic"
            onCheckedChanged: {
                root.updateWidget(root.mask, root.effect, root.reload, checked);
            }
        }

        Button {
            id: maskCheckbox

            text: i18n("Mask")
            enabled: !root.keepOriginal
            checkable: true
            checked: root.method.mask
            icon.name: checked ? "checkmark-symbolic" : "dialog-close-symbolic"
            onCheckedChanged: {
                root.updateWidget(checked, root.effect, root.reload, root.keepOriginal);
            }
        }

        Button {
            id: effectCheckbox

            text: i18n("Effect")
            enabled: !root.keepOriginal
            checkable: true
            checked: root.method.multiEffect
            icon.name: checked ? "checkmark-symbolic" : "dialog-close-symbolic"
            onCheckedChanged: {
                root.updateWidget(root.mask, checked, root.reload, root.keepOriginal);
            }
        }

        Button {
            id: reloadCheckbox

            text: i18n("Refresh")
            enabled: !root.keepOriginal
            checkable: true
            checked: root.reload
            icon.name: checked ? "checkmark-symbolic" : "dialog-close-symbolic"
            onCheckedChanged: {
                root.updateWidget(root.mask, root.effect, checked, root.keepOriginal);
            }
        }
    }
}

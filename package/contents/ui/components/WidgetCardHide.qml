import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.AbstractCard {
    id: root

    required property var model

    signal updateWidget(bool hide)

    checked: hideCheckbox.checked

    contentItem: RowLayout {
        Kirigami.Icon {
            Layout.preferredWidth: Kirigami.Units.iconSizes.medium
            Layout.preferredHeight: Kirigami.Units.iconSizes.medium
            source: root.model.icon
        }

        ColumnLayout {
            Label {
                text: root.model.title
                Layout.fillWidth: true
                wrapMode: Label.Wrap
            }

            RowLayout {
                TextEdit {
                    text: root.model.name
                    opacity: 0.6
                    readOnly: true
                    color: Kirigami.Theme.textColor
                    selectedTextColor: Kirigami.Theme.highlightedTextColor
                    selectionColor: Kirigami.Theme.highlightColor
                    font: Kirigami.Theme.smallFont
                }

                TextEdit {
                    text: root.model.id
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
            visible: root.model.inTray
            color: Kirigami.Theme.highlightColor
            Kirigami.Theme.colorSet: root.Kirigami.Theme["Selection"]
            radius: parent.height / 2
            Layout.preferredWidth: label.implicitWidth + 12
            Layout.preferredHeight: label.implicitHeight + 2
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
            id: hideCheckbox

            text: i18n("Hide")
            checkable: true
            checked: root.model.hide ?? false
            icon.name: checked ? "checkmark-symbolic" : "dialog-close-symbolic"
            onCheckedChanged: {
                root.updateWidget(hideCheckbox.checked);
            }
        }
    }
}

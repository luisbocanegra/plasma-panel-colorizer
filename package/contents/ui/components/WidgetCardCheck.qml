import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.AbstractCard {
    id: root
    property var widget
    signal updateWidget(mask: bool, effect: bool, reload: bool)
    checked: maskCheckbox.checked || effectCheckbox.checked || reloadCheckbox.checked

    contentItem: RowLayout {
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
                    Kirigami.Theme.colorSet: Kirigami.Theme["Selection"]
                    radius: parent.height / 2
                    width: label.width + 12
                    height: label.height + 2
                    Kirigami.Theme.inherit: false
                    Label {
                        anchors.centerIn: parent
                        id: label
                        text: "Tray"
                        color: Kirigami.Theme.textColor
                        Kirigami.Theme.colorSet: Kirigami.Theme["Selection"]
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
            id: maskCheckbox
            text: i18n("M")
            checkable: true
            checked: widget.method.mask ?? false
            icon.name: checked ? "checkmark-symbolic" : "dialog-close-symbolic"
            onCheckedChanged: {
                updateWidget(maskCheckbox.checked, effectCheckbox.checked, reloadCheckbox.checked)
            }
            Layout.preferredWidth: 50
        }
        Button {
            id: effectCheckbox
            text: i18n("E")
            checkable: true
            checked: widget.method.multiEffect ?? false
            icon.name: checked ? "checkmark-symbolic" : "dialog-close-symbolic"
            onCheckedChanged: {
                updateWidget(maskCheckbox.checked, effectCheckbox.checked, reloadCheckbox.checked)
            }
            Layout.preferredWidth: 50
        }
        Button {
            id: reloadCheckbox
            text: i18n("R")
            checkable: true
            checked: widget.reload ?? false
            icon.name: checked ? "checkmark-symbolic" : "dialog-close-symbolic"
            onCheckedChanged: {
                updateWidget(maskCheckbox.checked, effectCheckbox.checked, reloadCheckbox.checked)
            }
            Layout.preferredWidth: 50
        }
    }
}

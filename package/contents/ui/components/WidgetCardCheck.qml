import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.AbstractCard {
    id: root
    property var widget
    signal updateWidget(mask: bool, effect: bool)
    checked: maskCheckbox.checked || effectCheckbox.checked

    contentItem: RowLayout {
        Kirigami.Icon {
            width: Kirigami.Units.gridUnit
            height: width
            source: widget.icon
        }
        ColumnLayout {
            Label {
                text: widget.title
            }
            Label {
                text: widget.name
                opacity: 0.6
            }
        }
        Item {
            Layout.fillWidth: true
        }
        Button {
            id: maskCheckbox
            text: i18n("Mask")
            checkable: true
            checked: widget.method.mask ?? false
            icon.name: checked ? "checkmark-symbolic" : "dialog-close-symbolic"
            onCheckedChanged: {
                updateWidget(maskCheckbox.checked, effectCheckbox.checked)
            }
        }
        Button {
            id: effectCheckbox
            text: i18n("Effect")
            checkable: true
            checked: widget.method.multiEffect ?? false
            icon.name: checked ? "checkmark-symbolic" : "dialog-close-symbolic"
            onCheckedChanged: {
                updateWidget(maskCheckbox.checked, effectCheckbox.checked)
            }
        }
    }
}

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.AbstractCard {
    signal deleteOverride(string name)
    signal editingName(string name)

    checked: editBtn.checked

    contentItem: RowLayout {
        Label {
            text: (index + 1).toString() + "."
            font.bold: true
        }

        ColumnLayout {
            Label {
                text: modelData
                elide: Text.ElideRight
            }
        }

        Item {
            Layout.fillWidth: true
        }

        Button {
            id: editBtn

            icon.name: "document-edit-symbolic"
            text: i18n("Edit")
            checkable: true
            checked: overrideName === modelData && userInput
            onClicked: {
                userInput = true;
            }
            onCheckedChanged: {
                if (checked || overrideName === modelData)
                    editingName(modelData);

                showingConfig = checked;
            }
        }

        Button {
            text: i18n("Delete")
            icon.name: "edit-delete-remove-symbolic"
            onClicked: {
                deleteOverride(modelData);
            }
        }
    }
}

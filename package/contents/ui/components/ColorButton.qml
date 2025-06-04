// This is a modified version of https://invent.kde.org/frameworks/kdeclarative/-/blob/master/src/qmlcontrols/kquickcontrols/ColorButton.qml to make it look more like a button
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Button {
    id: root

    /**
     * The user selected color
     */
    property alias color: colorDialog.selectedColor
    /**
     * Title to show in the dialog
     */
    property alias dialogTitle: colorDialog.title
    /**
     * Allow the user to configure an alpha value
     */
    property bool showAlphaChannel: false
    property bool showCurentColor: true

    /**
     * This signal is emitted when the color dialog has been accepted
     *
     * @since 5.61
     */
    signal accepted(string color)

    onClicked: {
        colorDialog.open();
    }

    ColorDialog {
        id: colorDialog
        onAccepted: root.accepted(color)
        parentWindow: root.Window.window
        options: root.showAlphaChannel ? ColorDialog.ShowAlphaChannel : undefined
    }

    contentItem: Item {
        implicitWidth: btnL.implicitWidth + 8
        implicitHeight: btnL.implicitHeight

        RowLayout {
            id: btnL

            anchors.centerIn: parent

            Rectangle {
                color: root.color
                height: currentColorText.implicitHeight
                width: height
                radius: 2

                border {
                    width: 1
                    color: Kirigami.Theme.textColor
                }
            }

            Label {
                id: currentColorText

                text: "<code>" + root.color.toString().toUpperCase() + "</code>"
                visible: root.showCurentColor
                textFormat: Text.RichText
            }
        }
    }
}

// This is a modified version of https://invent.kde.org/frameworks/kdeclarative/-/blob/master/src/qmlcontrols/kquickcontrols/root.qml to make it look more like a button

import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import org.kde.kirigami as Kirigami
import QtQuick.Layouts

Button {
    id: root
    /**
     * The user selected color
     */
    property color color

    /**
     * Title to show in the dialog
     */
    property string dialogTitle

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
    signal accepted(color color)

    contentItem: Item {
        implicitWidth: btnL.implicitWidth + 8
        implicitHeight: btnL.implicitHeight
        RowLayout {
            anchors.centerIn: parent
            id: btnL

            Rectangle {
                color: root.color
                height: currentColorText.implicitHeight
                width: height
            }

            Label {
                id: currentColorText
                text: "<code>"+root.color.toString().toUpperCase()+"</code>"
                visible: root.showCurentColor
                textFormat: Text.RichText
            }
        }
    }

    Component {
        id: colorWindowComponent

        Window { // QTBUG-119055 https://invent.kde.org/plasma/kdeplasma-addons/-/commit/797cef06882acdf4257d8c90b8768a74fdef0955
            id: window
            width: Kirigami.Units.gridUnit * 16
            height: Kirigami.Units.gridUnit * 23
            visible: true
            title: plasmoid.title
            ColorDialog {
                id: colorDialog
                title: root.dialogTitle
                selectedColor: root.color || undefined /* Prevent transparent colors */
                options: root.showAlphaChannel
                parentWindow: window.Window.window
                onAccepted: {
                    root.color = selectedColor
                    root.accepted(selectedColor);
                    window.destroy();
                }
                onRejected: window.destroy()
            }
            onClosing: destroy()
            Component.onCompleted: colorDialog.open()
        }
    }

    onClicked: {
        colorWindowComponent.createObject(root)
    }
}

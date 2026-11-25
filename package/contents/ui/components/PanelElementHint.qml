import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Item {
    id: root
    property int target: -1
    height: 32
    width: 200
    property color borderColor: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.textColor, Kirigami.Theme.backgroundColor, 0.6)
    property color highlightColor: Kirigami.Theme.highlightColor
    property color backgroundColor: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.textColor, Kirigami.Theme.backgroundColor, 0.9)
    // panel
    Rectangle {
        anchors.centerIn: parent
        height: 32
        width: root.width
        color: root.backgroundColor
        border.width: root.target === 0 ? 2 : 1
        border.color: root.target === 0 ? root.highlightColor : root.borderColor
        radius: 3
        RowLayout {
            anchors.fill: parent
            anchors.margins: 4

            // launcher
            Rectangle {
                color: "transparent"
                border.width: root.target === 1 ? 2 : 0
                border.color: root.target === 1 ? root.highlightColor : root.borderColor
                Layout.preferredWidth: 24
                Layout.fillHeight: true
                radius: 3
                Kirigami.Icon {
                    anchors.centerIn: parent
                    anchors.fill: parent
                    source: "start-here-kde-plasma-symbolic"
                }
            }

            // spacer
            Rectangle {
                color: "transparent"
                border.width: root.target === 1 ? 2 : 0
                border.color: root.target === 1 ? root.highlightColor : root.borderColor
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 3
            }

            // tray
            Rectangle {
                color: "transparent"
                border.width: root.target === 1 ? 2 : 0
                border.color: root.target === 1 ? root.highlightColor : root.borderColor
                Layout.preferredWidth: 82
                Layout.fillHeight: true
                radius: 3

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 0
                    spacing: 2

                    // tray widgets
                    Rectangle {
                        color: "transparent"
                        border.width: root.target === 2 ? 2 : 0
                        border.color: root.target === 2 ? root.highlightColor : root.borderColor
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 3
                        Kirigami.Icon {
                            anchors.centerIn: parent
                            anchors.fill: parent
                            source: "audio-volume-high-symbolic"
                        }
                    }

                    Rectangle {
                        color: "transparent"
                        border.width: root.target === 2 ? 2 : 0
                        border.color: root.target === 2 ? root.highlightColor : root.borderColor
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 3
                        Kirigami.Icon {
                            anchors.centerIn: parent
                            anchors.fill: parent
                            source: "network-wireless-connected-100-symbolic"
                        }
                    }

                    Rectangle {
                        color: "transparent"
                        border.width: root.target === 2 ? 2 : 0
                        border.color: root.target === 2 ? root.highlightColor : root.borderColor
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 3
                        Kirigami.Icon {
                            anchors.centerIn: parent
                            anchors.fill: parent
                            source: "battery-050-symbolic"
                        }
                    }
                }
            }

            //clock
            Rectangle {
                color: "transparent"
                border.width: root.target === 1 ? 2 : 0
                border.color: root.target === 1 ? root.highlightColor : root.borderColor
                Layout.preferredWidth: 30
                Layout.fillHeight: true
                radius: 3
                Label {
                    text: "1:00"
                    font.pointSize: 10
                    anchors.centerIn: parent
                }
            }
        }
    }
}

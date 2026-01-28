import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PC3

Item {
    property bool unified: false
    height: 32
    width: 300
    property color borderColor: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.textColor, Kirigami.Theme.backgroundColor, 0.6)
    property color highlightColor: Kirigami.Theme.highlightColor
    property color panelColor: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.textColor, Kirigami.Theme.backgroundColor, 0.9)
    clip: true

    Timer {
        interval: 500
        onTriggered: unified = !unified
        repeat: true
        running: true
    }

    // panel
    Rectangle {
        height: 32
        width: 300
        color: panelColor
        border.width: 1
        border.color: borderColor
        radius: 3
        RowLayout {
            anchors.fill: parent
            anchors.margins: 4
            // launcher
            Rectangle {
                id: widget
                color: "transparent"
                Layout.preferredWidth: 24
                Layout.fillHeight: true
                radius: 3
                border.width: 2
                border.color: highlightColor
                Kirigami.Icon {
                    anchors.centerIn: parent
                    anchors.fill: parent
                    source: "start-here-kde-plasma-symbolic"
                }
            }
            // spacer
            Rectangle {
                color: "transparent"
                border.width: 2
                border.color: highlightColor
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 3
            }

            // tray
            Rectangle {
                color: "transparent"
                border.width: 2
                border.color: highlightColor
                Layout.preferredWidth: unified ? 117 : 82
                Layout.fillHeight: true
                radius: 3

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 0
                    // spacing: 2

                    // tray widgets
                    Rectangle {
                        color: "transparent"
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
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 3
                        Kirigami.Icon {
                            anchors.centerIn: parent
                            anchors.fill: parent
                            source: "battery-050-symbolic"
                        }
                    }
                    //clock
                    Rectangle {
                        visible: unified
                        color: "transparent"
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

            //clock
            Rectangle {
                visible: !unified
                color: "transparent"
                border.width: 2
                border.color: highlightColor
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

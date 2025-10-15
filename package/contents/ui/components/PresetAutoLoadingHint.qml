import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import "../code/utils.js" as Utils

Item {
    property int target: -1
    height: 32
    width: 300
    property color borderColor: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.textColor, Kirigami.Theme.backgroundColor, 0.6)
    property color highlightColor: Kirigami.Theme.highlightColor
    property color panelColor: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.textColor, Kirigami.Theme.backgroundColor, 0.9)
    property color widgetColor: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.textColor, Kirigami.Theme.backgroundColor, 0.9)
    property int panelRadius: 3
    property int widgetRadius: 3

    Timer {
        interval: 1000
        repeat: true
        running: true
        onTriggered: {
            panelRadius = Utils.getRandomInt(0, 10);
            widgetRadius = panelRadius;
            borderColor = Utils.getRandomColor(null, 0.8, 0.7, 1.0);
            panelColor = Utils.getRandomColor(null, 0.8, 0.3, 1.0);
            widgetColor = Utils.getRandomColor(null, 0.8, 0.3, 1.0);
        }
    }
    // panel
    Rectangle {
        anchors.centerIn: parent
        height: 32
        width: 300
        color: panelColor
        border.width: 1
        border.color: borderColor
        radius: panelRadius
        RowLayout {
            anchors.fill: parent
            anchors.margins: 4

            // launcher
            Rectangle {
                color: widgetColor
                border.width: 1
                border.color: borderColor
                Layout.preferredWidth: 24
                Layout.fillHeight: true
                radius: widgetRadius
                Kirigami.Icon {
                    anchors.centerIn: parent
                    anchors.fill: parent
                    source: "start-here-kde-plasma-symbolic"
                }
            }

            // spacer
            Rectangle {
                color: widgetColor
                border.width: 1
                border.color: borderColor
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: widgetRadius
            }

            // tray
            Rectangle {
                color: widgetColor
                border.width: 1
                border.color: borderColor
                Layout.preferredWidth: 82
                Layout.fillHeight: true
                radius: widgetRadius

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 0
                    spacing: 2

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
                }
            }

            //clock
            Rectangle {
                color: widgetColor
                border.width: 1
                border.color: borderColor
                Layout.preferredWidth: 30
                Layout.fillHeight: true
                radius: widgetRadius
                Label {
                    text: "1:00"
                    font.pointSize: 10
                    anchors.centerIn: parent
                }
            }
        }
    }
}

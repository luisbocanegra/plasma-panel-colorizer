import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PC3

Item {
    property int widgetState: 0
    height: 50
    width: 300
    property color borderColor: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.textColor, Kirigami.Theme.backgroundColor, 0.6)
    property color highlightColor: Kirigami.Theme.highlightColor
    property color backgroundColor: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.textColor, Kirigami.Theme.backgroundColor, 0.9)
    clip: true
    // panel
    Rectangle {
        height: 32
        width: 300
        color: backgroundColor
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
                SequentialAnimation on color {
                    running: widgetState === 3
                    alwaysRunToEnd: true
                    loops: Animation.Infinite
                    ColorAnimation {
                        to: highlightColor
                        duration: 250
                    }
                    ColorAnimation {
                        to: "transparent"
                        duration: 250
                    }
                }
                Kirigami.Icon {
                    anchors.centerIn: parent
                    anchors.fill: parent
                    source: "start-here-kde-plasma-symbolic"
                    active: widgetState === 1
                }
                PC3.BusyIndicator {
                    anchors.centerIn: parent
                    anchors.fill: parent
                    visible: widgetState === 4
                }
            }
            // spacer
            Rectangle {
                color: "transparent"
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 3
            }

            // tray
            Rectangle {
                color: "transparent"
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

    Kirigami.Icon {
        x: 6
        y: 8
        source: "cursor-arrow-symbolic"
        fallback: "cursor-arrow"
        visible: widgetState === 1
    }

    // popup
    Rectangle {
        y: 34
        radius: 3
        height: 20
        width: 120
        color: backgroundColor
        border.width: 1
        border.color: borderColor
        opacity: widgetState === 2 ? 1 : 0
        Behavior on opacity {
            NumberAnimation {
                duration: 250
            }
        }
    }
}

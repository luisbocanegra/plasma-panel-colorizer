import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Button {
    id: root
    hoverEnabled: true
    onClicked: Qt.openUrlExternally(root.url)
    padding: 0
    ToolTip.text: root.url
    ToolTip.visible: hovered && ToolTip.text !== ""
    ToolTip.delay: 1000
    property color backgroundColor
    property color iconColor
    property color textColor
    property string url
    property var fontMetrics: FontMetrics {
        font: Kirigami.Theme.defaultFont
        property real fullWidthCharWidth: root.fontMetrics.tightBoundingRect('＿').width
    }
    Item {
        id: baseColors
    }
    property string contrastColor: Kirigami.ColorUtils.brightnessForColor(root.backgroundColor) === Kirigami.ColorUtils.Light ? "black" : "white"
    // Kirigami.Theme.alternateBackgroundColor: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.highlightColor, "black", 0.3)
    Kirigami.Theme.highlightColor: textColor.valid ? textColor : baseColors.Kirigami.Theme.highlightColor
    Kirigami.Theme.backgroundColor: backgroundColor.valid ? backgroundColor : baseColors.Kirigami.Theme.backgroundColor
    Kirigami.Theme.textColor: {
        if (root.textColor.valid) {
            return root.textColor;
        }
        if (root.backgroundColor.valid) {
            return Kirigami.ColorUtils.tintWithAlpha(root.backgroundColor, contrastColor, 0.7);
        }
        return baseColors.Kirigami.Theme.textColor;
    }
}

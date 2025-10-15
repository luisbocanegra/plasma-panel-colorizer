import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PC3

RowLayout {
    Kirigami.Icon {
        Layout.preferredWidth: 64
        Layout.preferredHeight: 64
        source: "start-here-kde-plasma-symbolic"
        color: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.textColor, Kirigami.Theme.backgroundColor, 0.85)
    }
    Kirigami.Icon {
        Layout.preferredWidth: 32
        Layout.preferredHeight: 32
        source: "arrow-right-symbolic"
    }
    Kirigami.Icon {
        Layout.preferredWidth: 64
        Layout.preferredHeight: 64
        source: "start-here-kde-plasma-symbolic"
        color: Kirigami.Theme.textColor
    }
}

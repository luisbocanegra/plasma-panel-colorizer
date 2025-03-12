// import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid

// KCM.SimpleKCM {
Kirigami.PlaceholderMessage {
    id: categoryDisabledMessage

    icon.name: "action-unavailable-symbolic"
    text: i18n("Panel Colorizer is disabled")
    width: parent.width - (Kirigami.Units.largeSpacing * 4)
    anchors.centerIn: parent

    helpfulAction: Kirigami.Action {
        icon.name: "checkmark-symbolic"
        text: i18n("Enable")
        onTriggered: {
            cfg_isEnabled = true;
        }
    }
}

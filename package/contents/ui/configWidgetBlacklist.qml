import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import "components" as Components

KCM.SimpleKCM {
    id:root
    property string cfg_blacklist: blacklist.text

    Kirigami.FormLayout {

        
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: "Blacklist"
        }

        TextArea {
            Kirigami.FormData.label: i18n("Blacklisted plasmoids (one per line):")
            Layout.minimumWidth: 300
            id: blacklist
            text: cfg_blacklist
            onTextChanged: cfg_blacklist = text
        }

        Label {
            text: i18n("Widget IDs that contain any of the words in the list will not be colorized")
            opacity: 0.7
            Layout.maximumWidth: 300
            wrapMode: Text.Wrap
        }
    }
}

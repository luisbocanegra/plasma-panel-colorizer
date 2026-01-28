import QtQuick
import QtQuick.Effects

MultiEffect {
    // a not very effective way to recolor things that can't be recolored
    // the usual way
    id: effectRect
    property bool luisbocanegraPanelColorizerEffectManaged: true
    property Item target
    height: target?.height ?? 0
    width: target?.width ?? 0
    anchors.centerIn: parent
    source: target
    colorization: 1
    autoPaddingEnabled: false
}

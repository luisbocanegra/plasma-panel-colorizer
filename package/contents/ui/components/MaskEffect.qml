import QtQuick

ShaderEffect {
    required property var source
    required property var mask
    property real sourceOpacity: 1.0
    property bool enabled: false
    supportsAtlasTextures: true
    fragmentShader: enabled ? Qt.resolvedUrl("../shaders/badge.frag.qsb") : ""
}

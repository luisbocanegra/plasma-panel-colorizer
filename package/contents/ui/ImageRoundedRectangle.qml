pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Effects
import QtQml
import org.kde.kirigami as Kirigami

AnimatedImage {
    id: root
    property var corners: {
        "topLeftRadius": 0,
        "topRightRadius": 0,
        "bottomLeftRadius": 0,
        "bottomRightRadius": 0
    }
    fillMode: Image.PreserveAspectCrop
    asynchronous: true
    anchors.fill: parent
    layer.enabled: true
    layer.live: true
    layer.effect: MultiEffect {
        maskEnabled: true
        maskSpreadAtMax: 1
        maskSpreadAtMin: 1
        maskThresholdMin: 0.5
        maskSource: ShaderEffectSource {
            sourceItem: Kirigami.ShadowedRectangle {
                width: root.width
                height: root.height
                corners {
                    topLeftRadius: root.corners.topLeftRadius
                    topRightRadius: root.corners.topRightRadius
                    bottomLeftRadius: root.corners.bottomLeftRadius
                    bottomRightRadius: root.corners.bottomRightRadius
                }
            }
        }
    }
}

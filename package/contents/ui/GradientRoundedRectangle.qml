pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Effects
import QtQml
import org.kde.kirigami as Kirigami

Rectangle {
    id: root
    property var stops: []
    property var corners: {
        "topLeftRadius": 0,
        "topRightRadius": 0,
        "bottomLeftRadius": 0,
        "bottomRightRadius": 0
    }
    property int orientation: Gradient.Horizontal
    readonly property Component gradientStop: GradientStop {}

    anchors.fill: parent
    gradient: Gradient {
        id: gradient
        orientation: root.orientation
        stops: {
            let _stops = [];
            for (const stop of root.stops) {
                let g = root.gradientStop.createObject(gradient, {
                    "position": stop.position,
                    "color": stop.color
                });
                _stops.push(g);
            }
            return _stops;
        }
    }
    visible: true
    layer.enabled: true
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

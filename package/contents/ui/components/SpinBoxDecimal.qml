import QtQuick
import QtQuick.Controls

TextField {
    id: root

    property real from: 0
    property real to: 1
    property int decimals: 2
    property real stepSize: 0.1
    property real value: 0

    placeholderText: "0-1"
    text: "0.00"
    onTextChanged: {
        if (!acceptableInput)
            return;

        value = parseFloat(text).toFixed(2);
    }
    onValueChanged: {
        root.value = isNaN(value) ? 0 : value;
        text = root.value.toFixed(validator.decimals).toString() ?? "0.00";
    }

    ValueMouseControl {
        height: parent.height - 8
        width: height
        anchors.right: parent.right
        anchors.rightMargin: 4
        anchors.verticalCenter: parent.verticalCenter
        from: parent.validator.bottom
        to: parent.validator.top
        decimals: parent.validator.decimals
        stepSize: 0.05
        value: parent.value
        onValueChanged: {
            parent.value = parseFloat(value).toFixed(decimals);
        }
    }

    validator: DoubleValidator {
        bottom: root.from
        top: root.to
        decimals: root.decimals
        notation: DoubleValidator.StandardNotation
    }
}

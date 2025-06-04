/*
 *  SPDX-FileCopyrightText: 2024 Wolthera van Hövell tot Westerflier <griffinvalley@gmail.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */
import QtQuick
import QtQuick.Controls

// Simple double spinbox based on Qt example implementation
SpinBox {
    editable: true
    wheelEnabled: true

    property int decimals: 2
    property int multiplier: Math.pow(10, decimals)

    validator: DoubleValidator {
        bottom: Math.min(from, to)
        top: Math.max(from, to)
    }

    textFromValue: function (value, locale) {
        return Number(value / multiplier).toLocaleString(locale, 'f', decimals);
    }

    valueFromText: function (text, locale) {
        return Number.fromLocaleString(locale, text) * multiplier;
    }
}

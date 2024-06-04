/*
    SPDX-FileCopyrightText: %{CURRENT_YEAR} %{AUTHOR} <%{EMAIL}>
    SPDX-License-Identifier: LGPL-2.1-or-later
*/
// panelspacerplugin.cpp

#include "panelcolorizer.h"
#include <QDebug>
#include <QPainterPath>
#include <QRegion>

QVariant PanelColorizer::updatePanelMask(QRectF rect, double radius, QPointF offset, bool vertical) {

    QPainterPath path;
    path.addRoundedRect(rect, radius, radius);

    QRegion region = QRegion(path.toFillPolygon().toPolygon());
    double translateX = vertical ? 0                   : abs(offset.x());
    double translateY = vertical ? abs(offset.y()) : 0;
    region.translate(translateX, translateY);

    return QVariant::fromValue(region);
}

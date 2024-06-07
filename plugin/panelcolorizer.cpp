/*
    SPDX-FileCopyrightText: %{CURRENT_YEAR} %{AUTHOR} <%{EMAIL}>
    SPDX-License-Identifier: LGPL-2.1-or-later
*/
// panelspacerplugin.cpp

#include "panelcolorizer.h"
#include <QDebug>
#include <QPainterPath>
#include <QRegion>

QVariant PanelColorizer::updatePanelMask(QRectF rect, double radius, QPointF offset, bool vertical)
{
    QPainterPath path;
    path.addRoundedRect(rect, radius, radius);

    QRegion region = QRegion(path.toFillPolygon().toPolygon());
    double translateX = vertical ? 0                   : abs(offset.x());
    double translateY = vertical ? abs(offset.y()) : 0;
    region.translate(translateX, translateY);

    return QVariant::fromValue(region);
}

QVariant PanelColorizer::updateWidgetsMask(QVariantList rects, double radius, QPointF offset, bool vertical , int spacing, double hPadding, double vPadding)
{
    QPainterPath path;
    path.setFillRule( Qt::WindingFill );
    double currentLength = 0;
    for (const QVariant &var : rects) {
        QRectF rect = var.toRectF();
        if (vertical) {
            rect.moveTop(currentLength);
            currentLength += rect.height() + spacing;
        } else {
            rect.moveLeft(currentLength);
            currentLength += rect.width() + spacing;
        }
        path.addRoundedRect(rect, radius, radius);
    }

    QRegion region = QRegion(path.simplified().toFillPolygon().toPolygon());
    double translateX = vertical ? hPadding                   : abs(offset.x()) + hPadding;
    double translateY = vertical ? abs(offset.y()) + vPadding : vPadding;
    region.translate(translateX, translateY);

    return QVariant::fromValue(region);
}

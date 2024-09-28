/*
    SPDX-FileCopyrightText: %{CURRENT_YEAR} %{AUTHOR} <%{EMAIL}>
    SPDX-License-Identifier: LGPL-2.1-or-later
*/
// panelspacerplugin.cpp

#include "panelcolorizer.h"
#include <QDebug>
#include <QObject>
#include <QPainter>
#include <QPainterPath>
#include <QPixmap>
#include <QRegion>
#include <qbitmap.h>

PanelColorizer::PanelColorizer(QObject *parent) : QObject(parent) {}

void PanelColorizer::updatePanelMask(int index, QRectF rect, double topLeftRadius, double topRightRadius,
                                     double bottomLeftRadius, double bottomRightRadius, QPointF offset,
                                     int radiusCompensation) {
    // qDebug() << "updatePanelMask x:" << offset.x() << " y:" << offset.y() << " W:" << rect.width()
    //          << " H:" << rect.height();
    topLeftRadius += (topLeftRadius != 0) ? radiusCompensation : 0;
    topRightRadius += (topRightRadius != 0) ? radiusCompensation : 0;
    bottomLeftRadius += (bottomLeftRadius != 0) ? radiusCompensation : 0;
    bottomRightRadius += (bottomRightRadius != 0) ? radiusCompensation : 0;
    QPainterPath path;
    path.moveTo(rect.topLeft() + QPointF(topLeftRadius, 0));
    path.lineTo(rect.topRight() - QPointF(topRightRadius, 0));
    path.quadTo(rect.topRight(), rect.topRight() + QPointF(0, topRightRadius));
    path.lineTo(rect.bottomRight() - QPointF(0, bottomRightRadius));
    path.quadTo(rect.bottomRight(), rect.bottomRight() - QPointF(bottomRightRadius, 0));
    path.lineTo(rect.bottomLeft() + QPointF(bottomLeftRadius, 0));
    path.quadTo(rect.bottomLeft(), rect.bottomLeft() - QPointF(0, bottomLeftRadius));
    path.lineTo(rect.topLeft() + QPointF(0, topLeftRadius));
    path.quadTo(rect.topLeft(), rect.topLeft() + QPointF(topLeftRadius, 0));

    QPixmap pixmap(rect.size().toSize());
    pixmap.fill(Qt::transparent);
    // Draw the QPainterPath onto the QPixmap for antialiasing
    QPainter painter(&pixmap);
    painter.setRenderHint(QPainter::Antialiasing);
    painter.setBrush(Qt::black);
    // no border
    painter.setPen(Qt::NoPen);
    painter.drawPath(path);

    QRegion region = QRegion(pixmap.createMaskFromColor(Qt::transparent));
    double translateX = abs(offset.x());
    double translateY = abs(offset.y());
    region.translate(translateX, translateY);

    if (index >= m_regions.size()) {
        m_regions.resize(index + 1);
    }

    m_regions[index] = region;
    combineRegions();
}

QVariant PanelColorizer::mask() const { return QVariant::fromValue(m_mask); }

void PanelColorizer::combineRegions() {
    QRegion combined;
    for (const QRegion &region : m_regions) {
        combined = combined.united(region);
    }

    bool hadRegions = hasRegions();
    if (m_mask != combined) {
        m_mask = combined;
        emit maskChanged();
    }

    if (hadRegions != hasRegions()) {
        emit hasRegionsChanged();
    }
}

bool PanelColorizer::hasRegions() const { return !m_mask.isEmpty(); }

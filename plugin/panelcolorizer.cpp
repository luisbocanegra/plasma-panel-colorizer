/*
    SPDX-FileCopyrightText: %{CURRENT_YEAR} %{AUTHOR} <%{EMAIL}>
    SPDX-License-Identifier: LGPL-2.1-or-later
*/
// panelspacerplugin.cpp

#include "panelcolorizer.h"
#include <QDebug>
#include <QObject>
#include <QPainterPath>
#include <QRegion>

PanelColorizer::PanelColorizer(QObject *parent) : QObject(parent) {}

void PanelColorizer::updatePanelMask(int index, QRectF rect, double radius, QPointF offset) {
    // qDebug() << "updatePanelMask x:" << offset.x() << " y:" << offset.y() << " W:" << rect.width()
    //          << " H:" << rect.height();
    QPainterPath path;
    path.addRoundedRect(rect, radius, radius);

    QRegion region = QRegion(path.toFillPolygon().toPolygon());
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

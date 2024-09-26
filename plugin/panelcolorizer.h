#ifndef PANELCOLORIZER_H
#define PANELCOLORIZER_H

#pragma once

#include <QObject>
#include <QRectF>
#include <QRegion>
#include <QVariant>

class PanelColorizer : public QObject {
    Q_OBJECT
    Q_PROPERTY(QVariant mask READ mask NOTIFY maskChanged)
    Q_PROPERTY(bool hasRegions READ hasRegions NOTIFY hasRegionsChanged)

  public:
    Q_INVOKABLE void updatePanelMask(int index, QRectF rect, double radius, QPointF offset);

    explicit PanelColorizer(QObject *parent = nullptr);

    QVariant mask() const;
    bool hasRegions() const;

  signals:
    void maskChanged();
    void hasRegionsChanged();

  private:
    QString m_time;
    qreal m_value;
    QVector<QRegion> m_regions;
    QRegion m_mask;
    void combineRegions();
};

#endif

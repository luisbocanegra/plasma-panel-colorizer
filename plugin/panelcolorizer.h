#ifndef PANELCOLORIZER_H
#define PANELCOLORIZER_H

#pragma once

#include <LayerShellQt/Window>
#include <QCryptographicHash>
#include <QMargins>
#include <QObject>
#include <QPixmap>
#include <QPoint>
#include <QPointer>
#include <QRectF>
#include <QRegion>
#include <QVariant>
#include <QWindow>

class PanelColorizer : public QObject {
    Q_OBJECT
    Q_PROPERTY(QVariant mask READ mask NOTIFY maskChanged)
    Q_PROPERTY(bool hasRegions READ hasRegions NOTIFY hasRegionsChanged)

  public:
    Q_INVOKABLE void updatePanelMask(int index, QRectF rect, double topLeftRadius, double topRightRadius,
                                     double bottomLeftRadius, double bottomRightRadius, QPointF offset,
                                     int radiusCompensation, bool visible);
    Q_INVOKABLE void removeMaskRegion(int index);

    Q_INVOKABLE QString getIconHash(const QVariant &variant);

    Q_INVOKABLE void setScreenEdgeMargin(QWindow *window, int margin);
    Q_INVOKABLE void clearScreenEdgeMargin();

    explicit PanelColorizer(QObject *parent = nullptr);

    QVariant mask() const;
    bool hasRegions() const;

  signals:
    void maskChanged();
    void hasRegionsChanged();

  private slots:
    void setMargins();
    void setPosition();

  private:
    QString m_time;
    qreal m_value;
    QMap<int, QPair<QRegion, bool>> m_regions;
    QRegion m_mask;
    void combineRegions();

    QPointer<QWindow> m_panelWindow;
    LayerShellQt::Window *m_layerWindow = nullptr;
    QMargins m_layerMargins;
    int m_margin;
    QPoint m_panelPositionOffset;
    QPoint m_panelPosition;
    bool m_syncingPosition = false;
    void syncPanelPosition(bool positionSetByPlasma);
};

#endif

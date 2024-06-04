#ifndef PANELCOLORIZER_H
#define PANELCOLORIZER_H

#pragma once


#include <QObject>
#include <QRectF>
#include <QVariant>

class PanelColorizer : public QObject
{
    Q_OBJECT

public:

    Q_INVOKABLE QVariant updatePanelMask(QRectF rect, double radius, QPointF offset, bool vertical);
};

#endif

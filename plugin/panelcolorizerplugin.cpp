#include "panelcolorizer.h"

#include <QQmlEngine>
#include <QQmlExtensionPlugin>

class PanelColorizerPlugin : public QQmlExtensionPlugin {
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "org.qt-project.Qt.QQmlExtensionInterface")

  public:
    void registerTypes(const char *uri) override {
        //    Q_ASSERT(QLatin1String(uri) ==
        //    QLatin1String("org.kde.plasma.panelspacer"));

        qmlRegisterType<PanelColorizer>(uri, 1, 0, "PanelColorizer");
    }
};

#include "panelcolorizerplugin.moc"

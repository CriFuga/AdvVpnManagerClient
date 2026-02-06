#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QSortFilterProxyModel>

#include "advvpngroupmodel.h"
#include "advvpngroupproxymodel.h"
#include "advvpnitemmodel.h"
#include "advvpnitemproxymodel.h"
#include "advvpnsocket.h"
#include "clientcontroller.h"
#include "thememanager.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setOrganizationName("ADV Integration Srl");
    QCoreApplication::setApplicationName("ADVVpnManagerClient");
    QCoreApplication::setApplicationVersion("1.0.0");

    QGuiApplication app(argc, argv);

    AdvVpnGroupModel groupModel;
    AdvVpnItemModel itemModel;
    itemModel.setGroupModel(&groupModel);

    AdvVpnGroupProxyModel *groupProxy = new AdvVpnGroupProxyModel();
    groupProxy->setSourceModel(&groupModel);
    groupProxy->setDynamicSortFilter(true);
    groupProxy->setFilterCaseSensitivity(Qt::CaseInsensitive);
    groupProxy->sort(0, Qt::AscendingOrder);

    QSortFilterProxyModel *itemProxy = new AdvVpnItemProxyModel();
    itemProxy->setSourceModel(&itemModel);

    AdvVpnSocket socket;
    ClientController controller(&groupModel, &itemModel);

    ThemeManager themeManager;
    QQmlApplicationEngine engine;

    engine.rootContext()->setContextProperty("Theme", &themeManager);
    engine.rootContext()->setContextProperty("groupModel", groupProxy);
    engine.rootContext()->setContextProperty("itemModel", itemProxy);

    controller.setGroupProxy(groupProxy);
    controller.setItemProxy(itemProxy);

    engine.rootContext()->setContextProperty("rawGroupModel", &groupModel);
    engine.rootContext()->setContextProperty("rawItemModel", &itemModel);
    engine.rootContext()->setContextProperty("AdvVpnSocket", &socket);
    engine.rootContext()->setContextProperty("controller", &controller);
    engine.rootContext()->setContextProperty("syncModel", controller.syncModel());

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
                     &app, []() { QCoreApplication::exit(-1); }, Qt::QueuedConnection);

    engine.loadFromModule("ADVVpnManagerClient", "Main");

    controller.start();

    return app.exec();
}

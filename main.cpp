#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QSortFilterProxyModel>

#include "advvpngroupmodel.h"
#include "advvpnitemmodel.h"
#include "advvpnsocket.h"
#include "clientcontroller.h"
#include "thememanager.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setOrganizationName("ADV Integration Srl");
    QCoreApplication::setApplicationName("ADVVpnManagerClient");
    QCoreApplication::setApplicationVersion("1.0.0");

    QGuiApplication app(argc, argv);

    // 1. Inizializzazione Modelli
    AdvVpnGroupModel groupModel;

    // Proxy per la ricerca nella Sidebar
    QSortFilterProxyModel *proxyModel = new QSortFilterProxyModel();
    proxyModel->setSourceModel(&groupModel);
    proxyModel->setFilterCaseSensitivity(Qt::CaseInsensitive);
    proxyModel->setFilterRole(AdvVpnGroupModel::NameRole);

    AdvVpnItemModel itemModel;
    itemModel.setGroupModel(&groupModel);

    // 2. Inizializzazione Controller e Socket
    // Usiamo l'istanza globale se definita come Singleton, altrimenti quella locale
    AdvVpnSocket socket;

    // Passiamo le istanze ESATTE dei modelli al controller
    ClientController controller(&groupModel, &itemModel);

    ThemeManager themeManager;

    QQmlApplicationEngine engine;

    // 3. Registrazione Proprietà di Contesto
    engine.rootContext()->setContextProperty("Theme", &themeManager);

    // ATTENZIONE: Usa nomi diversi per il modello reale e il proxy!
    engine.rootContext()->setContextProperty("rawGroupModel", &groupModel);
    engine.rootContext()->setContextProperty("groupModel", proxyModel);

    engine.rootContext()->setContextProperty("itemModel", &itemModel);
    engine.rootContext()->setContextProperty("AdvVpnSocket", &socket);
    engine.rootContext()->setContextProperty("controller", &controller);

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
                     &app, []() { QCoreApplication::exit(-1); }, Qt::QueuedConnection);

    engine.loadFromModule("ADVVpnManagerClient", "Main");

    controller.start();

    return app.exec();
}

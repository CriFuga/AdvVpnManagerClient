#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QSortFilterProxyModel>

#include "advvpngroupmodel.h"
#include "advvpngroupproxymodel.h"
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

    // 1. Inizializzazione Modelli Sorgente
    AdvVpnGroupModel groupModel;
    AdvVpnItemModel itemModel;
    itemModel.setGroupModel(&groupModel);

    // 2. Configurazione Proxy Gruppi (Sidebar)
    AdvVpnGroupProxyModel *groupProxy = new AdvVpnGroupProxyModel();
    groupProxy->setSourceModel(&groupModel);
    groupProxy->setDynamicSortFilter(true);
    groupProxy->setFilterCaseSensitivity(Qt::CaseInsensitive);
    groupProxy->sort(0, Qt::AscendingOrder); // Ordinamento alfabetico automatico

    // 3. Configurazione Proxy Item (Lista IP centrale)
    QSortFilterProxyModel *itemProxy = new QSortFilterProxyModel();
    itemProxy->setSourceModel(&itemModel);
    itemProxy->setFilterRole(AdvVpnItemModel::IsHiddenRole); // Filtro per visibilità
    itemProxy->setFilterFixedString("false");               // Mostra solo i non nascosti
    itemProxy->setDynamicSortFilter(true);

    // 4. Inizializzazione Socket e Controller
    AdvVpnSocket socket;
    // Passiamo i modelli reali al controller (lui deve poter modificare tutto)
    ClientController controller(&groupModel, &itemModel);

    ThemeManager themeManager;
    QQmlApplicationEngine engine;

    // 5. Registrazione Proprietà di Contesto
    engine.rootContext()->setContextProperty("Theme", &themeManager);

    // NOTA: Passiamo i PROXY alla UI per gestire ricerca e invisibilità (Undo)
    engine.rootContext()->setContextProperty("groupModel", groupProxy);
    controller.setGroupProxy(groupProxy);
    engine.rootContext()->setContextProperty("itemModel", itemProxy); // <--- RIMOSSA LA DOPPIA RIGA ERRATA

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

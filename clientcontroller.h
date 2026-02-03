#ifndef CLIENTCONTROLLER_H
#define CLIENTCONTROLLER_H

#include <QObject>
#include <QJsonObject>
#include <qsortfilterproxymodel.h>
#include "changesbuffermanager.h"
#include "changesbuffermodel.h"

class AdvVpnGroupModel;
class AdvVpnItemModel;


class ClientController : public QObject
{
    Q_OBJECT
    // Manteniamo le proprietà per non rompere il QML
    Q_PROPERTY(QStringList availableCns READ availableCns NOTIFY availableCnsChanged)
    Q_PROPERTY(int pendingChangesCount READ pendingChangesCount NOTIFY pendingChangesCountChanged)

public:
    explicit ClientController(AdvVpnGroupModel *groupModel, AdvVpnItemModel *itemModel, QObject *parent = nullptr);

    ChangesBufferModel* syncModel() const { return m_syncModel; }

    // API PUBBLICHE (Invariate per il QML)
    Q_INVOKABLE void start();
    Q_INVOKABLE void sendIdUpdate(const QString &ip, const QString &newId); // Ex sendCnUpdate
    Q_INVOKABLE void addGroupRequest(const QString &groupName);
    Q_INVOKABLE void addIpRequest(const QString &groupName, const QString &ipAddress);
    Q_INVOKABLE void removeGroupRequest(const QString &groupName);
    Q_INVOKABLE void renameGroupRequest(const QString &oldName, const QString &newName);
    Q_INVOKABLE void requestRemoveIp(const QString &groupName, const QString &ipAddress);
    Q_INVOKABLE void updateIpRequest(const QString &oldIp, const QString &newIp); // Ex updateIpLocally
    Q_INVOKABLE void selectGroupFromProxy(int proxyRow);

    // Nuove API per il Sync
    Q_INVOKABLE void commitSync();
    Q_INVOKABLE void discardChanges();

    QStringList availableCns() const { return m_availableCns; }
    int pendingChangesCount() const { return m_changesBuffer->count(); }

    void setGroupProxy(QSortFilterProxyModel* proxy) { m_groupProxy = proxy; }

signals:
    void availableCnsChanged();
    void pendingChangesCountChanged();
    void errorsOccurred(const QString &msg);

private slots:
    void onSyncDataReceived(const QJsonObject &data);

private:
    void setupBufferConnections(); // Metodo per gestire la logica di Undo
    void rollbackAction(const VpnAction &action);

    QString actionTypeToString(VpnAction::Type type);

    AdvVpnGroupModel *m_groupModel;
    AdvVpnItemModel *m_itemModel;
    ChangesBufferManager *m_changesBuffer;
    ChangesBufferModel *m_syncModel; // Il modello per la ListView del Sync
    QStringList m_availableCns;
    QSortFilterProxyModel* m_groupProxy = nullptr;
};

#endif

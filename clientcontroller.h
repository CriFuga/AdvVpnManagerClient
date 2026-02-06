#ifndef CLIENTCONTROLLER_H
#define CLIENTCONTROLLER_H

#include <QObject>
#include <QJsonObject>
#include <qsortfilterproxymodel.h>
#include "changesbuffermanager.h"
#include "changesbuffermodel.h"

class AdvVpnGroupModel;
class AdvVpnItemModel;
class AdvVpnSocket;

class ClientController : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QStringList availableCns READ availableCns NOTIFY availableCnsChanged)
    Q_PROPERTY(int pendingChangesCount READ pendingChangesCount NOTIFY pendingChangesCountChanged)
    Q_PROPERTY(QStringList conflictMessages READ conflictMessages NOTIFY conflictMessagesChanged)

public:

    explicit ClientController(AdvVpnGroupModel *groupModel, AdvVpnItemModel *itemModel, QObject *parent = nullptr);

    Q_INVOKABLE void start();
    Q_INVOKABLE void sendIdUpdate(const QString &ip, const QString &newId);
    Q_INVOKABLE void addGroupRequest(const QString &groupName);
    Q_INVOKABLE void addIpRequest(const QString &groupName, const QString &ipAddress);
    Q_INVOKABLE void removeGroupRequest(const QString &groupName);
    Q_INVOKABLE void renameGroupRequest(const QString &oldName, const QString &newName);
    Q_INVOKABLE void requestRemoveIp(const QString &groupName, const QString &ipAddress);
    Q_INVOKABLE void updateIpRequest(const QString &oldIp, const QString &newIp);
    Q_INVOKABLE void selectGroupFromProxy(int proxyRow);
    Q_INVOKABLE void clearConflicts();
    Q_INVOKABLE void commitSync();
    Q_INVOKABLE void discardChanges();

    ChangesBufferModel* syncModel() const { return m_syncModel; }
    QStringList availableCns() const { return m_availableCns; }
    QStringList conflictMessages() const { return m_conflictMessages; }
    int pendingChangesCount() const { return m_changesBuffer->count(); }

    void setGroupProxy(QSortFilterProxyModel* proxy) { m_groupProxy = proxy; }
    void setItemProxy(QSortFilterProxyModel* proxy) { m_itemProxy = proxy; }

signals:
    void started(const QString &msg);
    void availableCnsChanged();
    void conflictMessagesChanged();
    void pendingChangesCountChanged();
    void errorsOccurred(const QString &msg);

private slots:
    void onSyncDataReceived(const QJsonObject &data);

private:

    void setupBufferConnections();
    void rollbackAction(const VpnAction &action);
    QString actionTypeToString(VpnAction::Type type);

    AdvVpnGroupModel *m_groupModel;
    AdvVpnItemModel *m_itemModel;
    ChangesBufferManager *m_changesBuffer;
    ChangesBufferModel *m_syncModel;
    QStringList m_availableCns;
    QStringList m_conflictMessages;
    QSortFilterProxyModel* m_groupProxy = nullptr;
    QSortFilterProxyModel* m_itemProxy = nullptr;
};

#endif

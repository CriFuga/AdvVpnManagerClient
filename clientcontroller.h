#ifndef CLIENTCONTROLLER_H
#define CLIENTCONTROLLER_H

#include <QObject>
#include <QJsonObject>

class AdvVpnGroupModel;
class AdvVpnItemModel;
class AdvVpnSocket;

struct PendingChange{

    QString type;        // e.g., "ADD", "RENAME", "DELETE"
    QString description; // e.g., "Rinomina gruppo 'A' in 'B'"
    QVariantMap data;    // Stores specific details for the sync payload

};

class ClientController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QStringList availableCns READ availableCns NOTIFY availableCnsChanged)
    Q_PROPERTY(QVariantList pendingChanges READ getPendingChangesForQml NOTIFY pendingChangesChanged)
    Q_PROPERTY(int pendingChangesCount READ pendingChangesCount NOTIFY pendingChangesChanged)

public:
    explicit ClientController(AdvVpnGroupModel *groupModel,
                              AdvVpnItemModel *itemModel,
                              QObject *parent = nullptr);

    void start();

    QStringList availableCns() const { return m_availableCns; }

    Q_INVOKABLE void addGroupRequest(const QString &groupName);
    Q_INVOKABLE void addIpRequest(const QString &groupName, const QString &ipAddress);
    Q_INVOKABLE void removeGroupRequest(const QString &groupName);
    Q_INVOKABLE void renameGroupRequest(const QString &oldName, const QString &newName);
    Q_INVOKABLE void requestRemoveIp(const QString &groupName, const QString &ipAddress);
    Q_INVOKABLE void updateIpLocally(const QString &oldIp, const QString &newIp);
    Q_INVOKABLE void commitSync();
    Q_INVOKABLE void discardChanges();
    Q_INVOKABLE void sendCnUpdate(const QString &ip, const QString &newCn);


    void recordChange(const QString &type, const QString &desc, const QVariantMap &data);
    QVariantList getPendingChangesForQml() const;
    int pendingChangesCount() const { return m_pendingChanges.size(); }

signals:

    void availableCnsChanged();
    void pendingChangesChanged();

private slots:

    void onSyncDataReceived(const QJsonObject &data);

private:

    AdvVpnGroupModel *m_groupModel;
    AdvVpnItemModel *m_itemModel;
    QStringList m_availableCns;
    QList<PendingChange> m_pendingChanges;
    QVariantList m_pendingChangesList; // Lista di QVariantMap per QML<
};

#endif // CLIENTCONTROLLER_H

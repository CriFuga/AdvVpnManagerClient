#ifndef ADVVPNGROUPMODEL_H
#define ADVVPNGROUPMODEL_H

#include <QAbstractListModel>

class AdvVpnGroup;

class AdvVpnGroupModel : public QAbstractListModel
{
    Q_OBJECT
public:

    enum Roles {
        NameRole = Qt::UserRole + 1,
        ItemCountRole
    };

    explicit AdvVpnGroupModel(QObject * parent = nullptr);

    void setGroups(const QList<class AdvVpnGroup *> &groups);
    void updateGroupNameLocally(const QString &oldName, const QString &newName);
    void addGroupLocally(const QString &groupName);
    void removeGroupLocally(const QString &groupName);
    void addIpToGroupLocally(const QString &groupName, const QString &ipAddress);
    void raiseConflicts(const QStringList &msg);
    AdvVpnGroup* groupAt(int row) const;

    QJsonArray toJsonArray() const;


    // Gestione Mappa IP -> CN
    void setIpToCn(const QHash<QString, QString> &map);
    QHash<QString, QString> ipToCnMap() const { return m_ipToCn; }
    QString getCnForIp(const QString &ip) const;

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role ) const override;
    QHash<int, QByteArray> roleNames() const override;

signals:
    void conflictsDetected(const QStringList &messages);

private:
    QList<AdvVpnGroup *> m_groups;
    QString m_sourcePath;
    QString m_originalText;

    QHash<QString, QString> m_ipToCn;

};

#endif // ADVVPNGROUPMODEL_H

#ifndef ADVVPNGROUPMODEL_H
#define ADVVPNGROUPMODEL_H

#include <QAbstractListModel>
#include <QJsonArray>
#include <QHash>

class AdvVpnGroup;

class AdvVpnGroupModel : public QAbstractListModel
{
    Q_OBJECT
public:
    enum Roles {
        NameRole = Qt::UserRole + 1,
        IsHiddenRole = Qt::UserRole + 2,
        ItemCountRole
    };

    explicit AdvVpnGroupModel(QObject * parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role ) const override;
    QHash<int, QByteArray> roleNames() const override;

    void setGroups(const QList<AdvVpnGroup *> &groups);
    void setGroupHidden(const QString &groupName, bool hide);
    AdvVpnGroup* groupAt(int row) const;

    void addGroupLocally(const QString &groupName);
    void removeGroupLocally(const QString &groupName);
    void updateGroupNameLocally(const QString &oldName, const QString &newName);
    void addIpToGroupLocally(const QString &groupName, const QString &ipAddress);

    bool duplicateNameExists(const QString &groupName) const;
    void raiseConflicts(const QStringList &msg);

    void setIpToCn(const QHash<QString, QString> &map);
    QHash<QString, QString> ipToCnMap() const;
    QString getCnForIp(const QString &ip) const;

    QJsonArray toJsonArray() const;

signals:
    void conflictsDetected(const QStringList &messages);

private:
    QList<AdvVpnGroup *> m_groups;
    QHash<QString, QString> m_ipToCn;
    QString m_sourcePath;
    QString m_originalText;
};

#endif // ADVVPNGROUPMODEL_H

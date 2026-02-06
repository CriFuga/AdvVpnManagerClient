#ifndef ADVVPNITEMMODEL_H
#define ADVVPNITEMMODEL_H

#include <QAbstractListModel>
#include <QHash>

class AdvVpnGroup;
class AdvVpnGroupModel;

class AdvVpnItemModel : public QAbstractListModel
{
    Q_OBJECT
public:
    enum Roles {
        KindRole = Qt::UserRole + 1,
        IsHiddenRole = Qt::UserRole + 2,
        ValueRole,
        CnRole,
        TooltipRole,
        QtDisplayRole = Qt::DisplayRole
    };

    explicit AdvVpnItemModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;
    void clear();

    Q_INVOKABLE void setGroupIndex(int row);
    Q_INVOKABLE QString currentGroupName() const;
    int currentGroupIndex() const;
    void setGroupModel(AdvVpnGroupModel *groupModel);

    Q_INVOKABLE void addIpLocally(const QString &ipAddress);
    Q_INVOKABLE void renameIpLocally(const QString &oldIp, const QString &newIp);
    Q_INVOKABLE void updateCnLocally(const QString &ip, const QString &newCn);
    Q_INVOKABLE void removeIpLocally(const QString &ipAddress);
    Q_INVOKABLE void setItemHidden(const QString &ip, bool hide);

    Q_INVOKABLE bool ipExistsInCurrentGroup(const QString &ip, const QString &excludeIp = "") const;
    Q_INVOKABLE QString getIpForCn(const QString &cn) const;
    void setIpToCn(const QHash<QString, QString> &map);

private:
    AdvVpnGroupModel *m_groupModel = nullptr;
    AdvVpnGroup *m_group = nullptr;
    QHash<QString, QString> m_ipToCn;
    int m_groupIndex = -1;
};

#endif // ADVVPNITEMMODEL_H

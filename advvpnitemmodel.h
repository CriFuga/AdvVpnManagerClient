#ifndef ADVVPNITEMMODEL_H
#define ADVVPNITEMMODEL_H

#include <QAbstractListModel>

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

    Q_INVOKABLE void setGroupIndex(int row);
    int currentGroupIndex() const { return m_groupIndex; }
    void setGroupModel(AdvVpnGroupModel *groupModel);
    Q_INVOKABLE void addIpLocally(const QString &ipAddress);
    Q_INVOKABLE void renameIpLocally(const QString &oldIp, const QString &newIp);
    Q_INVOKABLE void updateCnLocally(const QString &ip, const QString &newCn);
    Q_INVOKABLE void removeIpLocally(const QString &ipAddress);
    Q_INVOKABLE void setItemHidden(const QString &ip, bool hide);
    void setIpToCn(const QHash<QString, QString> &map);
    void clear();

    Q_INVOKABLE QString currentGroupName() const;

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

private:
    AdvVpnGroupModel *m_groupModel = nullptr;
    AdvVpnGroup *m_group = nullptr;
    AdvVpnItemModel *m_items = nullptr;
    int m_groupIndex = -1; // <--- AGGIUNGI QUESTA RIGA
    QHash<QString, QString> m_ipToCn;
};


#endif // ADVVPNITEMMODEL_H

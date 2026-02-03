#include "advvpngroupmodel.h"
#include "advvpngroup.h"
#include "advvpnitem.h"
#include <QDebug>
#include <QJsonArray>

// Constructor: initializes the model with an optional parent.
AdvVpnGroupModel::AdvVpnGroupModel(QObject * parent)
    : QAbstractListModel(parent)
{
}

// Resets the model with a new list of VPN groups, notifying views of the change.
void AdvVpnGroupModel::setGroups(const QList<AdvVpnGroup *> &groups)
{
    beginResetModel();
    m_groups = groups;
    endResetModel();
}

void AdvVpnGroupModel::updateGroupNameLocally(const QString &oldName, const QString &newName) {
    for (int i = 0; i < m_groups.count(); ++i) {
        if (m_groups[i]->name() == oldName) {
            m_groups[i]->setName(newName);

            QModelIndex idx = index(i, 0);
            emit dataChanged(idx, idx, {Qt::DisplayRole, NameRole});
            break;
        }
    }
}

void AdvVpnGroupModel::addGroupLocally(const QString &groupName)
{
    QString trimmedName = groupName.trimmed();

    for (const auto &group : m_groups) {
        if (group->name().compare(trimmedName, Qt::CaseInsensitive) == 0){
            emit conflictsDetected(
                {QString("'%1' già presente , impossibile aggiungerlo").arg(trimmedName)}
            );
            return;
        }
    }

    AdvVpnGroup *newGroup = new AdvVpnGroup(trimmedName);

    beginInsertRows(QModelIndex(), m_groups.count(), m_groups.count());
    m_groups.append(newGroup);
    endInsertRows();

    qInfo() << "📁 Gruppo aggiunto in staging:" << trimmedName;

}

void AdvVpnGroupModel::addIpToGroupLocally(const QString &groupName, const QString &ipAddress)
{
    for (int i = 0; i < m_groups.count(); ++i) {
        if (m_groups[i]->name() == groupName) {
            m_groups[i]->addIp(ipAddress);

            QModelIndex idx = index(i, 0);
            emit dataChanged(idx, idx, {Qt::DisplayRole, ItemCountRole});
            break;
        }
    }
}

void AdvVpnGroupModel::removeGroupLocally(const QString &groupName)
{
    for (int i = 0; i < m_groups.count(); ++i) {
        if (m_groups[i]->name() == groupName) {
            beginRemoveRows(QModelIndex(), i, i);
            m_groups.removeAt(i);
            endRemoveRows();
            break;
        }
    }
}

void AdvVpnGroupModel::raiseConflicts(const QStringList &msg)
{
    if (!msg.isEmpty()) emit conflictsDetected(msg);
}

void AdvVpnGroupModel::setGroupHidden(const QString &groupName, bool hide) {
    for (int i = 0; i < m_groups.count(); ++i) {
        if (m_groups[i]->name() == groupName) {
            m_groups[i]->setHidden(hide);

            if (!hide) {
                for (auto *item : m_groups[i]->items()) item->setHidden(false);
            }

            QModelIndex idx = index(i, 0);
            // Emetti il segnale per tutti i ruoli coinvolti
            emit dataChanged(idx, idx, {NameRole, IsHiddenRole, ItemCountRole});
            return;
        }
    }
}

// Returns the group object at the specified row index safely.
AdvVpnGroup *AdvVpnGroupModel::groupAt(int row) const
{
    if (row < 0 || row >= m_groups.size())
        return nullptr;
    return m_groups[row];
}

QJsonArray AdvVpnGroupModel::toJsonArray() const
{
    QJsonArray arr;
    for (const auto *group : m_groups) {
        if (group) {
            arr.append(group->toJson());
        }
    }
    return arr;
}


// Updates the internal hash map used to resolve IPs to Common Names.
void AdvVpnGroupModel::setIpToCn(const QHash<QString, QString> &map)
{
    m_ipToCn = map;
}

// Returns the total number of groups in the model.
int AdvVpnGroupModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) return 0;
    return m_groups.size();
}

// Retrieves data for a specific index and role (Display, Name, or ItemCount).
QVariant AdvVpnGroupModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_groups.count()) return QVariant();
    const auto *item = m_groups.at(index.row());

    if (role == NameRole) return item->name();
    if (role == IsHiddenRole) return item->isHidden(); // <--- Corretto
    if (role == ItemCountRole) {
        // Conta solo gli IP non nascosti per coerenza visiva
        int count = 0;
        for (const auto *vpnItem : item->items()) {
            if (!vpnItem->isHidden()) count++;
        }
        return count;
    }
    return QVariant();
}

// Maps internal model roles to string names usable in QML.
QHash<int, QByteArray> AdvVpnGroupModel::roleNames() const
{
    return {
        { NameRole, "name" },
        { IsHiddenRole ,"isHidden"},
        { ItemCountRole, "itemCount" }
    };
}



#include "advvpngroupmodel.h"
#include "advvpngroup.h"
#include "advvpnitem.h"
#include <QDebug>
#include <QJsonArray>


// Constructor: initializes the model with an optional parent
AdvVpnGroupModel::AdvVpnGroupModel(QObject * parent)
    : QAbstractListModel(parent)
{
}


// Returns the total number of groups in the model
int AdvVpnGroupModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) return 0;
    return m_groups.size();
}

// Retrieves data for a specific index and role (Display, Name, Hidden status, or ItemCount)
QVariant AdvVpnGroupModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_groups.count()) return QVariant();
    const auto *item = m_groups.at(index.row());

    if (role == NameRole) return item->name();
    if (role == IsHiddenRole) return item->isHidden();
    if (role == ItemCountRole) {
        int count = 0;
        for (auto* item : m_groups[index.row()]->items()) {
            if (!item->isHidden()) count++;
        }
        return count;
    }
    return QVariant();
}

// Maps internal model roles to string names usable in QML
QHash<int, QByteArray> AdvVpnGroupModel::roleNames() const
{
    return {
        { NameRole, "name" },
        { IsHiddenRole ,"isHidden"},
        { ItemCountRole, "itemCount" }
    };
}


// Resets the model with a new list of VPN groups, notifying views of the change
void AdvVpnGroupModel::setGroups(const QList<AdvVpnGroup *> &groups)
{
    beginResetModel();
    m_groups = groups;
    endResetModel();
}

// Returns the group object at the specified row index safely
AdvVpnGroup *AdvVpnGroupModel::groupAt(int row) const
{
    if (row < 0 || row >= m_groups.size())
        return nullptr;
    return m_groups[row];
}

// Sets the hidden state of a group and its items, then notifies the view
void AdvVpnGroupModel::setGroupHidden(const QString &groupName, bool hide) {
    for (int i = 0; i < m_groups.count(); ++i) {
        if (m_groups[i]->name() == groupName) {
            m_groups[i]->setHidden(hide);

            if (!hide) {
                for (auto *item : m_groups[i]->items()) item->setHidden(false);
            }

            QModelIndex idx = index(i, 0);
            emit dataChanged(idx, idx, {NameRole, IsHiddenRole, ItemCountRole});
            return;
        }
    }
}


// Validates uniqueness and inserts a new group into the local list
void AdvVpnGroupModel::addGroupLocally(const QString &groupName)
{
    QString trimmedName = groupName.trimmed();

    if (duplicateNameExists(trimmedName)) {
        emit conflictsDetected(
            {QString("'%1' is already present, cannot add it").arg(trimmedName)}
            );
        return;
    }

    AdvVpnGroup *newGroup = new AdvVpnGroup(trimmedName);

    beginInsertRows(QModelIndex(), m_groups.count(), m_groups.count());
    m_groups.append(newGroup);
    endInsertRows();

}

// Removes a group from the local list based on its name
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

// Updates the name of an existing group locally and notifies the view
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

// Adds an IP address to a specific group locally and notifies the view
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


// Checks if a group name already exists in the model (case-insensitive)
bool AdvVpnGroupModel::duplicateNameExists(const QString &groupName) const
{
    if (groupName.trimmed().isEmpty()) return false;

    QString trimmedName = groupName.trimmed();

    for (const auto &group : m_groups) {
        if (group->name().compare(trimmedName, Qt::CaseInsensitive) == 0){
            return true;
        }
    }
    return false;
}

// Emits the conflictsDetected signal with the provided message list
void AdvVpnGroupModel::raiseConflicts(const QStringList &msg)
{
    if (!msg.isEmpty()) emit conflictsDetected(msg);
}


// Updates the internal hash map used to resolve IPs to Common Names
void AdvVpnGroupModel::setIpToCn(const QHash<QString, QString> &map)
{
    m_ipToCn = map;
}


// Converts all group objects in the model to a JSON array
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

#include "advvpngroupmodel.h"
#include "advvpngroup.h"
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
        // Use -> to access pointer members
        if (m_groups[i]->name() == oldName) {
            // Use the setter function, not assignment to the getter
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

    // 1. Controllo duplicati locale
    for (const auto &group : m_groups) {
        if (group->name().compare(trimmedName, Qt::CaseInsensitive) == 0) return;
    }

    // 2. Creazione dell'oggetto con il nome richiesto
    AdvVpnGroup *newGroup = new AdvVpnGroup(trimmedName);

    // 3. Notifica alla View l'inserimento
    beginInsertRows(QModelIndex(), m_groups.count(), m_groups.count());
    m_groups.append(newGroup);
    endInsertRows();

    qInfo() << "📁 Gruppo aggiunto in staging:" << trimmedName;

}

void AdvVpnGroupModel::addIpToGroupLocally(const QString &groupName, const QString &ipAddress)
{
    for (int i = 0; i < m_groups.count(); ++i) {
        if (m_groups[i]->name() == groupName) { // Corretto con ->
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
        if (m_groups[i]->name() == groupName) { // Corretto con ->
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
            // Qui chiamiamo il metodo toJson() che abbiamo aggiunto prima alla classe AdvVpnGroup
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
    if (!index.isValid()) return {};
    const int r = index.row();
    if (r < 0 || r >= m_groups.size()) return {};

    auto *group = m_groups.at(r);
    if (!group) return {};

    switch (role) {
    case Qt::DisplayRole:
        return QString("%1 (%2)").arg(group->name()).arg(group->itemCount());
    case NameRole:
        return group->name();
    case ItemCountRole:
        return group->itemCount();
    default:
        return {};
    }
}

// Maps internal model roles to string names usable in QML.
QHash<int, QByteArray> AdvVpnGroupModel::roleNames() const
{
    return {
        { NameRole, "name" },
        { ItemCountRole, "itemCount" }
    };
}



#include "advvpnitemmodel.h"
#include "advvpngroupmodel.h"
#include "advvpngroup.h"
#include "advvpnitem.h"
#include <QDebug>


// Constructor: initializes the model with an optional parent
AdvVpnItemModel::AdvVpnItemModel(QObject *parent)
    : QAbstractListModel(parent), m_group(nullptr), m_groupModel(nullptr)
{
}


// Returns the total number of items in the currently selected group
int AdvVpnItemModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid() || !m_group) return 0;
    return m_group->items().size();
}

// Retrieves data for a specific index and role (Kind, Visibility, Value, or Common Name)
QVariant AdvVpnItemModel::data(const QModelIndex &index, int role) const
{
    if (!m_group || !index.isValid()) return QVariant();
    const int row = index.row();
    const auto &items = m_group->items();
    if (row < 0 || row >= items.size()) return QVariant();

    const AdvVpnItem *item = items.at(row);
    if (!item) return QVariant();
    const QString rawValue = item->toString();

    switch (role) {
    case KindRole:
        if (item->kind() == AdvVpnItem::Kind::Address) return "addr";
        if (item->kind() == AdvVpnItem::Kind::Net) return "net";
        if (item->kind() == AdvVpnItem::Kind::Range) return "range";
        return "unknown";
    case ValueRole: return rawValue;
    case CnRole: return m_ipToCn.value(rawValue, QString());
    case IsHiddenRole: return item->isHidden();
    case TooltipRole: return rawValue;
    case Qt::DisplayRole: return rawValue;
    default: return QVariant();
    }
}

// Maps internal model roles to string names usable in QML
QHash<int, QByteArray> AdvVpnItemModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[KindRole] = "kind";
    roles[IsHiddenRole] = "isHidden";
    roles[ValueRole] = "value";
    roles[CnRole] = "cn";
    roles[TooltipRole] = "tooltip";
    roles[Qt::DisplayRole] = "display";
    return roles;
}

// Clears the current group selection and resets the model
void AdvVpnItemModel::clear()
{
    beginResetModel();
    m_group = nullptr;
    m_groupIndex = -1;
    endResetModel();
}


// Updates the currently selected group by its row index from the GroupModel
void AdvVpnItemModel::setGroupIndex(int row)
{
    if (!m_groupModel) return;

    m_groupIndex = row;
    AdvVpnGroup *newGroup = m_groupModel->groupAt(row);

    beginResetModel();
    m_group = newGroup;
    endResetModel();
}

// Sets the pointer to the main GroupModel
void AdvVpnItemModel::setGroupModel(AdvVpnGroupModel *groupModel)
{
    m_groupModel = groupModel;
}

// Returns the name of the currently active group
QString AdvVpnItemModel::currentGroupName() const
{
    return m_group ? m_group->name() : QString();
}

int AdvVpnItemModel::currentGroupIndex() const
{
    return m_groupIndex;
}


// Creates a new VPN item from an IP string and adds it to the current group
void AdvVpnItemModel::addIpLocally(const QString &ipAddress)
{
    if (!m_group) return;

    QString error;
    AdvVpnItem *newItem = AdvVpnItem::fromString(ipAddress, &error);
    if (!newItem) return;

    int newRow = m_group->items().size();
    beginInsertRows(QModelIndex(), newRow, newRow);
    m_group->addItem(newItem);
    endInsertRows();

    if (m_groupModel) {
        m_groupModel->addIpToGroupLocally(m_group->name(), ipAddress);
    }
}

// Renames an existing IP address within the group locally
void AdvVpnItemModel::renameIpLocally(const QString &oldIp, const QString &newIp)
{
    if (!m_group) return;
    auto &items = const_cast<QList<AdvVpnItem*>&>(m_group->items());

    for (int i = 0; i < items.count(); ++i) {
        if (items[i]->toString() == oldIp) {
            QString error;
            AdvVpnItem *newItem = AdvVpnItem::fromString(newIp, &error);
            if (newItem) {
                AdvVpnItem *oldItem = items[i];
                items[i] = newItem;
                delete oldItem;
                QModelIndex idx = index(i, 0);
                emit dataChanged(idx, idx, {Qt::DisplayRole, ValueRole});
            }
            break;
        }
    }
}

// Updates the Common Name (ID) for a specific IP locally
void AdvVpnItemModel::updateCnLocally(const QString &ip, const QString &newCn) {
    if (!m_group) return;

    m_ipToCn.insert(ip, newCn);

    const auto &items = m_group->items();
    for (int i = 0; i < items.count(); ++i) {
        if (items[i]->toString() == ip) {
            QModelIndex idx = index(i, 0);
            emit dataChanged(idx, idx, {CnRole, Qt::DisplayRole});
            break;
        }
    }
}

// Removes an IP address from the current group list locally
void AdvVpnItemModel::removeIpLocally(const QString &ipAddress)
{
    if (!m_group) return;
    auto &items = const_cast<QList<AdvVpnItem*>&>(m_group->items());
    QString target = ipAddress.trimmed();

    for (int i = 0; i < items.count(); ++i) {
        if (items[i]->toString() == target) {
            beginRemoveRows(QModelIndex(), i, i);
            AdvVpnItem *item = items.takeAt(i);
            delete item;
            endRemoveRows();
            return;
        }
    }
}

// Sets the hidden status of a specific item and notifies both Item and Group models
void AdvVpnItemModel::setItemHidden(const QString &ip, bool hide)
{
    if (!m_group) return;
    const auto &items = m_group->items();

    for (int i = 0; i < items.count(); ++i) {
        if (items[i]->toString() == ip) {
            items[i]->setHidden(hide);

            QModelIndex idx = index(i, 0);
            emit dataChanged(idx, idx, {IsHiddenRole});

            if (m_groupModel && m_groupIndex != -1) {
                QModelIndex gIdx = m_groupModel->index(m_groupIndex, 0);
                emit m_groupModel->dataChanged(gIdx, gIdx, {AdvVpnGroupModel::ItemCountRole});
            }
            return;
        }
    }
}


// Performs a reverse lookup to find the IP associated with a specific Common Name
QString AdvVpnItemModel::getIpForCn(const QString &cn) const
{
    if (cn.trimmed().isEmpty()) return QString();
    return m_ipToCn.key(cn.trimmed());
}

// Checks if an IP already exists in the current group, with an optional exclusion
bool AdvVpnItemModel::ipExistsInCurrentGroup(const QString &ip, const QString &excludeIp) const {
    if (!m_group) return false;

    QString target = ip.trimmed();
    const auto &items = m_group->items();

    for (const auto *item : items) {
        QString currentItemIp = item->toString();

        if (!excludeIp.isEmpty() && currentItemIp == excludeIp) {
            continue;
        }

        if (currentItemIp == target) {
            return true;
        }
    }
    return false;
}

// Updates the internal IP-to-CN mapping and notifies the view of the data change
void AdvVpnItemModel::setIpToCn(const QHash<QString, QString> &map)
{
    m_ipToCn = map;
    if (rowCount() > 0) {
        emit dataChanged(index(0, 0), index(rowCount() - 1, 0), {CnRole, ValueRole, Qt::DisplayRole});
    }
}

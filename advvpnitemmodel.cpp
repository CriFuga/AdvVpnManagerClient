#include "advvpnitemmodel.h"
#include "advvpngroupmodel.h"
#include "advvpngroup.h"
#include "advvpnitem.h"
#include <QDebug>

AdvVpnItemModel::AdvVpnItemModel(QObject *parent)
    : QAbstractListModel(parent), m_group(nullptr), m_groupModel(nullptr)
{
}

void AdvVpnItemModel::setGroupIndex(int row)
{
    if (!m_groupModel) return;

    m_groupIndex = row;
    AdvVpnGroup *newGroup = m_groupModel->groupAt(row);

    beginResetModel();
    m_group = newGroup;
    endResetModel();
}

void AdvVpnItemModel::setGroupModel(AdvVpnGroupModel *groupModel)
{
    m_groupModel = groupModel;
}

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
            qInfo() << "🗑️ GUI: Rimosso con successo" << target;
            return;
        }
    }
}



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

void AdvVpnItemModel::setIpToCn(const QHash<QString, QString> &map)
{
    m_ipToCn = map;
    if (rowCount() > 0) {
        emit dataChanged(index(0, 0), index(rowCount() - 1, 0), {CnRole, ValueRole, Qt::DisplayRole});
    }
}

void AdvVpnItemModel::clear()
{
    beginResetModel();
    m_group = nullptr;
    m_groupIndex = -1;
    endResetModel();
}

QString AdvVpnItemModel::currentGroupName() const
{
    return m_group ? m_group->name() : QString();
}

int AdvVpnItemModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid() || !m_group) return 0;
    return m_group->items().size();
}

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
    case IsHiddenRole: return item->isHidden(); // <--- AGGIUNGI QUESTO
    case TooltipRole: return rawValue;
    case Qt::DisplayRole: return rawValue;
    default: return QVariant();
    }
}

QHash<int, QByteArray> AdvVpnItemModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[KindRole] = "kind";
    roles[IsHiddenRole] = "isHidden"; // <--- AGGIUNGI QUESTO
    roles[ValueRole] = "value";
    roles[CnRole] = "cn";
    roles[TooltipRole] = "tooltip";
    roles[Qt::DisplayRole] = "display";
    return roles;
}

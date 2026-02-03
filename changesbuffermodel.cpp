#include "changesbuffermodel.h"

ChangesBufferModel::ChangesBufferModel(ChangesBufferManager *manager, QObject *parent)
    : QAbstractListModel(parent)
    , m_manager(manager)
{
    if (m_manager) {
        connect(m_manager, &ChangesBufferManager::bufferUpdated, this, &ChangesBufferModel::updateFullBuffer);
    }
}

int ChangesBufferModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid() || !m_manager) return 0;
    return m_manager->count();
}

QVariant ChangesBufferModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || !m_manager) return QVariant();

    const auto actions = m_manager->buffer();
    if (index.row() >= actions.count()) return QVariant();

    const VpnAction &action = actions.at(index.row());

    switch (role) {
    case TypeRole:
        return action.type; // Restituisce l'enum (0-6)
    case TargetIdRole:
        return action.targetId;
    case DescriptionRole:
        return action.description;
    case GroupIdRole:
        return action.groupId;
    case IsGroupActionRole:
        // Utile nel QML per dare uno stile diverso se è un'azione su un Gruppo
        return (action.type == VpnAction::CreateGroup ||
                action.type == VpnAction::DeleteGroup ||
                action.type == VpnAction::RenameGroup);
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> ChangesBufferModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[TypeRole] = "type";
    roles[TargetIdRole] = "targetId";
    roles[DescriptionRole] = "description";
    roles[GroupIdRole] = "groupId";
    roles[IsGroupActionRole] = "isGroupAction";
    return roles;
}

void ChangesBufferModel::undo(int index)
{
    if (m_manager) {
        m_manager->undoAction(index);
    }
}

void ChangesBufferModel::updateFullBuffer()
{
    // Usiamo layoutChanged per notificare alla ListView di QML di rinfrescare l'intera lista
    // Se volessimo animazioni chirurgiche useremmo beginInsertRows/beginRemoveRows
    emit layoutAboutToBeChanged();
    emit layoutChanged();
}

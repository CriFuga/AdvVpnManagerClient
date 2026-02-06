#include "changesbuffermodel.h"

// Constructor: links the model to the manager and connects the update signal
ChangesBufferModel::ChangesBufferModel(ChangesBufferManager *manager, QObject *parent)
    : QAbstractListModel(parent)
    , m_manager(manager)
{
    if (m_manager) {
        connect(m_manager, &ChangesBufferManager::bufferUpdated, this, &ChangesBufferModel::updateFullBuffer);
    }
}

// Returns the total number of actions currently staged in the buffer manager
int ChangesBufferModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid() || !m_manager) return 0;
    return m_manager->count();
}

// Provides data to the QML view for each role based on the current action index
QVariant ChangesBufferModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || !m_manager) return QVariant();

    const auto actions = m_manager->buffer();
    if (index.row() >= actions.count()) return QVariant();

    const VpnAction &action = actions.at(index.row());

    switch (role) {
    case TypeRole:
        return action.type;
    case TargetIdRole:
        return action.targetId;
    case DescriptionRole:
        return action.description;
    case GroupIdRole:
        return action.groupId;
    case IsGroupActionRole:
        return (action.type == VpnAction::CreateGroup ||
                action.type == VpnAction::DeleteGroup ||
                action.type == VpnAction::RenameGroup);
    default:
        return QVariant();
    }
}

// Maps internal model roles to string property names accessible within QML
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

// Invokes the undo operation for a specific action index through the manager
void ChangesBufferModel::undo(int index)
{
    if (m_manager) {
        m_manager->undoAction(index);
    }
}

// Notifies the view that the underlying buffer data has changed and requires a full refresh
void ChangesBufferModel::updateFullBuffer()
{
    emit layoutAboutToBeChanged();
    emit layoutChanged();
}

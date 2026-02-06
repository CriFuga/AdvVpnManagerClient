#include "changesbuffermanager.h"
#include <QDebug>


// Constructor
ChangesBufferManager::ChangesBufferManager(QObject *parent)
    : QObject(parent)
{
}


// Adds a new action to the buffer and applies optimization logic to handle redundant steps
void ChangesBufferManager::addAction(const VpnAction &actionInput)
{
    VpnAction finalAction = actionInput;

    if (finalAction.type == VpnAction::DeleteIp) {
        for (int i = m_buffer.count() - 1; i >= 0; --i) {
            const VpnAction &existing = m_buffer.at(i);
            if (existing.type == VpnAction::UpdateIp && existing.newValue == finalAction.targetId) {
                finalAction.targetId = existing.targetId;
                finalAction.description = QString("Removed IP %1").arg(existing.targetId);
                m_buffer.removeAt(i);
                continue;
            }
            if (existing.targetId == actionInput.targetId && existing.type != VpnAction::UpdateIp) {
                m_buffer.removeAt(i);
            }
        }
    }
    optimizeBuffer(finalAction);

    m_buffer.append(finalAction);
    emit bufferUpdated();
    emit countChanged();
}

// Removes a specific action from the buffer and triggers a rollback signal
void ChangesBufferManager::undoAction(int index)
{
    if (index < 0 || index >= m_buffer.count())
        return;

    VpnAction actionToUndo = m_buffer.takeAt(index);
    emit actionUndone(actionToUndo);

    emit bufferUpdated();
    emit countChanged();
}

// Removes all pending actions belonging to a specific group
void ChangesBufferManager::undoGroupActions(const QString &groupName)
{
    for (int i = m_buffer.count() - 1; i >= 0; --i) {
        if (m_buffer[i].groupId == groupName) {
            m_buffer.removeAt(i);
        }
    }
    emit bufferUpdated();
    emit countChanged();
}

// Removes actions related to a group (usually called when the entire group is deleted)
void ChangesBufferManager::removeActionsRelatedToGroup(const QString &groupName)
{
    for (int i = m_buffer.count() - 1; i >= 0; --i) {
        if (m_buffer[i].groupId == groupName) {
            m_buffer.removeAt(i);
        }
    }
    emit bufferUpdated();
    emit countChanged();
}

// Clears the entire buffer
void ChangesBufferManager::clear()
{
    m_buffer.clear();
    emit bufferUpdated();
    emit countChanged();
}

// Returns the full list of actions currently in the buffer
QList<VpnAction> ChangesBufferManager::buffer() const
{
    return m_buffer;
}

// Returns the number of pending actions
int ChangesBufferManager::count() const
{
    return m_buffer.count();
}

// Removes pending actions that are rendered obsolete by a new incoming action
void ChangesBufferManager::optimizeBuffer(const VpnAction &newAction)
{
    for (int i = m_buffer.count() - 1; i >= 0; --i) {
        const VpnAction &existing = m_buffer.at(i);
        if (existing.targetId == newAction.targetId) {
            if (newAction.type == VpnAction::DeleteIp) {
                m_buffer.removeAt(i);
                continue;
            }
            if (newAction.type == VpnAction::UpdateId && existing.type == VpnAction::UpdateId) {
                m_buffer.removeAt(i);
                continue;
            }
        }
    }
}

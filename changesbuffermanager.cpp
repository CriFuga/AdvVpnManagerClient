#include "changesbuffermanager.h"
#include <algorithm>
#include <QDebug>

ChangesBufferManager::ChangesBufferManager(QObject *parent)
    : QObject(parent)
{
}

void ChangesBufferManager::addAction(const VpnAction &newAction)
{
    // 1. Applichiamo la logica di ottimizzazione prima di aggiungere
    optimizeBuffer(newAction);

    // 2. Se l'azione non è stata "annullata" dall'ottimizzazione (es. ADD + DELETE), la aggiungiamo
    // Nota: in caso di DELETE, optimizeBuffer rimuove gli UPDATE, ma il DELETE va comunque aggiunto
    m_buffer.append(newAction);

    qDebug() << "ChangesBuffer: Aggiunta azione" << newAction.description << "| Totale:" << m_buffer.count();

    emit bufferUpdated();
    emit countChanged();
}

void ChangesBufferManager::optimizeBuffer(const VpnAction &newAction)
{
    auto it = m_buffer.begin();
    while (it != m_buffer.end()) {
        bool shouldRemove = false;

        // Caso A: Se la nuova azione è un DELETE, rimuoviamo precedenti ADD o UPDATE dello stesso target
        if (newAction.type == VpnAction::DeleteIp || newAction.type == VpnAction::DeleteGroup) {
            if (it->targetId == newAction.targetId) {
                // Se stiamo eliminando qualcosa che avevamo appena creato, sparisce tutto (ADD + DELETE = NULL)
                if (it->type == VpnAction::AddIp || it->type == VpnAction::CreateGroup) {
                    it = m_buffer.erase(it);
                    // Non aggiungeremo nemmeno la DeleteAction perché l'oggetto non esiste sul cloud
                    // (Gestito dal chiamante o aggiungendo un flag 'skip')
                    continue;
                }
                // Se era un UPDATE, lo rimuoviamo: conta solo la cancellazione finale
                shouldRemove = true;
            }
        }

        // Caso B: Se modifichiamo lo stesso valore più volte, teniamo solo l'ultima modifica
        if (newAction.type == VpnAction::UpdateIp || newAction.type == VpnAction::UpdateId) {
            if (it->targetId == newAction.targetId && it->type == newAction.type) {
                shouldRemove = true;
            }
        }

        if (shouldRemove) {
            it = m_buffer.erase(it);
        } else {
            ++it;
        }
    }
}

void ChangesBufferManager::undoAction(int index)
{
    if (index < 0 || index >= m_buffer.count()) return;

    VpnAction action = m_buffer.at(index);

    // Notifichiamo il controller PRIMA di eliminare i dati
    emit actionUndone(action);

    if (action.type == VpnAction::CreateGroup) {
        undoGroupActions(action.targetId);
    } else {
        m_buffer.removeAt(index);
    }

    emit bufferUpdated();
    emit countChanged();
}

void ChangesBufferManager::undoGroupActions(const QString &groupName) {
    // Cerchiamo tutte le azioni nel buffer che riguardano questo gruppo
    // (comprese le eliminazioni degli IP che abbiamo fatto automaticamente)
    for (int i = m_buffer.count() - 1; i >= 0; --i) {
        VpnAction action = m_buffer.at(i);

        // Se l'azione riguarda un IP eliminato di quel gruppo o il gruppo stesso
        if (action.targetId == groupName || action.description.contains(groupName)) {
            emit actionUndone(action); // Notifica il controller per rimettere l'IP nel modello
            m_buffer.removeAt(i);
        }
    }
}

void ChangesBufferManager::removeActionsRelatedToGroup(const QString &groupName)
{
    for (int i = m_buffer.count() - 1; i >= 0; --i) {
        // Se l'azione riguarda un IP che appartiene a questo gruppo (usando groupId)
        if (m_buffer.at(i).groupId == groupName) {
            m_buffer.removeAt(i);
        }
    }
    emit bufferUpdated();
    emit countChanged();
}

void ChangesBufferManager::clear()
{
    m_buffer.clear(); emit countChanged();
}

QList<VpnAction> ChangesBufferManager::buffer() const
{
    return m_buffer;
}

int ChangesBufferManager::count() const
{
    return m_buffer.count();
}

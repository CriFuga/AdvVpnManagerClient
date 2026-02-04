#include "changesbuffermanager.h"
#include <QDebug>

ChangesBufferManager::ChangesBufferManager(QObject *parent)
    : QObject(parent)
{
}

void ChangesBufferManager::addAction(const VpnAction &actionInput)
{
    VpnAction finalAction = actionInput;

    // --- FIX LOGICA: Rinomina seguita da Eliminazione ---
    // Se l'utente rinomina A -> B e poi cancella B, nel buffer deve rimanere solo "Cancella A".
    if (finalAction.type == VpnAction::DeleteIp) {

        // Scorriamo il buffer al contrario per trovare la storia di questo IP
        for (int i = m_buffer.count() - 1; i >= 0; --i) {
            const VpnAction &existing = m_buffer.at(i);

            // Caso 1: Troviamo una Rinomina (UpdateIp) che ha generato l'IP che stiamo cancellando
            // Es: existing è "A -> B", finalAction è "Delete B"
            if (existing.type == VpnAction::UpdateIp && existing.newValue == finalAction.targetId) {

                qDebug() << "🔄 Merge Delete su Rinomina: Trovata sequenza [Rinomina -> Elimina]. Ripristino target originale:" << existing.targetId;

                // 1. Reindirizziamo la cancellazione all'IP originale (A)
                finalAction.targetId = existing.targetId;
                finalAction.description = QString("Rimosso IP %1").arg(existing.targetId);

                // 2. Rimuoviamo l'azione di rinomina dal buffer (perché è stata annullata dall'eliminazione)
                m_buffer.removeAt(i);

                // Nota: continuiamo il ciclo nel caso ci siano altre azioni intermedie o catene di rinomine
                continue;
            }

            // Caso 2: Pulizia di azioni intermedie fatte sull'IP provvisorio (B)
            // Se avevamo assegnato un ID a B prima di cancellarlo, quell'azione è inutile ora
            if (existing.targetId == actionInput.targetId && existing.type != VpnAction::UpdateIp) {
                m_buffer.removeAt(i);
            }
        }
    }

    // --- Ottimizzazione Standard ---
    // Rimuove duplicati o sovrascritture (es. due cambi di ID sullo stesso IP)
    optimizeBuffer(finalAction);

    m_buffer.append(finalAction);
    emit bufferUpdated();
    emit countChanged();
}

void ChangesBufferManager::undoAction(int index)
{
    if (index < 0 || index >= m_buffer.count())
        return;

    VpnAction actionToUndo = m_buffer.takeAt(index);
    emit actionUndone(actionToUndo);

    emit bufferUpdated();
    emit countChanged();
}

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

void ChangesBufferManager::removeActionsRelatedToGroup(const QString &groupName)
{
    // Usata quando si cancella un intero gruppo: rimuove le azioni pendenti di quel gruppo
    for (int i = m_buffer.count() - 1; i >= 0; --i) {
        if (m_buffer[i].groupId == groupName) {
            m_buffer.removeAt(i);
        }
    }
    emit bufferUpdated();
    emit countChanged();
}

void ChangesBufferManager::clear()
{
    m_buffer.clear();
    emit bufferUpdated();
    emit countChanged();
}

QList<VpnAction> ChangesBufferManager::buffer() const
{
    return m_buffer;
}

int ChangesBufferManager::count() const
{
    return m_buffer.count();
}

void ChangesBufferManager::optimizeBuffer(const VpnAction &newAction)
{
    // Scorre il buffer al contrario per rimuovere azioni rese obsolete dalla nuova azione
    for (int i = m_buffer.count() - 1; i >= 0; --i) {
        const VpnAction &existing = m_buffer.at(i);

        // Se l'azione riguarda lo stesso target (IP)
        if (existing.targetId == newAction.targetId) {

            // Se la nuova azione è DELETE, vince su tutto (UpdateId, UpdateGroup, ecc.)
            // Nota: La rinomina è gestita separatamente in addAction
            if (newAction.type == VpnAction::DeleteIp) {
                m_buffer.removeAt(i);
                continue;
            }

            // Se stiamo aggiornando l'ID e c'era già un aggiornamento ID pendente, teniamo solo l'ultimo
            if (newAction.type == VpnAction::UpdateId && existing.type == VpnAction::UpdateId) {
                m_buffer.removeAt(i);
                continue;
            }
        }
    }
}

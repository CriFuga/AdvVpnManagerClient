#ifndef CHANGESBUFFERMANAGER_H
#define CHANGESBUFFERMANAGER_H

#include <QObject>
#include <QList>
#include "vpnaction.h"

class ChangesBufferManager : public QObject {
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    explicit ChangesBufferManager(QObject *parent = nullptr);

    // Aggiunge un'azione e pulisce quelle ridondanti
    void addAction(const VpnAction &action);

    // Rimuove un'azione specifica (Undo)
    void undoAction(int index);

    // Se faccio undo su un gruppo, rimuovo tutti i figli
    void undoGroupActions(const QString &groupName);

    void removeActionsRelatedToGroup(const QString &groupName);

    void clear();

    QList<VpnAction> buffer() const;
    int count() const;

signals:
    void countChanged();
    void bufferUpdated();
    void actionUndone(const VpnAction &action);
private:
    QList<VpnAction> m_buffer;

    // Funzione interna per ottimizzare il buffer
    void optimizeBuffer(const VpnAction &newAction);
};

#endif // CHANGESBUFFERMANAGER_H

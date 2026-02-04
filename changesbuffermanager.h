#ifndef CHANGESBUFFERMANAGER_H
#define CHANGESBUFFERMANAGER_H

#include <QObject>
#include <QList>
#include "vpnaction.h"

class ChangesBufferManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    explicit ChangesBufferManager(QObject *parent = nullptr);

    // Funzioni principali
    void addAction(const VpnAction &action);
    void undoAction(int index);
    void undoGroupActions(const QString &groupName);
    void removeActionsRelatedToGroup(const QString &groupName);
    void clear();

    // Getter per i modelli
    QList<VpnAction> buffer() const;
    int count() const;

signals:
    void countChanged();
    void bufferUpdated();
    void actionUndone(const VpnAction &action);

private:
    QList<VpnAction> m_buffer;
    void optimizeBuffer(const VpnAction &newAction);
};

#endif // CHANGESBUFFERMANAGER_H

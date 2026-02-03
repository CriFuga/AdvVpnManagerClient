#ifndef VPNACTION_H
#define VPNACTION_H

#include <QString>
#include <QVariant>

struct VpnAction {
    enum Type {
        CreateGroup, DeleteGroup, RenameGroup,
        AddIp, DeleteIp, UpdateIp, UpdateId
    };

    Type type;
    QString groupId;      // Il "padre" dell'azione (nome gruppo)
    QString targetId;     // L'ID dell'oggetto (IP o nome gruppo)
    QVariant oldValue;    // Valore precedente
    QVariant newValue;    // Nuovo valore
    QString description;  // Testo per la UI
};

// AGGIUNGI QUESTA LINEA QUI:
QString actionTypeToString(VpnAction::Type type);

#endif // VPNACTION_H

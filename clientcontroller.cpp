#include "clientcontroller.h"
#include "advvpngroupmodel.h"
#include "advvpnitemmodel.h"
#include "advvpnsocket.h"
#include "advvpngroup.h"
#include <QJsonArray>
#include <QRegularExpression>
#include <QJsonDocument>
#include <QDebug>

ClientController::ClientController(AdvVpnGroupModel *groupModel, AdvVpnItemModel *itemModel, QObject *parent)
    : QObject(parent), m_groupModel(groupModel), m_itemModel(itemModel)
{
    // Inizializziamo il buffer e il modello per la UI del Sync
    m_changesBuffer = new ChangesBufferManager(this);
    m_syncModel = new ChangesBufferModel(m_changesBuffer, this);

    setupBufferConnections();

    // Colleghiamo il conteggio dei cambiamenti per il badge della UI
    connect(m_changesBuffer, &ChangesBufferManager::countChanged, this, &ClientController::pendingChangesCountChanged);

    auto socket = AdvVpnSocket::instance();
    if (socket) {
        connect(socket, &AdvVpnSocket::syncDataReceived, this, &ClientController::onSyncDataReceived);
    }
}

// --- GESTIONE CONNESSIONE ---

void ClientController::start() {
    if (auto socket = AdvVpnSocket::instance()) {
        socket->openConnection();
    }
}

// --- API RICHIESTE (SCRITTURA NEL BUFFER) ---

void ClientController::sendIdUpdate(const QString &ip, const QString &newId) {
    if (ip.isEmpty()) return;

    // 1. Normalizzazione (già presente nel tuo codice)
    QString cleanIp = ip.trimmed();
    QHostAddress address(cleanIp);
    if (!address.isNull() && address.protocol() == QAbstractSocket::IPv4Protocol) {
        cleanIp = address.toString();
    }

    QString cleanId = newId.trimmed();

    // 2. --- IL GUARDIANO (MANCANTE NEL TUO FILE) ---
    if (!cleanId.isEmpty()) {
        QString ownerIp = m_itemModel->getIpForCn(cleanId);

        // Se l'ID è già di qualcun altro, fermiamo tutto QUI
        if (!ownerIp.isEmpty() && ownerIp != cleanIp) {
            qWarning() << "⛔ ID duplicato bloccato:" << cleanId;

            // Questo segnale attiva il toast rosso in Main.qml
            emit errorsOccurred("L'ID '" + cleanId + "' è già usato dall'IP " + ownerIp);

            return; // 🛑 ESCE: non aggiorna il modello, non scrive nel buffer
        }
    }

    // 3. Procede solo se l'ID è univoco o vuoto
    VpnAction a;
    a.type = VpnAction::UpdateId;
    a.targetId = cleanIp;
    a.newValue = cleanId;
    a.groupId = m_itemModel->currentGroupName();
    a.description = QString("Assegnato ID '%1' a %2").arg(cleanId.isEmpty() ? "Vuoto" : cleanId, cleanIp);

    m_changesBuffer->addAction(a);
    m_itemModel->updateCnLocally(cleanIp, cleanId); // Aggiorna la lista principale

    emit availableCnsChanged(); // Aggiorna i suggerimenti live
    emit pendingChangesCountChanged();
}
void ClientController::addGroupRequest(const QString &groupName) {
    QString name = groupName.trimmed();
    if (name.isEmpty()) return;

    VpnAction a;
    a.type = VpnAction::CreateGroup;
    a.targetId = name;
    a.description = "Nuovo gruppo: " + name;

    m_changesBuffer->addAction(a);
    m_groupModel->addGroupLocally(name);
}

void ClientController::addIpRequest(const QString &groupName, const QString &ipAddress) {
    if (groupName.isEmpty() || ipAddress.trimmed().isEmpty()) return;

    VpnAction a;
    a.type = VpnAction::AddIp;
    a.targetId = ipAddress.trimmed();
    a.groupId = groupName;
    a.description = QString("Aggiunto IP %1 a %2").arg(ipAddress, groupName);

    m_changesBuffer->addAction(a);
    m_itemModel->addIpLocally(ipAddress.trimmed());
}

void ClientController::removeGroupRequest(const QString &groupName) {
    if (groupName.isEmpty()) return;

    m_changesBuffer->removeActionsRelatedToGroup(groupName);

    VpnAction a;
    a.type = VpnAction::DeleteGroup;
    a.targetId = groupName;
    a.description = "Eliminazione gruppo: " + groupName;
    m_changesBuffer->addAction(a);
    m_groupModel->setGroupHidden(groupName, true);
}

void ClientController::renameGroupRequest(const QString &oldName, const QString &newName) {
    if (oldName == newName || newName.trimmed().isEmpty()) return;

    VpnAction a;
    a.type = VpnAction::RenameGroup;
    a.targetId = oldName;
    a.newValue = newName.trimmed();
    a.description = QString("Rinominato %1 -> %2").arg(oldName, newName);

    m_changesBuffer->addAction(a);
    m_groupModel->updateGroupNameLocally(oldName, newName.trimmed());
}

void ClientController::requestRemoveIp(const QString &groupName, const QString &ipAddress) {
    if (groupName.isEmpty() || ipAddress.isEmpty()) return;

    VpnAction a;
    a.type = VpnAction::DeleteIp;
    a.targetId = ipAddress;
    a.groupId = groupName;
    a.description = QString("Rimosso IP %1 da %2").arg(ipAddress, groupName);

    m_itemModel->setItemHidden(ipAddress, true);
    m_changesBuffer->addAction(a);
    qDebug() << "❌ IP Nascosto e azione aggiunta:" << ipAddress << "nel gruppo" << groupName;
}

void ClientController::updateIpRequest(const QString &oldIp, const QString &newIp) {
    if (oldIp == newIp || newIp.trimmed().isEmpty()) return;

    VpnAction a;
    a.type = VpnAction::UpdateIp;
    a.targetId = oldIp;
    a.newValue = newIp.trimmed();
    a.groupId = m_itemModel->currentGroupName();
    a.description = QString("Cambiato IP: %1 -> %2").arg(oldIp, newIp);

    m_changesBuffer->addAction(a);
    m_itemModel->renameIpLocally(oldIp, newIp.trimmed());
}

void ClientController::selectGroupFromProxy(int proxyRow) {
    if (!m_groupProxy || proxyRow < 0) return;

    QModelIndex proxyIndex = m_groupProxy->index(proxyRow, 0);

    QModelIndex sourceIndex = m_groupProxy->mapToSource(proxyIndex);

    m_itemModel->setGroupIndex(sourceIndex.row());

    qDebug() << "Mappato proxy row" << proxyRow << "a source row" << sourceIndex.row();
}

// --- SYNC E DISCARD ---

void ClientController::commitSync() {
    auto actions = m_changesBuffer->buffer();
    if (actions.isEmpty()) return;

    QJsonObject root;
    root["type"] = "BULK_SYNC_REQUEST";
    QJsonArray changes;

    for (const auto &a : actions) {
        QJsonObject op;
        op["op"] = actionTypeToString(a.type);
        QJsonObject data;
        data["target"] = a.targetId;
        data["value"] = a.newValue.toString();
        data["parent"] = a.groupId;
        op["data"] = data;
        changes.append(op);
    }
    root["changes"] = changes;

    // Debugging del pacchetto in uscita
    QJsonDocument doc(root);
    qDebug().noquote() << "📤 INVIO BULK SYNC:\n" << doc.toJson(QJsonDocument::Indented);

    if (auto s = AdvVpnSocket::instance()) {
        s->sendJson(root);
        m_changesBuffer->clear();
        emit pendingChangesCountChanged();
    }
}

void ClientController::discardChanges() {
    m_changesBuffer->clear();
    emit pendingChangesCountChanged();

    // Ricarichiamo tutto dal server per annullare le modifiche locali "non committate"
    if (auto socket = AdvVpnSocket::instance()) {
        QJsonObject req;
        req["type"] = "FETCH_FULL_STATE";
        socket->sendJson(req);
    }
}

void ClientController::clearConflicts() {
    if (!m_conflictMessages.isEmpty()) {
        m_conflictMessages.clear();
        emit conflictMessagesChanged();
    }
}

// --- HELPERS E CALLBACKS ---

QString ClientController::actionTypeToString(VpnAction::Type type) {
    switch(type) {
    case VpnAction::CreateGroup: return "ADD_GROUP";
    case VpnAction::DeleteGroup: return "DEL_GROUP";
    case VpnAction::UpdateId:    return "SET_ID";
    case VpnAction::UpdateIp:    return "RENAME_IP";
    case VpnAction::AddIp:       return "ADD_IP";
    case VpnAction::DeleteIp:    return "DEL_IP";
    case VpnAction::RenameGroup: return "RENAME_GROUP";
    default:                     return "UNKNOWN";
    }
}

void ClientController::onSyncDataReceived(const QJsonObject &data) {
    if (data.contains("errors") || data.contains("conflicts")) {
        QStringList newErrors;
        QJsonArray errArray = data.contains("errors") ? data["errors"].toArray() : data["conflicts"].toArray();

        for (const auto &err : errArray) {
            newErrors.append(err.toString());
        }

        if (!newErrors.isEmpty()) {
            m_conflictMessages = newErrors;
            qDebug() << "📢 CONTROLLER: Conflitti rilevati!" << m_conflictMessages;
            emit conflictMessagesChanged(); // Notifica il QML di mostrare il ConflictDialog
            return; // Blocca l'aggiornamento dei modelli se i dati sono invalidi
        }
    }
    int currentIndex = m_itemModel->currentGroupIndex();

    // Aggiornamento Gruppi
    QJsonArray groupsArr = data["groups"].toArray();
    QList<AdvVpnGroup*> newGroups;
    for(const auto &val : groupsArr) {
        AdvVpnGroup *g = AdvVpnGroup::fromJson(val.toObject());
        if(g) newGroups.append(g);
    }
    m_groupModel->setGroups(newGroups);

    if (currentIndex >= 0) {
        m_itemModel->setGroupIndex(currentIndex);
    }

    // Aggiornamento Mappatura CN/ID
    QJsonArray cnsArr = data["cns"].toArray();
    QHash<QString, QString> serverCnMap;
    QStringList serverCnsList;

    for(const auto &val : cnsArr) {
        QJsonObject obj = val.toObject();
        QString ip = obj["ip"].toString();
        QString cn = obj["cn"].toString();

        if (!ip.isEmpty() && !cn.isEmpty()) {
            serverCnMap.insert(ip, cn);
        }
        if (!cn.isEmpty() && !serverCnsList.contains(cn)) {
            serverCnsList.append(cn);
        }
    }

    m_itemModel->setIpToCn(serverCnMap);
    QStringList filteredCns;
    for(const QString &cn : serverCnsList) {
        // Aggiunge ai suggerimenti solo se l'ID non è associato ad alcun IP
        if (m_itemModel->getIpForCn(cn).isEmpty()) {
            filteredCns.append(cn);
        }
    }

    filteredCns.sort();
    m_availableCns = filteredCns;
    emit availableCnsChanged();
    qInfo() << "Database sincronizzato con successo dal server.";
}

void ClientController::setupBufferConnections() {
    connect(m_changesBuffer, &ChangesBufferManager::countChanged, this, &ClientController::pendingChangesCountChanged);
    connect(m_changesBuffer, &ChangesBufferManager::actionUndone, this, &ClientController::rollbackAction);
}

void ClientController::rollbackAction(const VpnAction &a)
{
    qDebug() << "🔄 Rollback (Visuale) per azione:" << a.description;

    switch(a.type) {
    case VpnAction::DeleteGroup:
        m_groupModel->setGroupHidden(a.targetId, false);
        if (m_groupProxy) {
            m_groupProxy->invalidate();
            m_groupProxy->sort(0, Qt::AscendingOrder);
        }
        break;

    case VpnAction::DeleteIp:
        m_itemModel->setItemHidden(a.targetId, false);
        break;

    case VpnAction::UpdateIp:
        m_itemModel->renameIpLocally(a.newValue.toString(), a.oldValue.toString());
        break;

    case VpnAction::UpdateId:
        m_itemModel->updateCnLocally(a.targetId, a.oldValue.toString());
        break;

    case VpnAction::CreateGroup:
        m_groupModel->setGroupHidden(a.targetId, true);
        break;

    case VpnAction::AddIp:
        m_itemModel->setItemHidden(a.targetId, true);
        break;

    default:
        break;
    }
}

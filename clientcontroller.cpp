#include "clientcontroller.h"
#include "advvpngroupmodel.h"
#include "advvpnitemmodel.h"
#include "advvpngroup.h"
#include "advvpnsocket.h"
#include <QJsonArray>
#include <QDebug>

ClientController::ClientController(AdvVpnGroupModel *groupModel,
                                   AdvVpnItemModel *itemModel,
                                   QObject *parent)
    : QObject(parent)
    , m_groupModel(groupModel)
    , m_itemModel(itemModel)
{
    auto socket = AdvVpnSocket::instance();
    if (socket) {
        connect(socket, &AdvVpnSocket::syncDataReceived,
                this, &ClientController::onSyncDataReceived);

        qInfo() << "✅ ClientController pronto per la sincronizzazione remota.";
    }
}

void ClientController::start()
{
    if (auto socket = AdvVpnSocket::instance()) {
        socket->openConnection();
    }
}

void ClientController::sendCnUpdate(const QString &ip, const QString &newCn)
{
    if (ip.isEmpty()) return;

    // 1. Dati per il payload JSON finale
    QVariantMap data;
    data["ip"] = ip;
    data["cn"] = newCn.trimmed();

    QString desc = QString("Certificato per %1: %2")
                       .arg(ip, newCn.isEmpty() ? "Rimosso" : newCn);

    // 2. Registriamo lo Staging (per il toast e la lista modifiche)
    recordChange("UPDATE_CN_MAPPING", desc, data);

    // 3. AGGIORNAMENTO LOCALE IMMEDIATO (Fondamentale!)
    // Questo deve chiamare una funzione nel tuo AdvVpnItemModel che aggiorna la mappa ip->cn
    if (m_itemModel) {
        m_itemModel->updateCnLocally(ip, newCn.trimmed());
    }

    qInfo() << "📝 Update CN registrato localmente per" << ip << "->" << newCn;
}

void ClientController::addGroupRequest(const QString &groupName)
{
    if (groupName.trimmed().isEmpty()) return;

    // 1. Prepariamo i dati per il Sync futuro
    QVariantMap data;
    data["groupName"] = groupName.trimmed();

    // 2. Registriamo la modifica (Staging)
    recordChange("ADD_GROUP_REQUEST",
                 "Aggiunta nuovo gruppo: " + groupName,
                 data);

    // 3. Aggiorniamo la UI locale immediatamente (Sidebar)
    // Nota: devi aggiungere questo metodo nel tuo AdvVpnGroupModel
    m_groupModel->addGroupLocally(groupName.trimmed());
}

void ClientController::addIpRequest(const QString &groupName, const QString &ipAddress)
{
    if (groupName.isEmpty() || ipAddress.trimmed().isEmpty()) return;

    QVariantMap data;
    data["groupName"] = groupName;
    data["ipAddress"] = ipAddress.trimmed();

    recordChange("ADD_IP_REQUEST", QString("Aggiungi IP %1 a %2").arg(ipAddress, groupName), data);

    // Aggiorna la lista IP a destra (UI)
    m_itemModel->addIpLocally(ipAddress);
}

void ClientController::removeGroupRequest(const QString &groupName)
{
    if (groupName.trimmed().isEmpty()) return;

    if (m_itemModel && m_itemModel->currentGroupName() == groupName) {
        m_itemModel->clear();
        // Opzionale: se hai una proprietà nella Sidebar per l'indice corrente, resettala a -1
    }

    m_groupModel->removeGroupLocally(groupName);

    QVariantMap data;
    data["groupName"] = groupName;

    recordChange("REMOVE_GROUP_REQUEST", "Eliminazione gruppo: " + groupName, data);
}

void ClientController::renameGroupRequest(const QString &oldName, const QString &newName)
{
    QString trimmedNew = newName.trimmed();
    if (oldName == trimmedNew || trimmedNew.isEmpty()) return;

    static QRegularExpression re("^[a-zA-Z0-9_-]+$");
    if (!re.match(trimmedNew).hasMatch()) {
        qWarning() << "⚠️ Nome non valido:" << trimmedNew;
        return;
    }

    // 1. Prepariamo i dati per il Sync futuro
    QVariantMap data;
    data["oldName"] = oldName;
    data["newName"] = trimmedNew;

    QString desc = QString("Rinomina gruppo '%1' in '%2'").arg(oldName, trimmedNew);

    // 2. Registriamo la modifica invece di inviarla subito
    recordChange("RENAME_GROUP_REQUEST", desc, data);

    // 3. Aggiorniamo la UI locale immediatamente
    m_groupModel->updateGroupNameLocally(oldName, trimmedNew);
}

void ClientController::commitSync()
{
    if (m_pendingChanges.isEmpty()) return;

    if (auto socket = AdvVpnSocket::instance()) {
        QJsonObject rootJson;
        rootJson["type"] = "BULK_SYNC_REQUEST";

        QJsonArray changesArray;
        for (const PendingChange &change : m_pendingChanges) {
            QJsonObject changeObj;
            changeObj["type"] = change.type;
            changeObj["data"] = QJsonObject::fromVariantMap(change.data);
            changesArray.append(changeObj);
        }
        rootJson["changes"] = changesArray;

        // Invio massivo al server
        socket->sendJson(rootJson);

        // Pulizia della coda locale
        m_pendingChanges.clear();
        emit pendingChangesChanged();

        qInfo() << "🚀 Sincronizzazione massiva inviata al server.";
    }
}

void ClientController::discardChanges()
{
    if (m_pendingChanges.isEmpty()) return;

    // 1. Svuota la lista delle modifiche
    m_pendingChanges.clear();

    // 2. Notifica QML che la lista e il conteggio sono cambiati
    emit pendingChangesChanged();

    // 3. Opzionale: Richiedi un SYNC aggiornato al server per resettare la UI locale
    if (auto socket = AdvVpnSocket::instance()) {
        QJsonObject req;
        req["type"] = "FETCH_FULL_STATE"; // Assicurati che il server gestisca questo comando
        socket->sendJson(req);
    }

    qInfo() << "♻️ Modifiche locali annullate e coda svuotata.";
}

void ClientController::requestRemoveIp(const QString &groupName, const QString &ipAddress)
{
    // Debug per vedere cosa arriva davvero
    qDebug() << "DEBUG CONTROLLER -> Gruppo:" << groupName << "| IP:" << ipAddress;

    if (groupName.isEmpty() || ipAddress.trimmed().isEmpty()) return;

    // Chiamata al modello con l'IP corretto
    if (m_itemModel) {
        m_itemModel->removeIpLocally(ipAddress.trimmed());
    }

    // Registrazione per il Sync
    QVariantMap data;
    data["groupName"] = groupName;
    data["ipAddress"] = ipAddress.trimmed();

    recordChange("REMOVE_IP_REQUEST",
                 QString("Elimina IP %1 dal gruppo %2").arg(ipAddress, groupName),
                 data);
}

void ClientController::recordChange(const QString &type, const QString &desc, const QVariantMap &data) {

    PendingChange change = {type, desc, data};
    m_pendingChanges.append(change);

    // Questo è vitale: forza QML a rileggere la lista!
    emit pendingChangesChanged();
}

void ClientController::updateIpLocally(const QString &oldIp, const QString &newIp)
{
    if (oldIp == newIp || newIp.trimmed().isEmpty()) return;

    m_itemModel->renameIpLocally(oldIp, newIp);

    QVariantMap data;
    data["old_ip"] = oldIp;
    data["new_ip"] = newIp;

    data["group_name"] = m_itemModel->currentGroupName();

    recordChange("RENAME_IP_REQUEST",
                 QString("Rinomina IP: %1 -> %2").arg(oldIp, newIp),
                 data);
}

QVariantList ClientController::getPendingChangesForQml() const {
    QVariantList list;
    for (const auto &change : m_pendingChanges) {
        QVariantMap map;
        map["description"] = change.description;
        map["type"] = change.type;
        list.append(map);
    }
    return list;
}

void ClientController::onSyncDataReceived(const QJsonObject &data)
{
    int currentIndex = m_itemModel->currentGroupIndex();

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
    serverCnsList.sort();
    m_availableCns = serverCnsList;

    emit availableCnsChanged();
    qInfo() << "📥 UI Sincronizzata con il database del Server.";
}

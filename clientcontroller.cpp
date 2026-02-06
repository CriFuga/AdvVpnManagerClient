#include "clientcontroller.h"
#include "advvpngroupmodel.h"
#include "advvpnitemmodel.h"
#include "advvpnsocket.h"
#include "advvpngroup.h"
#include <QJsonArray>
#include <QRegularExpression>
#include <QJsonDocument>
#include <QDebug>

// Initializes managers, models and connects core signals for buffer and networking
ClientController::ClientController(AdvVpnGroupModel *groupModel, AdvVpnItemModel *itemModel, QObject *parent)
    : QObject(parent), m_groupModel(groupModel), m_itemModel(itemModel)
{
    m_changesBuffer = new ChangesBufferManager(this);
    m_syncModel = new ChangesBufferModel(m_changesBuffer, this);

    setupBufferConnections();

    connect(m_changesBuffer, &ChangesBufferManager::countChanged, this, &ClientController::pendingChangesCountChanged);

    connect(m_groupModel, &AdvVpnGroupModel::conflictsDetected, this, [this](const QStringList &errors){
        if (!errors.isEmpty()) {
            emit errorsOccurred(errors.first());
        }
    });

    auto socket = AdvVpnSocket::instance();
    if (socket) {
        connect(socket, &AdvVpnSocket::syncDataReceived, this, &ClientController::onSyncDataReceived);
    }

    connect(socket, &AdvVpnSocket::connectionStatusChanged, this, [this, socket](){
        if (socket->isConnected()) {
            emit started("Connected to VPN server.");
        } else {
            emit errorsOccurred("Connection to VPN server lost.");
        }
    });
}

// Triggers the socket connection to the server
void ClientController::start() {
    if (auto socket = AdvVpnSocket::instance()) {
        socket->openConnection();
    }
}

// Configures internal signal-slot mapping for the changes buffer
void ClientController::setupBufferConnections() {
    connect(m_changesBuffer, &ChangesBufferManager::countChanged, this, &ClientController::pendingChangesCountChanged);
    connect(m_changesBuffer, &ChangesBufferManager::actionUndone, this, &ClientController::rollbackAction);
}

// Validates and stages an ID (CN) update for a specific IP
void ClientController::sendIdUpdate(const QString &ip, const QString &newId) {
    if (ip.isEmpty()) return;

    QString cleanIp = ip.trimmed();
    QHostAddress address(cleanIp);
    if (!address.isNull() && address.protocol() == QAbstractSocket::IPv4Protocol) {
        cleanIp = address.toString();
    }

    QString cleanId = newId.trimmed();

    if (!cleanId.isEmpty()) {
        QString ownerIp = m_itemModel->getIpForCn(cleanId);

        if (!ownerIp.isEmpty() && ownerIp != cleanIp) {
            emit errorsOccurred("ID '" + cleanId + "' is already assigned to IP " + ownerIp);
            return;
        }
    }

    VpnAction a;
    a.type = VpnAction::UpdateId;
    a.targetId = cleanIp;
    a.newValue = cleanId;
    a.groupId = m_itemModel->currentGroupName();
    a.description = QString("Assigned ID '%1' to %2").arg(cleanId.isEmpty() ? "Empty" : cleanId, cleanIp);

    m_changesBuffer->addAction(a);
    m_itemModel->updateCnLocally(cleanIp, cleanId);

    emit availableCnsChanged();
    emit pendingChangesCountChanged();
}

// Validates name uniqueness and stages a new group creation
void ClientController::addGroupRequest(const QString &groupName) {
    QString name = groupName.trimmed();
    if (name.isEmpty()) return;

    if (m_groupModel->duplicateNameExists(name)) {
        emit errorsOccurred("A group named '" + name + "' already exists");
        return;
    }

    VpnAction a;
    a.type = VpnAction::CreateGroup;
    a.targetId = name;
    a.description = "New group: " + name;

    m_changesBuffer->addAction(a);
    m_groupModel->addGroupLocally(name);
}

// Validates IP uniqueness and stages adding an IP to a group
void ClientController::addIpRequest(const QString &groupName, const QString &ipAddress) {
    if (groupName.isEmpty() || ipAddress.trimmed().isEmpty()) return;

    QString cleanIp = ipAddress.trimmed();

    if (m_itemModel->ipExistsInCurrentGroup(cleanIp)) {
        emit errorsOccurred("The address " + cleanIp + " is already present in this group!");
        return;
    }

    VpnAction a;
    a.type = VpnAction::AddIp;
    a.targetId = cleanIp;
    a.groupId = groupName;
    a.description = QString("Added IP %1 to %2").arg(cleanIp, groupName);

    m_changesBuffer->addAction(a);
    m_itemModel->addIpLocally(cleanIp);
}

// Stages a group deletion and cleans up related pending actions
void ClientController::removeGroupRequest(const QString &groupName) {
    if (groupName.isEmpty()) return;

    m_changesBuffer->removeActionsRelatedToGroup(groupName);

    VpnAction a;
    a.type = VpnAction::DeleteGroup;
    a.targetId = groupName;
    a.description = "Delete group: " + groupName;
    m_changesBuffer->addAction(a);
    m_groupModel->setGroupHidden(groupName, true);
}

// Validates new name availability and stages a group rename
void ClientController::renameGroupRequest(const QString &oldName, const QString &newName) {
    if (oldName == newName || newName.trimmed().isEmpty()) return;

    QString cleanNew = newName.trimmed();
    if (m_groupModel->duplicateNameExists(cleanNew)) {
        emit errorsOccurred("A group named '" + cleanNew + "' already exists!");
        return;
    }

    VpnAction a;
    a.type = VpnAction::RenameGroup;
    a.targetId = oldName;
    a.newValue = cleanNew;
    a.description = QString("Renamed %1 -> %2").arg(oldName, cleanNew);

    m_changesBuffer->addAction(a);
    m_groupModel->updateGroupNameLocally(oldName, cleanNew);
}

// Stages an IP deletion from a specific group
void ClientController::requestRemoveIp(const QString &groupName, const QString &ipAddress) {
    if (groupName.isEmpty() || ipAddress.isEmpty()) return;

    VpnAction a;
    a.type = VpnAction::DeleteIp;
    a.targetId = ipAddress;
    a.groupId = groupName;
    a.description = QString("Removed IP %1 from %2").arg(ipAddress, groupName);

    m_itemModel->setItemHidden(ipAddress, true);
    m_changesBuffer->addAction(a);
}

// Validates and stages an IP address modification
void ClientController::updateIpRequest(const QString &oldIp, const QString &newIp) {
    if (oldIp == newIp || newIp.trimmed().isEmpty()) return;

    QString cleanNewIp = newIp.trimmed();

    if (m_itemModel->ipExistsInCurrentGroup(cleanNewIp, oldIp)) {
        emit errorsOccurred("Cannot modify: address " + cleanNewIp + " is already present!");
        return;
    }

    VpnAction a;
    a.type = VpnAction::UpdateIp;
    a.targetId = oldIp;
    a.newValue = cleanNewIp;
    a.groupId = m_itemModel->currentGroupName();
    a.description = QString("Changed IP: %1 -> %2").arg(oldIp, cleanNewIp);

    m_changesBuffer->addAction(a);
    m_itemModel->renameIpLocally(oldIp, cleanNewIp);
}

// Serializes staged actions into JSON and sends them to the server
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

    QJsonDocument doc(root);
    qDebug().noquote() << "SENDING BULK SYNC:\n" << doc.toJson(QJsonDocument::Indented);

    if (auto s = AdvVpnSocket::instance()) {
        s->sendJson(root);
        m_changesBuffer->clear();
        emit pendingChangesCountChanged();
    }
}

// Clears the buffer and requests a full state refresh from the server
void ClientController::discardChanges() {
    m_changesBuffer->clear();
    emit pendingChangesCountChanged();

    if (auto socket = AdvVpnSocket::instance()) {
        QJsonObject req;
        req["type"] = "FETCH_FULL_STATE";
        socket->sendJson(req);
    }
}

// Maps proxy view row index to source model index for group selection
void ClientController::selectGroupFromProxy(int proxyRow) {
    if (!m_groupProxy || proxyRow < 0) return;

    QModelIndex proxyIndex = m_groupProxy->index(proxyRow, 0);
    QModelIndex sourceIndex = m_groupProxy->mapToSource(proxyIndex);

    m_itemModel->setGroupIndex(sourceIndex.row());
}

// Clears conflict messages for the UI
void ClientController::clearConflicts() {
    if (!m_conflictMessages.isEmpty()) {
        m_conflictMessages.clear();
        emit conflictMessagesChanged();
    }
}

// Converts internal action enum to server-compliant string operation
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

// Processes incoming JSON data from server to update local models and suggestions
void ClientController::onSyncDataReceived(const QJsonObject &data) {
    if (data.contains("errors") || data.contains("conflicts")) {
        QStringList newErrors;
        QJsonArray errArray = data.contains("errors") ? data["errors"].toArray() : data["conflicts"].toArray();

        for (const auto &err : errArray) {
            newErrors.append(err.toString());
        }

        if (!newErrors.isEmpty()) {
            m_conflictMessages = newErrors;
            emit conflictMessagesChanged();
            return;
        }
    }
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
    QStringList filteredCns;
    for(const QString &cn : serverCnsList) {
        if (m_itemModel->getIpForCn(cn).isEmpty()) {
            filteredCns.append(cn);
        }
    }

    filteredCns.sort();
    m_availableCns = filteredCns;
    emit availableCnsChanged();
    qInfo() << "Database successfully synchronized from server.";
}

// Reverts local UI state when an action is undone in the buffer
void ClientController::rollbackAction(const VpnAction &a)
{
    qDebug() << "Rollback (Visual) for action:" << a.description;

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

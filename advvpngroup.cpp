#include "advvpngroup.h"
#include "advvpnitem.h"

#include <QJsonObject>
#include <QJsonArray>

AdvVpnGroup::AdvVpnGroup(const QString &name)
    : m_name(name)
{
}

void AdvVpnGroup::addItem(AdvVpnItem *item)
{
    if (item) {
        m_items.append(item);
    }
}

AdvVpnGroup *AdvVpnGroup::fromJson(const QJsonObject &json)
{
    QString name = json["name"].toString();
    if (name.isEmpty()) return nullptr;

    AdvVpnGroup *group = new AdvVpnGroup(name);

    QJsonArray itemsArr = json["items"].toArray();
    for (const auto &val : itemsArr) {
        QJsonObject itemObj = val.toObject();
        QString strVal = itemObj["value"].toString();

        AdvVpnItem *item = AdvVpnItem::fromString(strVal);
        if (item) {
            group->addItem(item);
        }
    }
    return group;
}

// Destructor: cleans up dynamically allocated item memory.
AdvVpnGroup::~AdvVpnGroup()
{
    qDeleteAll(m_items);
    m_items.clear();
}

void AdvVpnGroup::addIp(const QString &ipAddress)
{
    AdvVpnItem *item = AdvVpnItem::fromString(ipAddress);
    if (item) {
        this->addItem(item); // Usa addItem per coerenza
    }
}

// Returns the name of the VPN group.
const QString &AdvVpnGroup::name() const
{
    return m_name;
}

// Returns the list of VPN items contained in this group.
const QList<AdvVpnItem *> &AdvVpnGroup::items() const
{
    return m_items;
}

// Returns the count of items in this group.
int AdvVpnGroup::itemCount() const
{
    return m_items.size();
}

QJsonObject AdvVpnGroup::toJson() const
{
    QJsonObject obj;
    obj["name"] = m_name;

    QJsonArray itemsArray;
    for (const AdvVpnItem *item : m_items) {
        itemsArray.append(item->toJson());
    }
    obj["items"] = itemsArray;

    return obj;
}

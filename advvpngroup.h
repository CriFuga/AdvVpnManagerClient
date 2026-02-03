#ifndef ADVVPNGROUP_H
#define ADVVPNGROUP_H

#include <QList>
#include <QJsonObject>
#include <QJsonArray>

// RIMOSSO: class GroupToken;
class AdvVpnItem;

class AdvVpnGroup
{
public:

    explicit AdvVpnGroup(const QString &name);

    void addItem(AdvVpnItem *item);
    static AdvVpnGroup *fromJson(const QJsonObject &json);

    ~AdvVpnGroup();

    bool isValid() const { return true; }
    bool isHidden() const { return m_isHidden; }
    void setHidden(bool hidden) { m_isHidden = hidden; }

    void setName(const QString &newName) { m_name = newName; }
    void addIp(const QString &ipAddress);

    const QString &name() const;
    const QList<AdvVpnItem *> &items() const;
    int itemCount () const;

    QJsonObject toJson() const;

private:
    QString m_name;
    bool m_isHidden = false;
    QList<AdvVpnItem *> m_items;
};

#endif

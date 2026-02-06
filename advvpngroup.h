#ifndef ADVVPNGROUP_H
#define ADVVPNGROUP_H

#include <QList>
#include <QJsonObject>
#include <QJsonArray>

class AdvVpnItem;

class AdvVpnGroup
{
public:
    explicit AdvVpnGroup(const QString &name);
    ~AdvVpnGroup();

    static AdvVpnGroup *fromJson(const QJsonObject &json);
    QJsonObject toJson() const;

    bool isValid() const;
    bool isHidden() const;
    void setHidden(bool hidden);

    void setName(const QString &newName);
    void addItem(AdvVpnItem *item);
    void addIp(const QString &ipAddress);

    const QString &name() const;
    const QList<AdvVpnItem *> &items() const;
    int itemCount() const;

private:
    QString m_name;
    bool m_isHidden = false;
    QList<AdvVpnItem *> m_items;
};

#endif

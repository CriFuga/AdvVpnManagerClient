#ifndef ADVPNITEM_H
#define ADVPNITEM_H

#include <QtNetwork/QHostAddress>
#include <QJsonObject>

/*
 * Polymorphic representation of an nftables element:
 * - single IPv4 address
 * - CIDR network (ip/prefix)
 * - IPv4 range (a-b)
 */

class AdvVpnItem
{
public:
    enum class Kind { Address, Net, Range };

    virtual ~AdvVpnItem() = default;

    virtual Kind kind() const = 0;
    virtual bool contains(quint32 ipv4HostOrder) const = 0;
    virtual QString toString() const = 0;
    virtual QJsonObject toJson() const = 0;
    static AdvVpnItem* fromJson(const QJsonObject &json);

    bool contains(const QHostAddress &addr) const;

    quint32 start() const { return m_start; } // inclusive, host order
    quint32 end()   const { return m_end; }   // inclusive, host order

    static AdvVpnItem *fromString(QStringView token, QString *error = nullptr);
    static QString kindToString(Kind k);

protected:
    quint32 m_start = 0;
    quint32 m_end = 0;

    static bool parseIPv4(QStringView s, quint32 &outHostOrder, QString *error);
    static quint32 maskFromPrefix(int prefix);
    static QString hostToString(quint32 hostOrder);
    static QStringView trimToken(QStringView v);
};

class AdvAddressItem final : public AdvVpnItem
{
public:
    static AdvVpnItem *create(QStringView ip, QString *error = nullptr);

    Kind kind() const override { return Kind::Address; }
    bool contains(quint32 ipv4HostOrder) const override;
    QString toString() const override;
    QJsonObject toJson() const override;
};

class AdvNetItem final : public AdvVpnItem
{
public:
    static AdvVpnItem *create(QStringView ip, qsizetype prefix, QString *error = nullptr);

    Kind kind() const override { return Kind::Net; }
    bool contains(quint32 ipv4HostOrder) const override;
    QString toString() const override;
    QJsonObject toJson() const override;

    int prefixLen() const { return m_prefix; }

private:
    int m_prefix = 0;
};

class AdvRangeItem final : public AdvVpnItem
{
public:
    static AdvVpnItem *create(QStringView a, QStringView b, QString *error = nullptr);

    Kind kind() const override { return Kind::Range; }
    bool contains(quint32 ipv4HostOrder) const override;
    QString toString() const override;
    QJsonObject toJson() const override;
};

#endif // ADVPNITEM_H

#include "advvpnitem.h"

QStringView AdvVpnItem::trimToken(QStringView v)
{
    while (!v.isEmpty() && v.front().isSpace()) v = v.sliced(1);
    while (!v.isEmpty() && v.back().isSpace())  v = v.sliced(0, v.size() - 1);

    // Strip trailing separators.
    while (!v.isEmpty() && (v.back() == ',' || v.back() == ';')) v = v.sliced(0, v.size() - 1);
    while (!v.isEmpty() && v.back().isSpace()) v = v.sliced(0, v.size() - 1);

    return v;
}

bool AdvVpnItem::parseIPv4(QStringView s, quint32 &outHostOrder, QString *error)
{
    const QString str = s.toString().trimmed();
    QHostAddress ha;
    if (!ha.setAddress(str) || ha.protocol() != QAbstractSocket::IPv4Protocol) {
        if (error) *error = QString("Invalid IPv4 address: '%1'").arg(str);
        return false;
    }
    outHostOrder = ha.toIPv4Address();   // big-endian raw
    //outHostOrder = qFromBigEndian(net);       // convert to host order
    return true;
}

quint32 AdvVpnItem::maskFromPrefix(int prefix)
{
    if (prefix <= 0) return 0u;
    if (prefix >= 32) return 0xFFFFFFFFu;
    return 0xFFFFFFFFu << (32 - prefix);
}

QString AdvVpnItem::hostToString(quint32 hostOrder)
{
    auto tmp = QHostAddress(hostOrder).toString();
    return tmp;
}

AdvVpnItem *AdvVpnItem::fromJson(const QJsonObject &json)
{
    QString kindStr = json["kind"].toString().toLower();
    QString valueStr = json["value"].toString();

    QString error;
    AdvVpnItem* item = nullptr;

    if (kindStr == "address") {
        item = AdvAddressItem::create(valueStr, &error);
    }
    else if (kindStr == "net") {
        int prefix = json["prefix"].toInt(-1);
        QString ipOnly = valueStr.section('/', 0, 0);
        item = AdvNetItem::create(ipOnly, prefix, &error);
    }
    else if (kindStr == "range") {
        const QStringList parts = valueStr.split('-', Qt::SkipEmptyParts);

        if (parts.size() != 2) {
            qWarning() << "fromJson Range Error: formato non valido (atteso IP-IP):" << valueStr;
            return nullptr;
        }
        item = AdvRangeItem::create(parts.at(0), parts.at(1), &error);
    }
    else {
        qWarning() << "fromJson Error: Unknown AdvVpnItem kind:" << kindStr;
        return nullptr;
    }

    if (!item) {
        qWarning() << "fromJson Failed per" << kindStr << ":" << valueStr << "-> Motivo:" << error;
    }

    return item;
}

bool AdvVpnItem::contains(const QHostAddress &addr) const
{
    if (addr.protocol() != QAbstractSocket::IPv4Protocol) return false;
    return contains(addr.toIPv4Address());
}

AdvVpnItem *AdvAddressItem::create(QStringView ip, QString *error)
{
    quint32 a = 0;
    if (!parseIPv4(ip, a, error)) return nullptr;

    auto ptr = new AdvAddressItem();
    ptr->m_start = a;
    ptr->m_end = a;
    return ptr;
}

bool AdvAddressItem::contains(quint32 ipv4HostOrder) const
{
    return ipv4HostOrder == m_start;
}

QString AdvAddressItem::toString() const
{
    return hostToString(m_start);
}

QJsonObject AdvAddressItem::toJson() const
{
    QJsonObject obj;
    obj["kind"] = "address";
    obj["value"] = toString();
    return obj;
}

AdvVpnItem *AdvNetItem::create(QStringView ip, qsizetype prefix, QString *error)
{
    if (prefix < 0 || prefix > 32) {
        if (error) *error = QString("Invalid CIDR prefix: %1").arg(prefix);
        return nullptr;
    }

    quint32 a = 0;
    if (!parseIPv4(ip, a, error)) return nullptr;

    const quint32 mask = maskFromPrefix(int(prefix));
    const quint32 netStart = a & mask;
    const quint32 netEnd = netStart | (~mask);

    auto ptr = new AdvNetItem();
    ptr->m_start = netStart;
    ptr->m_end = netEnd;
    ptr->m_prefix = int(prefix);
    return ptr;
}

bool AdvNetItem::contains(quint32 ipv4HostOrder) const
{
    return ipv4HostOrder >= m_start && ipv4HostOrder <= m_end;
}

QString AdvNetItem::toString() const
{
    auto tmp = QString("%1/%2").arg(hostToString(m_start)).arg(m_prefix);
    return tmp;
}

QJsonObject AdvNetItem::toJson() const
{
    QJsonObject obj;
    obj["kind"] = "net";
    obj["value"] = toString();
    obj["prefix"] = m_prefix;
    return obj;
}

AdvVpnItem *AdvRangeItem::create(QStringView a, QStringView b, QString *error)
{
    quint32 x = 0, y = 0;
    if (!parseIPv4(a, x, error)) return nullptr;
    if (!parseIPv4(b, y, error)) return nullptr;

    if (x > y) std::swap(x, y);

    auto ptr = new AdvRangeItem();
    ptr->m_start = x;
    ptr->m_end = y;
    return ptr;
}

bool AdvRangeItem::contains(quint32 ipv4HostOrder) const
{
    return ipv4HostOrder >= m_start && ipv4HostOrder <= m_end;
}

QString AdvRangeItem::toString() const
{
    return QString("%1-%2").arg(hostToString(m_start), hostToString(m_end));
}

QJsonObject AdvRangeItem::toJson() const
{
    QJsonObject obj;
    obj["kind"] = "range";
    obj["value"] = toString();
    return obj;
}

AdvVpnItem *AdvVpnItem::fromString(QStringView token, QString *error)
{
    token = trimToken(token);
    if (token.isEmpty()) {
        if (error) *error = "Empty element token";
        return nullptr;
    }

    // Range: a-b
    const qsizetype dash = token.indexOf(u'-');
    if (dash > 0) {
        const QStringView left = trimToken(token.sliced(0, dash));
        const QStringView right = trimToken(token.sliced(dash + 1));
        return AdvRangeItem::create(left, right, error);
    }

    // Net: ip/prefix
    const qsizetype slash = token.indexOf(u'/');
    if (slash > 0) {
        const QStringView ipPart = trimToken(token.sliced(0, slash));
        const QStringView prPart = trimToken(token.sliced(slash + 1));

        bool ok = false;
        const qsizetype prefix = prPart.toString().toInt(&ok);
        if (!ok) {
            if (error) *error = QString("Invalid CIDR prefix token: '%1'").arg(prPart.toString());
            return nullptr;
        }

        return AdvNetItem::create(ipPart, prefix, error);
    }

    // Address: ip
    return AdvAddressItem::create(token, error);
}

QString AdvVpnItem::kindToString(Kind k)
{
    switch (k) {
    case AdvVpnItem::Kind::Address: return "Address";
    case AdvVpnItem::Kind::Net:     return "Net";
    case AdvVpnItem::Kind::Range:   return "Range";
    }
    return "Unknown";
}

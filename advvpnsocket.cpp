#include "advvpnsocket.h"
#include <QSettings>
#include <QJsonDocument>
#include <QDebug>

AdvVpnSocket* AdvVpnSocket::m_instance = nullptr;

AdvVpnSocket::AdvVpnSocket(QObject *parent)
    : QWebSocket{QString(), QWebSocketProtocol::VersionLatest, parent} // [cite: 18]
{
    m_instance = this;

    QSettings settings;
    m_host = settings.value("server/host", "localhost").toString();
    m_port = quint16(settings.value("server/port", 8080).toUInt());

    connect(this, &QWebSocket::connected, this, &AdvVpnSocket::onConnected);
    connect(this, &QWebSocket::disconnected, this, &AdvVpnSocket::onDisconnected);
    connect(this, &QWebSocket::textMessageReceived, this, &AdvVpnSocket::onTextMessageReceived);
    connect(this, &QWebSocket::errorOccurred, this, &AdvVpnSocket::onError);

}

AdvVpnSocket::~AdvVpnSocket()
{
    if (m_instance == this) {
        m_instance = nullptr;
    }
    this->disconnect();
    this->close();

    qDebug() << "AdvVpnSocket (Inherited) destroyed cleanly.";
}

void AdvVpnSocket::openConnection()
{
    QUrl url(QStringLiteral("ws://%1:%2").arg(m_host).arg(m_port));
    qInfo() << "Connecting to VPN Server at" << url;
    this->open(url);
}

void AdvVpnSocket::sendJson(const QJsonObject &json)
{
    QJsonDocument doc(json);
    this->sendTextMessage(QString::fromUtf8(doc.toJson(QJsonDocument::Compact)));
}

AdvVpnSocket *AdvVpnSocket::instance()
{
    return m_instance;
}

void AdvVpnSocket::onConnected()
{
    qInfo() << "✅ Connected to VPN Server!";
    m_connected = true;
    emit connectionStatusChanged();
}

void AdvVpnSocket::onDisconnected()
{
    qInfo() << "❌ Disconnected from VPN Server";
    m_connected = false;
    emit connectionStatusChanged();
}

void AdvVpnSocket::onTextMessageReceived(QString message)
{
    QJsonDocument doc = QJsonDocument::fromJson(message.toUtf8());

    if (doc.isObject()) {
        QJsonObject json = doc.object();
        QString type = json["type"].toString();

        if (type == "REQUEST_INIT_DATA") {
            qInfo() << "📩 Server requested INIT DATA -> Triggering upload...";
            emit initDataRequested();
        }
        else if (type == "SYNC_STATE") {
            qInfo() << "📩 Server sent SYNC STATE -> Updating models...";
            qInfo() << "⚡ STO PER EMETTERE IL SEGNALE syncDataReceived...";
            emit syncDataReceived(json);
        }
    } else {
            qDebug() << "Received raw text message:" << message;
    }
}

void AdvVpnSocket::onError(QAbstractSocket::SocketError error)
{
qWarning() << "⚠️ WebSocket Error:" << error << this->errorString();
}




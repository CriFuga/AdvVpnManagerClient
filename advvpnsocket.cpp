#include "advvpnsocket.h"
#include <QSettings>
#include <QJsonDocument>
#include <QDebug>
#include <QTimer>

AdvVpnSocket* AdvVpnSocket::m_instance = nullptr;


// Constructor: sets up the singleton instance, loads settings, and connects internal socket signals
AdvVpnSocket::AdvVpnSocket(QObject *parent)
    : QWebSocket{QString(), QWebSocketProtocol::VersionLatest, parent}
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

// Destructor: ensures clean disconnection and clears the singleton pointer
AdvVpnSocket::~AdvVpnSocket()
{
    if (m_instance == this) {
        m_instance = nullptr;
    }
    this->disconnect();
    this->close();

    qDebug() << "AdvVpnSocket instance destroyed cleanly.";
}


// Returns the current singleton instance
AdvVpnSocket *AdvVpnSocket::instance()
{
    return m_instance;
}

// Builds the connection URL and opens the WebSocket
void AdvVpnSocket::openConnection()
{
    QUrl url(QStringLiteral("ws://%1:%2").arg(m_host).arg(m_port));
    qInfo() << "Connecting to VPN Server at" << url;
    this->open(url);
}

// Serializes a QJsonObject and sends it over the WebSocket
void AdvVpnSocket::sendJson(const QJsonObject &json)
{
    QJsonDocument doc(json);
    this->sendTextMessage(QString::fromUtf8(doc.toJson(QJsonDocument::Compact)));
}

bool AdvVpnSocket::isConnected() const
{
    return m_connected;
}

// Handles successful connection event
void AdvVpnSocket::onConnected()
{
    qInfo() << "Connected to VPN Server!";
    m_connected = true;
    emit connectionStatusChanged();
}

// Handles disconnection event
void AdvVpnSocket::onDisconnected()
{
    qInfo() << "Disconnected from VPN Server";
    m_connected = false;
    QTimer::singleShot(5000, this, &AdvVpnSocket::openConnection);
    emit connectionStatusChanged();
}

// Parses incoming text messages as JSON and triggers appropriate signals
void AdvVpnSocket::onTextMessageReceived(QString message)
{
    QJsonDocument doc = QJsonDocument::fromJson(message.toUtf8());

    if (doc.isObject()) {
        QJsonObject json = doc.object();
        QString type = json["type"].toString();

        if (type == "REQUEST_INIT_DATA") {
            qInfo() << "Server requested INIT DATA -> Triggering upload...";
            emit initDataRequested();
        }
        else if (type == "SYNC_STATE") {
            qInfo() << "Server sent SYNC STATE -> Updating models...";
            emit syncDataReceived(json);
        }
    } else {
        qDebug() << "Received raw text message:" << message;
    }
}

// Handles socket errors and logs them
void AdvVpnSocket::onError(QAbstractSocket::SocketError error)
{
    qWarning() << "⚠WebSocket Error:" << error << this->errorString();
}

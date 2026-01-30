#ifndef ADVVPNSOCKET_H
#define ADVVPNSOCKET_H

#include <QWebSocket>
#include <QQmlEngine>
#include <QJsonObject>

class AdvVpnSocket : public QWebSocket
{
    Q_OBJECT
    //QML_ELEMENT
    //QML_SINGLETON
    Q_PROPERTY(bool connected READ isConnected NOTIFY connectionStatusChanged)
    Q_PROPERTY(bool isConnected READ isConnected NOTIFY connectionStatusChanged)

public:
    explicit AdvVpnSocket(QObject *parent = nullptr);
    ~AdvVpnSocket();

    Q_INVOKABLE void openConnection();
    Q_INVOKABLE void sendJson(const QJsonObject &json);

    static AdvVpnSocket *instance();

    bool isConnected() const { return m_connected; }

signals:
    void initDataRequested();
    void syncDataReceived(const QJsonObject &data);

    void connectionStatusChanged();

private slots:
    void onConnected();
    void onDisconnected();
    void onTextMessageReceived(QString message);
    void onError(QAbstractSocket::SocketError error);

private:
    static AdvVpnSocket *m_instance;
    QString m_host;
    quint16 m_port;
    bool m_connected = false;
};

#endif // ADVVPNSOCKET_H

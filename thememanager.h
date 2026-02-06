#ifndef THEMEMANAGER_H
#define THEMEMANAGER_H

#include <QObject>
#include <QColor>

class ThemeManager : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool darkMode READ darkMode WRITE setDarkMode NOTIFY darkModeChanged)

    Q_PROPERTY(QColor background READ background NOTIFY themeChanged)
    Q_PROPERTY(QColor panel READ panel NOTIFY themeChanged)
    Q_PROPERTY(QColor border READ border NOTIFY themeChanged)
    Q_PROPERTY(QColor textMain READ textMain NOTIFY themeChanged)
    Q_PROPERTY(QColor textDim READ textDim NOTIFY themeChanged)
    Q_PROPERTY(QColor textPrimary READ textPrimary NOTIFY themeChanged)
    Q_PROPERTY(QColor cardBackground READ cardBackground NOTIFY themeChanged)

    Q_PROPERTY(QColor accent READ accent CONSTANT)
    Q_PROPERTY(QColor sidebarBg READ sidebarBg CONSTANT)
    Q_PROPERTY(QColor success READ success CONSTANT)
    Q_PROPERTY(QColor error READ error CONSTANT)
    Q_PROPERTY(QColor sidebarItemActive READ sidebarItemActive CONSTANT)

public:
    explicit ThemeManager(QObject *parent = nullptr);

    bool darkMode() const { return m_darkMode; }
    void setDarkMode(bool dark);

    QColor background() const { return m_darkMode ? QColor(0x020617) : QColor(0xf1f5f9); }
    QColor panel() const      { return m_darkMode ? QColor(0x1e293b) : QColor(0xffffff); }
    QColor border() const     { return m_darkMode ? QColor(0x334155) : QColor(0xe2e8f0); }
    QColor textMain() const   { return m_darkMode ? QColor(0xf1f5f9) : QColor(0x0f172a); }
    QColor textDim() const    { return m_darkMode ? QColor(0x94a3b8) : QColor(0x64748b); }
    QColor textPrimary() const { return textMain(); }
    QColor cardBackground() const { return m_darkMode ? QColor(0x1e293b) : QColor(0xffffff); }

    QColor accent() const     { return QColor(0x2563eb); }
    QColor sidebarBg() const  { return QColor(0x1e293b); }
    QColor sidebarItemActive() const { return QColor(0x334155); }
    QColor success() const    { return QColor(0x22c55e); }
    QColor error() const      { return QColor(0xef4444); }

signals:
    void darkModeChanged();
    void themeChanged();

private:
    bool m_darkMode = false;
};

#endif

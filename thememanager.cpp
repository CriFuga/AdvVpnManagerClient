#include "thememanager.h"
#include <QSettings>

ThemeManager::ThemeManager(QObject *parent) : QObject(parent)
{
    QSettings settings;
    m_darkMode = settings.value("darkMode", false).toBool();
}

void ThemeManager::setDarkMode(bool dark)
{
    if (m_darkMode != dark) {
        m_darkMode = dark;

        QSettings settings;
        settings.setValue("darkMode", dark);

        emit darkModeChanged();
        emit themeChanged();
    }
}


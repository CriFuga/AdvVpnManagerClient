cmake_minimum_required(VERSION 3.16)

project(ADVVpnManagerClient VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 REQUIRED COMPONENTS Quick WebSockets)

qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(appADVVpnManagerClient
    main.cpp
)

include_directories("qml")

qt_add_qml_module(appADVVpnManagerClient
    URI ADVVpnManagerClient
    VERSION 1.0
    QML_FILES
        Main.qml
        qml/AutoSuggestField.qml
        qml/NetworkItemDelegate.qml
        qml/SidebarItem.qml
        qml/ConflictDialog.qml
        qml/Toolbar.qml
        qml/PopupToast.qml
        qml/VpnButton.qml
        qml/PlaceholderView.qml
        qml/Sidebar.qml
        qml/NotificationManager.qml
        qml/SearchBar.qml
        qml/AddGroupDialog.qml
        qml/AddIpDialog.qml
        qml/SyncReviewDialog.qml
        qml/EditItemDialog.qml
        qml/ConfirmDeleteIpDialog.qml
        qml/ConfirmAssignIdDialog.qml
        qml/EditGroupDialog.qml
        qml/ConfirmDeleteGroupDialog.qml
    SOURCES
        advvpnsocket.h advvpnsocket.cpp
        advvpngroupmodel.h advvpngroupmodel.cpp
        advvpnitem.h advvpnitem.cpp
        advvpngroup.h advvpngroup.cpp
        advvpnitemmodel.h advvpnitemmodel.cpp
        clientcontroller.h clientcontroller.cpp
        thememanager.h thememanager.cpp
        vpnaction.h vpnaction.cpp
        changesbuffermanager.h changesbuffermanager.cpp
        changesbuffermodel.h changesbuffermodel.cpp
        advvpngroupproxymodel.h advvpngroupproxymodel.cpp
        advvpnitemproxymodel.h advvpnitemproxymodel.cpp
    RESOURCES
        Resources.qrc
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appADVVpnManagerClient PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appADVVpnManagerClient
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appADVVpnManagerClient
    PRIVATE Qt6::Quick Qt6::WebSockets
)

include(GNUInstallDirs)
install(TARGETS appADVVpnManagerClient
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

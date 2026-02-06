import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects
import "qml"

ApplicationWindow {
    id: window
    width: 1200
    height: 800
    visible: true
    title: "AdvVpn Dashboard"
    color: Theme.background

    // Barra di stato della connessione
    Rectangle {
        id: connectionBar
        width: parent.width
        height: 4
        z: 100
        color: AdvVpnSocket.isConnected ? Theme.success : Theme.error
        Behavior on color { ColorAnimation { duration: 400 } }
    }

    // Overlay per i dialoghi
    Rectangle {
        id: modalOverlay
        anchors.fill: parent
        color: "#000000"
        z: 150
        visible: addGroupDialog.opened || addIpDialog.opened || syncReviewDialog.opened ||
                 editItemDialog.opened || deleteIpDialog.opened || deleteGroupDialog.opened
        opacity: visible ? 0.4 : 0.0
        Behavior on opacity { NumberAnimation { duration: 200 } }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                addGroupDialog.close()
                addIpDialog.close()
                syncReviewDialog.close()
                editItemDialog.close()
                deleteIpDialog.close()
                deleteGroupDialog.close()
            }
        }
    }

    Timer {
        id: toastTimer
        interval: 3500
        onTriggered: globalToast.showRequested = false
    }

    // --- AGGIORNAMENTO CONNECTIONS ---
    Connections {
        target: controller

        // Questo gestisce il nuovo segnale del buffer
        function onPendingChangesCountChanged() {
            if (controller.pendingChangesCount > 0) {
                globalToast.text = "Modifica registrata nel buffer"
                globalToast.showRequested = true
                toastTimer.restart()
            }
        }

        function onErrorsOccurred(errorMessage) {
            globalToast.text = errorMessage
            globalToast.showRequested = true
            toastTimer.restart()
        }

        function onStarted(msg) {
            globalToast.text = msg
            globalToast.showRequested = true
            toastTimer.restart()
        }
    }

    // --- DIALOGS (Aggiornati con le nuove API del Controller) ---
    ConflictDialog {
        id: conflictDialog
        anchors.fill: parent
        z: 999 // Lo mette sopra a tutto il resto della UI

        onDismiss: {
            controller.clearConflictMessages()
        }

    }

    AddGroupDialog {
        id: addGroupDialog;
        z: 200;
        onGroupAdded: (name) => controller.addGroupRequest(name)
    }

    AddIpDialog {
        id: addIpDialog;
        z: 200;
        onIpAdded: (ip) => controller.addIpRequest(rawItemModel.currentGroupName(), ip)
    }

    EditItemDialog {
        id: editItemDialog
        z: 2000
        onItemUpdated: (oldIp, newIp, newCn) => {
            if (newIp !== oldIp) {
                controller.updateIpRequest(oldIp, newIp) // Usa la nuova API
            }
            // newCn corrisponde al nuovo ID assegnato
            controller.sendIdUpdate(newIp, newCn) // Usa la nuova API

            globalToast.text = "Modifiche aggiunte al sync"
            globalToast.showRequested = true
            toastTimer.restart()
        }
    }

    ConfirmDeleteIpDialog {
        id: deleteIpDialog
        z: 200
        titleText: "Delete IP Address"
        onConfirmed: {
            // Passa direttamente il nome restituito dal modello
            controller.requestRemoveIp(rawItemModel.currentGroupName(), deleteIpDialog.messageText)
        }
    }

    ConfirmDeleteGroupDialog {
        id: deleteGroupDialog
        z: 200
        onConfirmed: {
            let nameToDelete = rawItemModel.currentGroupName()
            if (nameToDelete !== "") {
                mainSidebar.currentIndex = -1
                controller.removeGroupRequest(nameToDelete)
            }
        }
    }

    ConfirmAssignIdDialog {
            id: assignCnDialog
            z: 2000

            onConfirmed: (ip, cn) => {
                controller.sendIdUpdate(ip, cn)

                globalToast.text = "ID assegnato correttamente"
                globalToast.showRequested = true
                toastTimer.restart()
            }
        }

    SyncReviewDialog { id: syncReviewDialog; z: 200 }

    // --- LAYOUT PRINCIPALE ---
    RowLayout {
        anchors.fill: parent
        anchors.topMargin: connectionBar.height
        spacing: 0

        Sidebar {
            id: mainSidebar
            // Inizializziamo a -1 per mostrare il placeholder all'avvio
            currentIndex: -1
            onGroupSelected: (proxyIndex) => controller.selectGroupFromProxy(proxyIndex)
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            Toolbar {
                id: mainToolbar
                title: rawItemModel.currentGroupName() !== "" ? rawItemModel.currentGroupName() : "Network Items"
            }

            Item {
                id: mainContentArea
                Layout.fillWidth: true
                Layout.fillHeight: true

                // Vista iniziale
                PlaceholderView {
                    anchors.fill: parent
                    visible: mainSidebar.currentIndex === -1
                }

                PopupToast {
                    id: globalToast
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 50
                    z: 999
                }

                // Lista degli Item (visibile solo se un gruppo è selezionato)
                Item {
                    anchors.fill: parent
                    visible: mainSidebar.currentIndex !== -1

                    ListView {
                        id: itemListView
                        anchors.fill: parent
                        anchors.margins: 25
                        model: itemModel
                        spacing: 12
                        clip: true

                        remove: Transition {
                            NumberAnimation { property: "opacity"; to: 0; duration: 200 }
                            NumberAnimation { property: "scale"; to: 0.9; duration: 200 }
                        }

                        displaced: Transition {
                            NumberAnimation { properties: "y"; duration: 250; easing.type: Easing.OutQuad }
                        }

                        delegate: NetworkItemDelegate {
                            width: itemListView.width
                            ipValue: model.value
                            cn: model.cn
                            onClicked: {
                                itemListView.currentIndex = index
                            }
                        }
                    }

                    // Pulsante flottante per aggiungere IP
                    VpnButton {
                        id: addFab
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.margins: 32
                        width: 56
                        height: 56

                        contentItem: Item {
                            Image {
                                id: addIcon
                                anchors.centerIn: parent
                                source: "qrc:/icons/add.svg"
                                width: 24
                                height: 24
                                fillMode: Image.PreserveAspectFit
                                visible: false
                            }
                            ColorOverlay {
                                anchors.fill: addIcon
                                source: addIcon
                                color: "white"
                            }
                        }
                        onClicked: addIpDialog.open()
                    }
                }
            }
        }
    }
}

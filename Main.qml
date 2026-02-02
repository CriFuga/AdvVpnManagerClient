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

    // --- 1. BARRA DI CONNESSIONE ---
    Rectangle {
        id: connectionBar
        width: parent.width
        height: 4
        z: 100
        color: AdvVpnSocket.isConnected ? Theme.success : Theme.error
        Behavior on color { ColorAnimation { duration: 400 } }
    }

    // --- 2. LOGICA OVERLAY UNIFICATA ---
    Rectangle {
        id: modalOverlay
        anchors.fill: parent
        color: "#000000"
        z: 150
        // Aggiunti i due delete dialog alla visibilità dell'overlay
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

    // --- 3. LOGICA TOAST ---
    Timer {
        id: toastTimer
        interval: 3500
        onTriggered: globalToast.showRequested = false
    }

    Connections {
        target: controller

        function onPendingChangesChanged() {
            let changes = controller.pendingChanges
            if (changes.length > 0) {
                let lastChange = changes[changes.length - 1]
                globalToast.text = lastChange.description
                globalToast.showRequested = true
                toastTimer.restart()
            }
        }
        function onErrorsOccurred(errorMessage) {
            globalToast.text = errorMessage
            globalToast.showRequested = true
            toastTimer.restart()
        }
    }

    // --- 4. DIALOGS ---
    AddGroupDialog {
        id: addGroupDialog;
        z: 200;
        onGroupAdded: (name) => controller.addGroupRequest(name)
    }
    AddIpDialog {
        id: addIpDialog;
        z: 200;
        onIpAdded: (ip) => controller.addIpRequest(itemModel.currentGroupName(), ip)
    }
    EditItemDialog {
        id: editItemDialog
        z: 2000 // Sempre sopra tutto

        onItemUpdated: (oldIp, newIp, newCn) => {
            console.log("Aggiornamento coordinato: ", oldIp, "->", newIp, "| CN:", newCn)

            // 1. Se l'IP è cambiato, inviamo la modifica dell'indirizzo
            if (newIp !== oldIp) {
                controller.updateIpLocally(oldIp, newIp)
            }

            // 2. Inviamo l'aggiornamento del CN (anche se l'IP è lo stesso)
            // Usiamo il metodo che abbiamo già testato
           if (newCn !== editItemDialog.oldCn) {
                   console.log("📝 Cambio CN rilevato:", editItemDialog.oldCn, "->", newCn)
                   controller.sendCnUpdate(newIp, newCn)
               } else {
                   console.log("ℹ️ CN non modificato, salto l'invio al sync")
               }

            // Opzionale: un piccolo toast di feedback
            globalToast.text = "Modifiche applicate con successo"
            globalToast.showRequested = true
            toastTimer.restart()
        }
    }

    // Dialog eliminazione IP
    ConfirmDeleteIpDialog {
        id: deleteIpDialog
        z: 200
        titleText: "Elimina Indirizzo IP"
        onConfirmed: {
            let cleanName = mainSidebar.currentGroupName.split(' ')[0]
            controller.requestRemoveIp(cleanName, deleteIpDialog.messageText)
        }
    }
    // Dialog eliminazione Gruppo
    ConfirmDeleteGroupDialog {
        id: deleteGroupDialog
        z: 200
        onConfirmed: {
            // Recuperiamo il nome dalla stringa del messaggio o salvandolo in una proprietà
            let nameToDelete = mainSidebar.currentGroupName.split(' ')[0]

            // Reset della UI se necessario
            if (mainSidebar.currentGroupName.startsWith(nameToDelete)) {
                mainSidebar.currentIndex = -1
            }

            // Chiamata al controller per lo staging
            controller.removeGroupRequest(nameToDelete)
        }
    }
    ConfirmAssignCnDialog {
        id: assignCnDialog
        z: 2000 // Assicura che sia sopra l'overlay e la toolbar

        onConfirmed: (ip, cn) => {
            controller.sendCnUpdate(ip, cn)

            // Opzionale: Mostra un feedback all'utente
            globalToast.text = "Assegnazione CN inviata per " + ip
            globalToast.showRequested = true
            toastTimer.restart()
        }
    }

    SyncReviewDialog { id: syncReviewDialog; z: 200 }

    // --- 5. LAYOUT PRINCIPALE ---
    RowLayout {
        anchors.fill: parent
        anchors.topMargin: connectionBar.height
        spacing: 0

        Sidebar {
            id: mainSidebar
            onGroupSelected: (proxyIndex) => itemModel.setGroupIndex(proxyIndex)
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            Toolbar {
                id: mainToolbar
                title: itemModel.currentGroupName() !== "" ? itemModel.currentGroupName() : "Network Items"
            }

            Item {
                id: mainContentArea
                Layout.fillWidth: true
                Layout.fillHeight: true

                PlaceholderView {
                    anchors.fill: parent
                    visible: mainSidebar.currentIndex === -1
                }


                PopupToast {
                    id: globalToast
                    anchors.horizontalCenter: parent.horizontalCenter
                    z: 999
                }

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
                        delegate: NetworkItemDelegate {
                            width: itemListView.width
                            ipValue: model.value
                            cn: model.cn
                            onClicked: itemListView.currentIndex = index
                        }
                    }

                    RowLayout {
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.margins: 32
                        spacing: 16

                        //VpnButton {
                        //    id: editFab
                        //    Layout.preferredWidth: 44
                        //    Layout.preferredHeight: 44

                        //    contentItem: Item {
                        //        Image {
                        //            id: editIcon
                        //            anchors.centerIn: parent
                        //            source: "qrc:/icons/edit.svg"
                        //            width: 22
                        //            height: 22
                        //            fillMode: Image.PreserveAspectFit
                        //            visible: false
                        //        }
                        //        ColorOverlay {
                        //            anchors.fill: editIcon
                        //            source: editIcon
                        //            color: Theme.darkMode ? "#ffffff" : (Theme.accent || "#2563eb")
                        //        }
                        //    }

                        //    enabled: itemListView.currentIndex !== -1
                        //    opacity: enabled ? 1.0 : 0.4
                        //    onClicked: {
                        //        let currentIp = itemModel.data(itemModel.index(itemListView.currentIndex, 0), 258);
                        //        editItemDialog.oldIp = currentIp
                        //        editItemDialog.newIpText = currentIp
                        //        editItemDialog.open()
                        //    }
                        //}

                        VpnButton {
                            id: addFab
                            Layout.preferredWidth: 44
                            Layout.preferredHeight: 44

                            contentItem: Item {
                                Image {
                                    id: addIcon
                                    anchors.centerIn: parent
                                    source: "qrc:/icons/add.svg"
                                    width: 22
                                    height: 22
                                    fillMode: Image.PreserveAspectFit
                                    visible: false
                                }
                                ColorOverlay {
                                    anchors.fill: addIcon
                                    source: addIcon
                                    color: Theme.darkMode ? "#ffffff" : (Theme.accent || "#2563eb")
                                }
                            }
                            onClicked: addIpDialog.open()
                        }
                    }
                }
            }
        }
    }
}

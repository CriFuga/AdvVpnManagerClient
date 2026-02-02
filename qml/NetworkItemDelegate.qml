import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects

ItemDelegate {
    id: delegateRoot
    height: 85
    width: parent ? parent.width : 0
    property string cn: ""
    property string ipValue: ""

    onClicked: {
        delegateRoot.ListView.view.currentIndex = index
        delegateRoot.forceActiveFocus()
    }

    background: Rectangle {
        radius: 12
        color: Theme.cardBackground
        border.color: (delegateRoot.ListView.isCurrentItem || delegateRoot.hovered)
                      ? Theme.accent : Theme.border
        border.width: delegateRoot.ListView.isCurrentItem ? 2 : 1
    }

    contentItem: RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 20
        anchors.rightMargin: 20 // Aumentato per staccare i bottoni dal bordo
        spacing: 20

        // --- 1. ICONA IP (Fissa a sinistra) ---
        Rectangle {
            width: 44; height: 44; radius: 22
            color: cn !== "" ? (Theme.darkMode ? "#064e3b" : "#d1fae5") : (Theme.darkMode ? "#1e293b" : "#f1f5f9")
            border.color: cn !== "" ? "#10b981" : Theme.border
            border.width: 2
            Layout.alignment: Qt.AlignVCenter

            Text {
                anchors.centerIn: parent
                text: "IP"
                font.bold: true; font.pixelSize: 13
                color: cn !== "" ? "#10b981" : Theme.textDim
            }
        }

        // --- 2. AREA TESTI (Prende tutto lo spazio centrale) ---
        ColumnLayout {
            Layout.fillWidth: true // Fondamentale per spingere i bottoni a destra
            Layout.alignment: Qt.AlignVCenter
            spacing: 4

            Label {
                text: ipValue
                color: Theme.textMain
                font.bold: true; font.pixelSize: 16
            }

            // Container per CN o TextField
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 30

                // Stato Assegnato: ✓ nome_certificato
                RowLayout {
                    anchors.left: parent.left // Forza l'allineamento a sinistra
                    anchors.verticalCenter: parent.verticalCenter
                    visible: cn !== ""
                    spacing: 6

                    Text {
                        text: "✓"
                        color: "#10b981"
                        font.pixelSize: 12
                    }
                    Label {
                        text: cn
                        color: Theme.darkMode ? "#10b981" : "#059669"
                        font.pixelSize: 13; font.weight: Font.Medium
                        elide: Text.ElideRight
                    }
                }

                // Stato Vuoto: Campo input
                AutoSuggestField {
                    width: 250               // Larghezza fissa in pixel
                    Layout.preferredWidth: 200 // Larghezza preferita nel layout
                    visible: cn === ""
                    placeholderText: "Assegna ID..."
                    font.pixelSize: 12
                    suggestions: controller.availableCns
                    onSuggestionPicked: (val) => {
                        assignCnDialog.ipTarget = ipValue
                        assignCnDialog.cnValue = val
                        assignCnDialog.open()
                    }
                }
            }
        }

        // --- 3. BOTTONI (Fissi a destra) ---
        RowLayout {
                    id: actionButtons
                    spacing: 8
                    Layout.alignment: Qt.AlignVCenter
                    Layout.rightMargin: 15

                    // Definiamo una proprietà di stato per l'animazione
                    property bool isShown: delegateRoot.hovered || delegateRoot.ListView.isCurrentItem

                    // Applichiamo l'opacità e la trasformazione basandoci sullo stato
                    opacity: isShown ? 1.0 : 0.0

                    transform: Translate {
                        // Usiamo un'espressione condizionale diretta qui
                        x: actionButtons.isShown ? 0 : 20

                        Behavior on x {
                            NumberAnimation { duration: 250; easing.type: Easing.OutBack }
                        }
                    }

                    Behavior on opacity {
                        NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
                    }

                    // BOTTONE EDIT (MATITA)
                    VpnButton {
                        id: editBtn
                        Layout.preferredWidth: 34
                        Layout.preferredHeight: 34

                        // Spostiamo qui tutta la preparazione dei dati
                        onClicked: {
                            // 1. Selezioniamo l'item nella lista
                            delegateRoot.ListView.view.currentIndex = index

                            // 2. Prepariamo i dati per il Dialog unificato
                            editItemDialog.oldIp = ipValue
                            editItemDialog.newIpText = ipValue
                            editItemDialog.oldCn = cn
                            editItemDialog.newCnText = cn

                            // 3. Apriamo il Dialog
                            editItemDialog.open()
                        }

                        background: Rectangle {
                            color: editBtn.hovered ? (Theme.darkMode ? "#223b82f6" : "#e0e7ff") : "transparent"
                            radius: 17
                        }

                        contentItem: Item {
                            anchors.fill: parent
                            Image {
                                id: editIcon
                                source: "qrc:/icons/edit.svg"
                                anchors.centerIn: parent
                                width: 16; height: 16
                                fillMode: Image.PreserveAspectFit
                                sourceSize: Qt.size(16, 16)
                                visible: false
                            }
                            ColorOverlay {
                                anchors.fill: editIcon
                                source: editIcon
                                color: editBtn.hovered ? Theme.accent : Theme.textDim
                            }
                        }
                    }

                    // BOTTONE ELIMINA (CESTINO)
                    VpnButton {
                        id: deleteBtn
                        Layout.preferredWidth: 34
                        Layout.preferredHeight: 34
                        onClicked: {
                            deleteIpDialog.messageText = ipValue
                            deleteIpDialog.open()
                        }

                        background: Rectangle {
                            color: deleteBtn.hovered ? (Theme.darkMode ? "#22ff4444" : "#fee2e2") : "transparent"
                            radius: 17
                        }

                        contentItem: Item {
                            anchors.fill: parent
                            Image {
                                id: binIcon
                                source: "qrc:/icons/bin.svg"
                                anchors.centerIn: parent
                                width: 16; height: 16
                                fillMode: Image.PreserveAspectFit
                                sourceSize.width: 16
                                sourceSize.height: 16
                                visible: false
                            }
                            ColorOverlay {
                                anchors.fill: binIcon
                                source: binIcon
                                color: deleteBtn.hovered ? "#ef4444" : Theme.textDim
                            }
                        }
                    }
                }
    }
}

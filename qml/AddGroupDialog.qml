import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects

Dialog {
    id: control
    modal: true
    focus: true

    // Rimuoviamo i margini e l'header di default di Qt
    padding: 0
    header: null
    footer: null

    signal groupAdded(string name)

    // Sfondo e Contenitore Principale
    background: Rectangle {
        implicitWidth: 350
        implicitHeight: 250
        radius: 16
        color: Theme.panel // Colore del pannello dal tuo ThemeManager

        // Bordo sottile per dare definizione
        border.color: Theme.border
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 25
            spacing: 15

            // TITOLO
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                Text {
                    text: "Crea Nuovo Gruppo"
                    color: Theme.textMain
                    font.pixelSize: 20
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                }
                Text {
                    text: "Assegna un nome univoco al gruppo"
                    color: Theme.textDim
                    font.pixelSize: 13
                    Layout.alignment: Qt.AlignHCenter
                }
            }

            // CAMPO DI INPUT
            TextField {
                id: groupNameInput
                Layout.fillWidth: true
                Layout.preferredHeight: 45
                placeholderText: "Es: Server Web"
                color: Theme.textMain
                focus: true

                background: Rectangle {
                    color: Theme.background
                    radius: 8
                    border.color: groupNameInput.activeFocus ? Theme.accent : Theme.border
                    border.width: groupNameInput.activeFocus ? 2 : 1
                }
            }

            Item { Layout.fillHeight: true } // Spaziatore

            // BOTTONI (Ora dentro il Rectangle bianco)
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Button {
                    id: cancelBtn
                    text: "Annulla"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    onClicked: control.close()

                    contentItem: Text {
                        text: cancelBtn.text
                        color: Theme.textDim
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.bold: true
                    }

                    background: Rectangle {
                        color: cancelBtn.hovered ? "#15ffffff" : "transparent"
                        radius: 8
                        border.color: Theme.border
                    }
                }

                Button {
                    id: confirmBtn
                    text: "Crea"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    enabled: groupNameInput.text.trim().length > 0

                    onClicked: {
                        control.groupAdded(groupNameInput.text.trim())
                        groupNameInput.clear()
                        control.close()
                    }

                    background: Rectangle {
                        color: confirmBtn.enabled ? (confirmBtn.hovered ? "#2563eb" : Theme.accent) : "#334155"
                        radius: 8
                    }

                    contentItem: Text {
                        text: confirmBtn.text
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.bold: true
                    }
                }
            }
        }
    }

    // Reset del campo quando il dialog si apre
    onOpened: {
        groupNameInput.forceActiveFocus()
    }
}

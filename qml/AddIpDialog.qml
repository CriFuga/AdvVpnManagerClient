import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects

Dialog {
    id: control
    modal: true
    focus: true

    padding: 0
    header: null
    footer: null

    signal ipAdded(string ip)

    background: Rectangle {
        implicitWidth: 350
        implicitHeight: 250
        radius: 16
        color: Theme.panel
        border.color: Theme.border
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 25
            spacing: 15

            // TITOLO E SOTTOTITOLO
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                Text {
                    text: "Aggiungi Nuovo IP"
                    color: Theme.textMain
                    font.pixelSize: 20
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                }
                Text {
                    text: "Inserisci l'indirizzo IPv4 per questo gruppo"
                    color: Theme.textDim
                    font.pixelSize: 13
                    Layout.alignment: Qt.AlignHCenter
                }
            }

            // CAMPO DI INPUT IP
            TextField {
                id: ipInput
                Layout.fillWidth: true
                Layout.preferredHeight: 45
                placeholderText: "Es: 10.128.2.1"
                color: Theme.textMain
                focus: true

                // Filtro base per accettare solo numeri e punti
                inputMethodHints: Qt.ImhDigitsOnly
                validator: RegularExpressionValidator {
                    regularExpression: /^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.?\b){4}$/
                }

                background: Rectangle {
                    color: Theme.background
                    radius: 8
                    border.color: ipInput.activeFocus ? Theme.accent : Theme.border
                    border.width: ipInput.activeFocus ? 2 : 1
                }
            }

            Item { Layout.fillHeight: true }

            // BOTTONI
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
                    text: "Aggiungi"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    // Il tasto è attivo solo se l'input è un IP valido
                    enabled: ipInput.acceptableInput

                    onClicked: {
                        control.ipAdded(ipInput.text.trim())
                        ipInput.clear()
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

    onOpened: {
        ipInput.forceActiveFocus()
    }
}

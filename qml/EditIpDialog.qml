import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects

Dialog {
    id: control
    anchors.centerIn: parent

    enter: Transition {
        NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 200; easing.type: Easing.OutCubic }
        NumberAnimation { property: "scale"; from: 0.9; to: 1.0; duration: 200; easing.type: Easing.OutBack }
    }

    // ANIMAZIONE DI USCITA (Fade out + Scale down)
    exit: Transition {
        NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 150; easing.type: Easing.InCubic }
        NumberAnimation { property: "scale"; from: 1.0; to: 0.9; duration: 150; easing.type: Easing.InCubic }
    }

    // Proprietà per gestire i dati in entrata e uscita
    property string oldIp: ""
    property alias newIpText: ipInputField.text

    // Segnale emesso quando l'utente conferma la modifica
    signal ipUpdated(string oldIp, string newIp)

    modal: true
    focus: true
    padding: 0
    header: null
    footer: null

    // Funzione centralizzata per l'invio (Invio e Clic)
    function submitUpdate() {
        let cleanIp = ipInputField.text.trim();
        if (cleanIp !== "" && cleanIp !== oldIp && ipInputField.acceptableInput) {
            control.ipUpdated(oldIp, cleanIp);
            control.close();
        }
    }

    background: Rectangle {
        implicitWidth: 380
        implicitHeight: 280
        radius: 20
        color: Theme.panel // Uso del tema invece del colore fisso
        border.color: Theme.border
        border.width: 1

        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            color: "#40000000"
            radius: 20
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 30
            spacing: 20

            // HEADER CENTRATO
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "Modifica Indirizzo IP"
                    color: Theme.textMain
                    font.pixelSize: 22
                    font.bold: true
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                }

                Text {
                    text: "Stai modificando l'indirizzo: " + oldIp
                    color: Theme.textDim
                    font.pixelSize: 14
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            // CAMPO DI INPUT CON VALIDATORE
            TextField {
                id: ipInputField
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                color: Theme.textMain
                font.pixelSize: 15
                horizontalAlignment: Text.AlignHCenter
                placeholderText: "Nuovo indirizzo IP..."
                placeholderTextColor: Theme.textDim
                verticalAlignment: TextInput.AlignVCenter

                // Validator per assicurarsi che il nuovo IP sia formalmente corretto
                validator: RegularExpressionValidator {
                    regularExpression: /^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.?\b){4}$/
                }

                background: Rectangle {
                    color: Theme.background
                    radius: 10
                    border.color: ipInputField.activeFocus ? Theme.accent : Theme.border
                    border.width: ipInputField.activeFocus ? 2 : 1
                }

                Keys.onPressed: (event) => {
                                    if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                                        control.submitUpdate()
                                        event.accepted = true
                                    }
                                }
            }

            Item { Layout.fillHeight: true }

            // AREA BOTTONI
            RowLayout {
                Layout.fillWidth: true
                spacing: 15

                VpnButton {
                    id: cancelBtn
                    text: "Annulla"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 42
                    onClicked: control.close()
                }

                VpnButton {
                    id: modifyBtn
                    text: "Modifica"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 42
                    // Abilitato solo se l'IP è valido e diverso dal precedente
                    enabled: ipInputField.acceptableInput && ipInputField.text.trim() !== oldIp
                    onClicked: control.submitUpdate()
                }
            }
        }
    }

    onOpened: {
        ipInputField.forceActiveFocus()
    }
}

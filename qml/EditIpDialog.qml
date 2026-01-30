import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Dialog {
    id: control

    // Proprietà per gestire i dati in entrata e uscita
    property string oldIp: ""
    property alias newIpText: ipInputField.text

    // Segnale emesso quando l'utente conferma la modifica
    signal ipUpdated(string oldIp, string newIp)

    modal: true
    width: 400
    height: 250

    // Sfondo coerente con il tema scuro della dashboard
    background: Rectangle {
        color: "#1e222d"
        radius: 12
        border.color: "#333a4d"
        border.width: 1
    }

    contentItem: ColumnLayout {
        anchors.fill: parent
        anchors.margins: 25
        spacing: 20

        Text {
            text: "Modifica Indirizzo IP"
            color: "white"
            font.pixelSize: 20
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
        }

        // Campo di input per il nuovo IP
        TextField {
            id: ipInputField
            Layout.fillWidth: true
            Layout.preferredHeight: 45
            color: "white"
            font.pixelSize: 15
            placeholderText: "Inserisci nuovo IP..."
            placeholderTextColor: "#64748b"
            verticalAlignment: TextInput.AlignVCenter

            background: Rectangle {
                color: "#0f172a"
                radius: 8
                border.color: ipInputField.activeFocus ? "#3b82f6" : "#334155"
                border.width: 1
            }
        }

        // Area bottoni con il tuo preset VpnButton
        RowLayout {
            Layout.fillWidth: true
            spacing: 15
            Layout.topMargin: 10

            VpnButton {
                text: "ANNULLA"
                Layout.fillWidth: true
                onClicked: control.close()
            }

            VpnButton {
                text: "MODIFICA"
                Layout.fillWidth: true
                // Azione di conferma
                onClicked: {
                    let cleanIp = newIpText.toString().trim(); // Usa toString() e trim() (senza ed)
                        if (cleanIp !== "" && cleanIp !== oldIp.toString()) {
                            control.ipUpdated(oldIp.toString(), cleanIp);
                            control.close();
                        }
                }
            }
        }
    }
}

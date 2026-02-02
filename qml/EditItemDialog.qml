import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects

Dialog {
    id: control
    anchors.centerIn: parent

    // Proprietà per gestire i dati in entrata e uscita
    property string oldIp: ""
    property string oldCn: ""
    property alias newIpText: ipInputField.text
    property alias newCnText: cnSuggestField.text

    // Segnale unificato per aggiornare sia IP che CN
    signal itemUpdated(string oldIp, string newIp, string newCn)

    modal: true
    focus: true
    padding: 0
    header: null
    footer: null

    enter: Transition {
        NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 200; easing.type: Easing.OutCubic }
        NumberAnimation { property: "scale"; from: 0.9; to: 1.0; duration: 200; easing.type: Easing.OutBack }
    }

    exit: Transition {
        NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 150; easing.type: Easing.InCubic }
        NumberAnimation { property: "scale"; from: 1.0; to: 0.9; duration: 150; easing.type: Easing.InCubic }
    }

    // Funzione centralizzata per l'invio
    function submitUpdate() {
        let cleanIp = ipInputField.text.trim();
        let cleanCn = cnSuggestField.text.trim();

        // Verifica validità IP (o che sia rimasto invariato se stiamo cambiando solo il CN)
        if (ipInputField.acceptableInput) {
            control.itemUpdated(oldIp, cleanIp, cleanCn);
            control.close();
        }
    }

    background: Rectangle {
        implicitWidth: 400
        implicitHeight: 380 // Aumentata per ospitare comodamente entrambi i campi
        radius: 20
        color: Theme.panel
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

            // HEADER
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8
                Text {
                    text: "Modifica Assegnazione"
                    color: Theme.textMain
                    font.pixelSize: 22
                    font.bold: true
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                }
                Text {
                    text: "Stai modificando l'elemento: " + oldIp
                    color: Theme.textDim
                    font.pixelSize: 13
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            // SEZIONE INPUT IP
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6
                Label {
                    text: "Indirizzo IP"
                    color: Theme.textDim
                    font.pixelSize: 12
                    font.bold: true
                }
                TextField {
                    id: ipInputField
                    Layout.fillWidth: true
                    Layout.preferredHeight: 42
                    color: Theme.textMain
                    font.pixelSize: 14
                    placeholderText: "Indirizzo IP..."
                    placeholderTextColor: Theme.textDim
                    verticalAlignment: TextInput.AlignVCenter

                    validator: RegularExpressionValidator {
                        regularExpression: /^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.?\b){4}$/
                    }

                    background: Rectangle {
                        color: Theme.background
                        radius: 8
                        border.color: ipInputField.activeFocus ? Theme.accent : Theme.border
                        border.width: ipInputField.activeFocus ? 2 : 1
                    }
                }
            }

            // SEZIONE INPUT CN (AutoSuggest)
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6
                Label {
                    text: "Certificato Associato (CN)"
                    color: Theme.textDim
                    font.pixelSize: 12
                    font.bold: true
                }
                AutoSuggestField {
                    id: cnSuggestField
                    Layout.fillWidth: true
                    Layout.preferredHeight: 42
                    suggestions: controller.availableCns
                    placeholderText: "Cerca certificato..."
                    text: oldCn

                    // Al posto di Keys.onPressed usiamo la logica interna dell'AutoSuggestField
                    // che abbiamo già perfezionato per la selezione rapida
                }
            }

            Item { Layout.fillHeight: true }

            // AREA BOTTONI
            RowLayout {
                Layout.fillWidth: true
                spacing: 15

                VpnButton {
                    text: "Annulla"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 42
                    onClicked: control.close()
                }

                VpnButton {
                    id: modifyBtn
                    text: "Salva Modifiche"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 42
                    // Abilitato se l'IP è formalmente corretto e almeno un campo è cambiato
                    enabled: ipInputField.acceptableInput && (ipInputField.text.trim() !== oldIp || cnSuggestField.text.trim() !== oldCn)
                    onClicked: control.submitUpdate()
                }
            }
        }
    }

    onOpened: {
        ipInputField.forceActiveFocus()
    }
}

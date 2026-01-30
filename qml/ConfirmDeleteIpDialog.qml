import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects
import ".." // Per accedere a Theme.qml se necessario

Dialog {
    id: control
    parent: Overlay.overlay
    anchors.centerIn: parent
    modal: true
    focus: true

    // Proprietà dinamiche
    property string titleText: "Elimina Indirizzo IP"
    property string messageText: "" // L'IP da mostrare
    signal confirmed()

    // Dimensioni fisse per un look bilanciato
    implicitWidth: 400
    implicitHeight: 300

    // Animazioni di entrata/uscita
    enter: Transition {
        NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 200; easing.type: Easing.OutCubic }
        NumberAnimation { property: "scale"; from: 0.9; to: 1.0; duration: 200; easing.type: Easing.OutBack }
    }
    exit: Transition {
        NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 150; easing.type: Easing.InCubic }
        NumberAnimation { property: "scale"; from: 1.0; to: 0.9; duration: 150; easing.type: Easing.InCubic }
    }

    background: Rectangle {
        color: Theme.panel
        radius: 20
        border.color: Theme.border
        border.width: 1

        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            color: "#60000000"
            radius: 20
        }
    }

    contentItem: ColumnLayout {
        anchors.fill: parent
        anchors.margins: 30
        spacing: 20

        // SEZIONE ICONA E TITOLO
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 12

            Item {
                Layout.preferredWidth: 64
                Layout.preferredHeight: 64
                Layout.alignment: Qt.AlignHCenter

                // Sfondo circolare tenue per l'icona
                Rectangle {
                    anchors.fill: parent
                    radius: 32
                    color: Theme.darkMode ? "#33ef4444" : "#fee2e2"
                }

                Image {
                    id: warningIcon
                    source: "qrc:/icons/warning.svg" // La tua icona QRC
                    anchors.centerIn: parent
                    width: 32
                    height: 32
                    fillMode: Image.PreserveAspectFit
                    asynchronous: false
                    cache: true
                    mipmap: true
                    visible: false // Nascondiamo l'originale per l'overlay
                }

                ColorOverlay {
                    anchors.fill: warningIcon
                    source: warningIcon
                    color: "#ef4444" // Rosso pericolo standard
                }
            }

            Text {
                text: control.titleText
                color: Theme.textMain
                font.pixelSize: 22
                font.bold: true
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }
        }

        // SEZIONE MESSAGGIO
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            Text {
                text: "Sei sicuro di voler eliminare definitivamente:"
                color: Theme.textDim
                font.pixelSize: 14
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                text: control.messageText
                color: Theme.textMain
                font.pixelSize: 17
                font.bold: true
                font.family: "Monospace"
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }
        }

        Item { Layout.fillHeight: true }

        // BOTTONI DI AZIONE
        RowLayout {
            Layout.fillWidth: true
            spacing: 15

            VpnButton {
                id: cancelBtn
                text: "Annulla"
                Layout.fillWidth: true
                Layout.preferredHeight: 45
                onClicked: control.close()

                contentItem: Text {
                    text: cancelBtn.text
                    color: Theme.textDim
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    color: "transparent"
                    radius: 12
                    border.color: Theme.border
                }
            }

            VpnButton {
                id: deleteBtn
                text: "Elimina"
                Layout.fillWidth: true
                Layout.preferredHeight: 45
                onClicked: {
                    control.confirmed()
                    control.close()
                }

                background: Rectangle {
                    color: deleteBtn.hovered ? "#dc2626" : "#ef4444"
                    radius: 12
                }

                contentItem: Text {
                    text: deleteBtn.text
                    color: "white"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
}

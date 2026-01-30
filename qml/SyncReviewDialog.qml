import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Dialog {
    id: syncReviewDialog
    modal: true
    anchors.centerIn: parent
    width: 500
    height: 450

    // Sfondo personalizzato scuro per il tuo tema
    background: Rectangle {
        color: "#1e293b"
        radius: 12
        border.color: "#334155"
    }

    contentItem: ColumnLayout {
        spacing: 20
        anchors.margins: 20

        Text {
            text: "Sincronizzazione Cloud"
            color: "white"
            font.pixelSize: 22
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
        }

        ListView {
            id: reviewList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 10
            model: controller.pendingChanges // Ora la lista sarà piena!

            delegate: Rectangle {
                width: reviewList.width
                height: 50
                color: "#0f172a"
                radius: 8

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    Text { text: "✎"; color: "#3b82f6" }
                    Text {
                        text: modelData.description
                        color: "white"
                        font.pixelSize: 13
                        Layout.fillWidth: true
                    }
                }
            }
        }

        // Area Bottoni con il tuo stile VpnButton
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            spacing: 15

            VpnButton {
                text: "ANNULLA"
                Layout.fillWidth: true
                onClicked: {
                        controller.discardChanges(); // Chiama la nuova funzione C++
                        syncReviewDialog.close();
                    }
            }

            VpnButton {
                text: "APPLY"
                Layout.fillWidth: true
                // Colore accentato per l'azione principale
                onClicked: {
                    controller.commitSync();
                    syncReviewDialog.close();
                }
            }
        }
    }
}

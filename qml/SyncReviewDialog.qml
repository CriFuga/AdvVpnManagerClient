import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects

Dialog {
    id: syncReviewDialog

    // Posizionamento e logica modale
    parent: Overlay.overlay
    anchors.centerIn: parent
    modal: true
    width: 500
    height: 500 // Leggermente più alto per far spazio alla lista

    // ANIMAZIONI
    enter: Transition {
        NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 200; easing.type: Easing.OutCubic }
        NumberAnimation { property: "scale"; from: 0.9; to: 1.0; duration: 200; easing.type: Easing.OutBack }
    }

    exit: Transition {
        NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 150; easing.type: Easing.InCubic }
        NumberAnimation { property: "scale"; from: 1.0; to: 0.9; duration: 150; easing.type: Easing.InCubic }
    }

    // SFONDO ADATTIVO
    background: Rectangle {
        color: Theme.panel
        radius: 20
        border.color: Theme.border
        border.width: 1

        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            color: "#40000000"
            radius: 20
        }
    }

    contentItem: ColumnLayout {
        spacing: 20
        anchors.margins: 30

        // TITOLO CENTRATO
        Text {
            text: "Sincronizzazione Cloud"
            color: Theme.textMain
            font.pixelSize: 22
            font.bold: true
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
        }

        // LISTA DELLE MODIFICHE
        ListView {
            id: reviewList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 8
            model: controller.pendingChanges

            delegate: Rectangle {
                width: reviewList.width
                height: 54
                // Colore alternativo basato sul tema per staccare dallo sfondo
                color: Theme.darkMode ? "#0f172a" : "#f1f5f9"
                radius: 10
                border.color: Theme.border
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 12

                    Text {
                        text: "✎"
                        color: Theme.accent
                        font.pixelSize: 16
                    }

                    Text {
                        text: modelData.description
                        color: Theme.textMain
                        font.pixelSize: 13
                        font.weight: Font.Medium
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }
                }
            }

            // Scrollbar estetica
            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
            }
        }

        // AREA BOTTONI
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 45
            spacing: 12

            VpnButton {
                text: "CHIUDI"
                Layout.fillWidth: true
                Layout.preferredHeight: 42
                onClicked: syncReviewDialog.close()
                // Stile secondario (testo dim)
                contentItem: Text {
                    text: parent.text
                    color: Theme.textDim
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.bold: true
                }
            }

            VpnButton {
                text: "DISCARD"
                Layout.fillWidth: true
                Layout.preferredHeight: 42
                onClicked: {
                    controller.discardChanges()
                    syncReviewDialog.close()
                }
            }

            VpnButton {
                text: "COMMIT"
                Layout.fillWidth: true
                Layout.preferredHeight: 42
                // Colore accentato per l'azione principale
                onClicked: {
                    controller.commitSync()
                    syncReviewDialog.close()
                }

                background: Rectangle {
                    color: parent.enabled ? (parent.hovered ? Qt.darker(Theme.accent, 1.1) : Theme.accent) : "#334155"
                    radius: 10
                }
                contentItem: Text {
                    text: parent.text
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.bold: true
                }
            }
        }
    }
}

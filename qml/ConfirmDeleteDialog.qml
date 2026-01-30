import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects

Dialog {
    id: control
    property string titleText: ""
    property string messageText: ""
    signal confirmed()

    anchors.centerIn: parent
    modal: true
    padding: 0

    // Dimensioni fisse per rompere il binding loop
    implicitWidth: 420
    implicitHeight: mainLayout.implicitHeight + 40

    background: Rectangle {
        color: Theme.darkMode ? "#1e222d" : "#ffffff"
        radius: 18
        border.color: Theme.darkMode ? "#2e3446" : "#e2e8f0"

        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            color: "#60000000"
            radius: 20
        }
    }

    contentItem: ColumnLayout {
        id: mainLayout
        spacing: 20
        anchors.margins: 30

        // Header centrato con Icona
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 15

            Rectangle {
                width: 36; height: 36; radius: 18
                color: "#fef2f2"
                Text {
                    anchors.centerIn: parent
                    text: "!"
                    color: "#ef4444"
                    font.bold: true
                    font.pixelSize: 18
                }
            }

            Label {
                text: control.titleText
                color: Theme.darkMode ? "#ffffff" : "#1e293b"
                font.bold: true
                font.pixelSize: 20
            }
        }

        // Testo dell'IP centrato e stilizzato
        Label {
            text: control.messageText
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            color: Theme.darkMode ? "#94a3b8" : "#64748b"
            font.pixelSize: 16
            //font.family: "Monospace" // Rende l'IP più leggibile
            wrapMode: Text.WordWrap
        }

        // Bottoni compatti e centrati
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 15

            VpnButton {
                text: "Annulla"
                Layout.preferredWidth: 100
                Layout.preferredHeight: 38
                onClicked: control.close()
            }

            VpnButton {
                id: delBtn
                text: "Elimina"
                Layout.preferredWidth: 100
                Layout.preferredHeight: 38
                // Stile rosso per il tasto Elimina
                contentItem: Text {
                    text: delBtn.text
                    color: "white"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle {
                    color: delBtn.pressed ? "#b91c1c" : "#ef4444"
                    radius: 10
                }
                onClicked: {
                    control.confirmed()
                    control.close()
                }
            }
        }
    }
}

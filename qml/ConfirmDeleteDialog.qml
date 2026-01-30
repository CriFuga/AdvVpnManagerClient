import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects

Dialog {
    id: control
    property string titleText: ""
    property string messageText: ""
    signal confirmed()

    enter: Transition {
        NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 200; easing.type: Easing.OutCubic }
        NumberAnimation { property: "scale"; from: 0.9; to: 1.0; duration: 200; easing.type: Easing.OutBack }
    }

    // ANIMAZIONE DI USCITA (Fade out + Scale down)
    exit: Transition {
        NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 150; easing.type: Easing.InCubic }
        NumberAnimation { property: "scale"; from: 1.0; to: 0.9; duration: 150; easing.type: Easing.InCubic }
    }

    anchors.centerIn: parent
    modal: true
    padding: 0
    header: null
    footer: null

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
            color: Theme.darkMode ? "#60000000" : "#20000000" // Ombra più leggera in light mode
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
                color: "#fef2f2" // Sfondo rosso chiarissimo per l'icona
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
                color: Theme.darkMode ? "#ffffff" : "#1e293b" // Blu notte profondo per light mode
                font.bold: true
                font.pixelSize: 20
            }
        }

        // Testo del messaggio centrato
        Label {
            text: control.messageText
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            // Colore più scuro in light mode per leggibilità
            color: Theme.darkMode ? "#94a3b8" : "#334155"
            font.pixelSize: 16
            wrapMode: Text.WordWrap
            lineHeight: 1.2
        }

        // Bottoni compatti e centrati
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 15

            VpnButton {
                id: cancelBtn
                text: "Annulla"
                Layout.preferredWidth: 100
                Layout.preferredHeight: 38

                contentItem: Text {
                    text: cancelBtn.text
                    // Grigio scuro/Blu in light mode, bianco in dark
                    color: Theme.darkMode ? "#ffffff" : "#475569"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    color: "transparent"
                    radius: 10
                    border.color: Theme.darkMode ? "#333a4d" : "#cbd5e1"
                    border.width: 1
                }

                onClicked: control.close()
            }

            VpnButton {
                id: delBtn
                text: "Elimina"
                Layout.preferredWidth: 100
                Layout.preferredHeight: 38

                contentItem: Text {
                    text: delBtn.text
                    color: "white"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    // Gradiente di rosso: più scuro se premuto
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

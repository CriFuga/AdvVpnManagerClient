import QtQuick 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects

Rectangle {
    id: root
    property alias text: label.text
    property bool showRequested: false

    visible: opacity > 0
    z: 9999
    radius: 25 // Leggermente più arrotondato per richiamare lo stile dei bottoni

    // Sfondo: In Dark Mode lo teniamo scuro, in Light Mode lo facciamo bianco puro
    color: Theme.darkMode ? "#1e293b" : "#ffffff"

    // --- IL BORDO COORDINATO ---
    // Usiamo lo stesso spessore (2) e colore (accent) dei tuoi bottoni nella Toolbar
    border.color: Theme.accent || "#2563eb"
    border.width: Theme.darkMode ? 1.5 : 2 // Un po' più sottile in Dark Mode per non appesantire

    // Dimensioni dinamiche in base al testo
    width: layout.implicitWidth + 60
    height: 50
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom // <--- AGGIUNTA FONDAMENTALE

    // Ombra per dare profondità (fondamentale in Light Mode)
    layer.enabled: true
    layer.effect: DropShadow {
        transparentBorder: true
        color: Theme.darkMode ? "#80000000" : "#302563eb" // Ombra bluastra in Light Mode per l'effetto Glow
        radius: 15
        samples: 20
        verticalOffset: 4
    }

    RowLayout {
        id: layout
        anchors.centerIn: parent
        spacing: 12

        Image {
            id: infoIcon
            source: "qrc:/icons/info.svg"
            sourceSize: Qt.size(20, 20)
            smooth: true

            // Tinta l'icona con il colore accent per uniformità totale
            layer.enabled: true
            layer.effect: ColorOverlay {
                color: Theme.accent || "#2563eb"
            }
        }

        Text {
            id: label
            // Colore testo: Accento in Light Mode, Bianco in Dark Mode
            color: Theme.darkMode ? "#ffffff" : (Theme.accent || "#2563eb")
            font.pixelSize: 14
            font.weight: Font.DemiBold
        }
    }

    // Comportamenti fluidi per il cambio tema
    Behavior on color { ColorAnimation { duration: 300 } }
    Behavior on border.color { ColorAnimation { duration: 300 } }

    // --- LOGICA ANIMAZIONE (Invariata) ---
    states: [
        State {
            name: "visible"
            when: root.showRequested
            PropertyChanges { target: root; opacity: 1; anchors.bottomMargin: 40 }
        },
        State {
            name: "hidden"
            when: !root.showRequested
            PropertyChanges { target: root; opacity: 0; anchors.bottomMargin: 10 }
        }
    ]
    state: "hidden"
    Behavior on opacity { NumberAnimation { duration: 250 } }
    Behavior on anchors.bottomMargin {
        NumberAnimation { duration: 450; easing.type: Easing.OutBack }
    }
}

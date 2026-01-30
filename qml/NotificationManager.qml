import QtQuick 2.15

Item {
    id: root
    property var toastElement

    function show(msg) {
        if (!toastElement) return

        hideTimer.stop()
        toastElement.text = msg
        toastElement.showRequested = true
    }

    // AGGIUNGI QUESTA FUNZIONE
    function hide() {
        if (!toastElement || !toastElement.showRequested) return
        hideTimer.restart() // Avvia il countdown di 2 secondi prima di chiudere davvero
    }

    Timer {
        id: hideTimer
        interval: 2000 // I tuoi 2 secondi di "grazia"
        onTriggered: {
            if (toastElement) toastElement.showRequested = false
        }
    }
}

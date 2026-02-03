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

    function hide() {
        if (!toastElement || !toastElement.showRequested) return
        hideTimer.restart()
    }

    Timer {
        id: hideTimer
        interval: 2000
        onTriggered: {
            if (toastElement) toastElement.showRequested = false
        }
    }
}

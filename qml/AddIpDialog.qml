import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects

Dialog {
    id: control

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
    focus: true
    padding: 0
    header: null
    footer: null

    signal ipAdded(string ip)

    function submitIp() {
        if (ipInput.acceptableInput) {
            control.ipAdded(ipInput.text.trim())
            ipInput.clear()
            control.close()
        }
    }

    background: Rectangle {
        implicitWidth: 380
        implicitHeight: 280
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

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "Aggiungi Nuovo IP"
                    color: Theme.textMain
                    font.pixelSize: 22
                    font.bold: true
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                }

                Text {
                    text: "Inserisci l'indirizzo IPv4 per questo gruppo"
                    color: Theme.textDim
                    font.pixelSize: 14
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            TextField {
                id: ipInput
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                placeholderText: "Es: 10.128.2.1"
                color: Theme.textMain
                font.pixelSize: 15
                horizontalAlignment: Text.AlignHCenter

                validator: RegularExpressionValidator {
                    regularExpression: /^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.?\b){4}$/
                }

                background: Rectangle {
                    color: Theme.background
                    radius: 10
                    border.color: ipInput.activeFocus ? Theme.accent : Theme.border
                    border.width: ipInput.activeFocus ? 2 : 1
                }

                Keys.onPressed: (event) => {
                                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                        control.submitIp()
                                        event.accepted = true
                                    }
                                }
            }

            Item { Layout.fillHeight: true }

            RowLayout {
                Layout.fillWidth: true
                spacing: 15

                VpnButton {
                    id: cancelBtn
                    text: "Cancel"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 42
                    onClicked: control.close()
                }

                VpnButton {
                    id: confirmBtn
                    text: "Add"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 42
                    enabled: ipInput.acceptableInput
                    onClicked: control.submitIp()
                }
            }
        }
    }

    onOpened: {
        ipInput.forceActiveFocus()
    }
}

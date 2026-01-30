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

    signal groupAdded(string name)

    // Funzione centralizzata per l'invio
    function submit() {
        let name = groupNameInput.text.trim()
        if (name.length > 0) {
            control.groupAdded(name)
            groupNameInput.clear()
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

        // Ombra per staccare dal background
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

            // HEADER CENTRATO
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "Crea Nuovo Gruppo"
                    color: Theme.textMain
                    font.pixelSize: 22
                    font.bold: true
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                }

                Text {
                    text: "Assegna un nome univoco al gruppo"
                    color: Theme.textDim
                    font.pixelSize: 14
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            // CAMPO DI INPUT
            TextField {
                id: groupNameInput
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                placeholderText: "Es: Server Web"
                color: Theme.textMain
                font.pixelSize: 15
                horizontalAlignment: Text.AlignHCenter
                focus: true

                background: Rectangle {
                    color: Theme.background
                    radius: 10
                    border.color: groupNameInput.activeFocus ? Theme.accent : Theme.border
                    border.width: groupNameInput.activeFocus ? 2 : 1
                }

                Keys.onPressed: (event) => {
                                    if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                                        control.submit()
                                        event.accepted = true
                                    }
                                }
            }

            Item { Layout.fillHeight: true }

            // BOTTONI
            RowLayout {
                Layout.fillWidth: true
                spacing: 15

                VpnButton {
                    id: cancelBtn
                    text: "Annulla"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 42
                    onClicked: control.close()

                    contentItem: Text {
                        text: cancelBtn.text
                        color: Theme.textDim
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.bold: true
                    }

                    background: Rectangle {
                        color: cancelBtn.hovered ? (Theme.darkMode ? "#15ffffff" : "#08000000") : "transparent"
                        radius: 10
                        border.color: Theme.border
                    }
                }

                VpnButton {
                    id: confirmBtn
                    text: "Crea"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 42
                    enabled: groupNameInput.text.trim().length > 0
                    onClicked: control.submit()

                    background: Rectangle {
                        color: confirmBtn.enabled ? (confirmBtn.hovered ? Qt.darker(Theme.accent, 1.1) : Theme.accent) : "#334155"
                        radius: 10
                    }

                    contentItem: Text {
                        text: confirmBtn.text
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.bold: true
                    }
                }
            }
        }
    }

    onOpened: {
        groupNameInput.forceActiveFocus()
    }
}

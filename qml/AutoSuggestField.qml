import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt5Compat.GraphicalEffects

TextField {
    id: control

    property var suggestions: []
    property alias popupOpened: popup.visible // Permette al Delegate di vedere se è aperto
    property alias listModel: suggestModel

    color: Theme.textMain
    placeholderTextColor: Theme.textDim
    font.pixelSize: 13
    leftPadding: 10
    rightPadding: clearButton.visible ? 30 : 10
    selectByMouse: true
    selectionColor: Theme.accent

    // Gestione tastiera
    Keys.onPressed: (event) => {
                        if (popup.visible) {
                            if (event.key === Qt.Key_Down) {
                                suggestList.currentIndex = (suggestList.currentIndex + 1) % suggestList.count
                                event.accepted = true
                            } else if (event.key === Qt.Key_Up) {
                                suggestList.currentIndex = (suggestList.currentIndex - 1 + suggestList.count) % suggestList.count
                                event.accepted = true
                            } else if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                                if (suggestList.currentIndex !== -1) {
                                    control.text = suggestModel.get(suggestList.currentIndex).value
                                    popup.close()
                                }
                                event.accepted = true
                            }
                        }
                    }

    background: Rectangle {
        radius: 6
        color: Theme.darkMode ? "#1e293b" : "#f8fafc"
        border.color: control.activeFocus ? Theme.accent : Theme.border
        border.width: 1

        // La "X" (Corretta)
        Item {
            id: clearButton
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: 28; height: 28
            visible: control.text.length > 0

            Text {
                anchors.centerIn: parent
                text: "✕"
                font.pixelSize: 10
                color: Theme.textDim
                opacity: mouseXClear.containsMouse ? 1.0 : 0.6
            }

            MouseArea {
                id: mouseXClear
                anchors.fill: parent
                hoverEnabled: true
                // Blocco fondamentale per far funzionare il click nei Popup/TextField
                onPressed: (mouse) => mouse.accepted = true
                onReleased: (mouse) => {
                                if (containsMouse) {
                                    control.text = ""
                                    control.forceActiveFocus()
                                    popup.close()
                                }
                            }
            }
        }
    }

    ListModel { id: suggestModel }

    onTextChanged: {
        suggestModel.clear()
        // Controllo di sicurezza: suggestions deve esistere ed essere un array
        if (suggestions && text.length > 0 && activeFocus) {
            var found = false
            for (var i = 0; i < suggestions.length; i++) { // Ciclo for classico più sicuro
                var s = suggestions[i]
                if (s && s.toLowerCase().includes(text.toLowerCase())) {
                    suggestModel.append({ "value": s })
                    found = true
                }
            }
            popup.visible = found
            if (found) suggestList.currentIndex = 0
        } else {
            popup.visible = false
        }
    }

    Popup {
        id: popup
        y: control.height + 4
        width: control.width
        padding: 0
        focus: false
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        // Animazioni più veloci e sobrie
        enter: Transition {
            NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 150 }
            NumberAnimation { property: "y"; from: control.height; to: control.height + 4; duration: 150; easing.type: Easing.OutCubic }
        }

        exit: Transition {
            NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 100 }
            NumberAnimation { property: "y"; from: control.height + 4; to: control.height + 8; duration: 100 }
        }

        background: Rectangle {
            radius: 8
            color: Theme.panel
            border.color: Theme.border
            // Ombra quasi impercettibile, molto più elegante
            layer.enabled: true
            layer.effect: DropShadow {
                transparentBorder: true
                color: "#20000000"
                radius: 8
                samples: 12
            }
        }

        contentItem: ListView {
            id: suggestList
            implicitHeight: Math.min(count * 32, 160)
            model: suggestModel
            clip: true

            delegate: ItemDelegate {
                width: control.width
                height: 32
                highlighted: ListView.isCurrentItem

                contentItem: Text {
                    text: model.value
                    color: highlighted ? Theme.textMain : Theme.textMain
                    font.pixelSize: 12
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 10
                    elide: Text.ElideRight
                }

                background: Rectangle {
                    // Selezione discreta (grigio chiaro invece di blu elettrico)
                    color: highlighted ? (Theme.darkMode ? "#2d3748" : "#f1f5f9") : "transparent"
                    radius: 4
                    anchors.fill: parent
                    anchors.margins: 2
                }

                onClicked: {
                    control.text = model.value
                    popup.close()
                }
            }
        }
    }
}

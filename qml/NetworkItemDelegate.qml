import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects

ItemDelegate {
    id: delegateRoot
    height: 85
    width: parent ? parent.width : 0

    property string cn: ""
    property string ipValue: ""
    property bool isEditing: false

    signal setCn(string ip, string newCn)

    background: Rectangle {
        radius: 12
        color: Theme.cardBackground
        border.color: delegateRoot.hovered ? Theme.accent : Theme.border
        border.width: 1

        // Transizione fluida per il bordo al passaggio del mouse
        Behavior on border.color { ColorAnimation { duration: 150 } }
    }

    contentItem: RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 20
        anchors.rightMargin: 15
        spacing: 20

        // --- ICONA STATO IP ---
        Rectangle {
            width: 44; height: 44; radius: 22
            color: cn !== "" ? (Theme.darkMode ? "#064e3b" : "#d1fae5")
                             : (Theme.darkMode ? "#1e293b" : "#f1f5f9")

            border.color: cn !== "" ? "#10b981" : (Theme.darkMode ? "#3b82f6" : "#cbd5e1")
            border.width: 2
            Layout.alignment: Qt.AlignVCenter

            Text {
                anchors.centerIn: parent
                text: "IP"
                font.bold: true
                font.pixelSize: 13
                color: cn !== "" ? "#10b981" : (Theme.darkMode ? "#3b82f6" : "#64748b")
            }
        }

        // --- AREA TESTI ---
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4
            Layout.alignment: Qt.AlignVCenter

            Label {
                text: ipValue
                color: Theme.darkMode ? "#f8fafc" : "#1e293b"
                font.bold: true
                font.pixelSize: 17
                Layout.fillWidth: true
            }

            Item {
                id: cnContainer
                Layout.fillWidth: true
                Layout.preferredHeight: 32

                // Visualizzazione CN
                Label {
                    visible: !isEditing && cn !== ""
                    anchors.fill: parent
                    text: "✓ " + cn
                    color: Theme.darkMode ? "#10b981" : "#059669"
                    font.pixelSize: 14
                    font.weight: Font.Medium
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: isEditing = true
                    }
                }

                // Campo CN (Larghezza limitata per estetica)
                AutoSuggestField {
                    id: suggestField
                    visible: isEditing || cn === ""

                    // Limitiamo la larghezza del campo CN al 60% dell'area disponibile
                    width: Math.min(parent.width * 0.6, 300)
                    height: parent.height

                    suggestions: controller.availableCertificates || []
                    placeholderText: "Assegna CN..."
                    text: isEditing ? cn : ""

                    onVisibleChanged: {
                        if (visible && isEditing) forceActiveFocus()
                    }

                    onAccepted: {
                        delegateRoot.setCn(ipValue, text)
                        isEditing = false
                    }

                    onActiveFocusChanged: {
                        if (!activeFocus && !popupOpened) isEditing = false
                    }

                    background: Rectangle {
                        // Colore dinamico per il campo di testo
                        color: Theme.darkMode ? "#0f172a" : "#f1f5f9"
                        radius: 6
                        border.color: suggestField.activeFocus ? Theme.accent : (Theme.darkMode ? "#334155" : "#cbd5e1")
                        border.width: 1
                    }
                }
            }
        }

        // --- TASTO ELIMINA (Hover fluido e Icona nitida) ---
        VpnButton {
            id: deleteBtn
            Layout.preferredWidth: 38
            Layout.preferredHeight: 38

            // Animazione di opacità e leggero spostamento X per fluidità
            opacity: delegateRoot.hovered ? 1.0 : 0.0
            scale: delegateRoot.hovered ? 1.0 : 0.8

            contentItem: Item {
                Image {
                    id: binIcon
                    anchors.centerIn: parent
                    source: "qrc:/icons/bin.svg"
                    width: 20
                    height: 20
                    fillMode: Image.PreserveAspectFit
                    mipmap: true // Migliora la nitidezza in Light Mode
                    visible: false
                }

                ColorOverlay {
                    anchors.fill: binIcon
                    source: binIcon
                    color: deleteBtn.hovered ? "#ff4444" : "#ef4444"
                }
            }

            background: Rectangle {
                color: deleteBtn.hovered ? (Theme.darkMode ? "#22ffffff" : "#11000000") : "transparent"
                radius: 19
            }

            onClicked: {
                deleteIpDialog.messageText = ipValue
                deleteIpDialog.open()
            }

            Behavior on opacity { NumberAnimation { duration: 150 } }
            Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
        }
    }
}

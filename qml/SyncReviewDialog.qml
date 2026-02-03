import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects

Dialog {
    id: syncReviewDialog
    title: "Revisione Sincronizzazione"
    modal: true
    anchors.centerIn: parent
    width: 600
    height: 500
    standardButtons: Dialog.NoButton

    background: Rectangle {
        color: "#1e293b"
        radius: 16
        border.color: "#334155"
    }

    contentItem: ColumnLayout {
        spacing: 20

        // --- HEADER ---
        ColumnLayout {
            Layout.fillWidth: true
            Layout.margins: 10
            spacing: 4
            Text {
                text: "Sincronizzazione Cloud"
                color: "white"
                font.pixelSize: 20; font.bold: true
            }
            Text {
                text: syncModel.rowCount + " modifiche in attesa"
                color: "#94a3b8"; font.pixelSize: 13
            }
        }

        // --- LISTA MODIFICHE ---
        ListView {
            id: syncListView
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: syncModel
            clip: true
            spacing: 12

            delegate: Rectangle {
                // Rimosso l'ancoraggio errato che causava il crash
                width: syncListView.width - 20
                anchors.horizontalCenter: syncListView.horizontalCenter // <--- Usa l'ID della ListView, non 'parent'

                // Altezza dinamica corretta
                implicitHeight: itemLayout.implicitHeight + 24
                radius: 12
                color: "#0f172a"
                border.color: isGroupAction ? "#3b82f6" : "#334155"

                RowLayout {
                    id: itemLayout
                    // Corretto: Usiamo il sistema di layout invece delle anchors interne
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 15

                    // Icona con ColorOverlay
                    Item {
                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 32
                        Layout.alignment: Qt.AlignVCenter
                        Image {
                            id: actionIcon
                            anchors.fill: parent
                            sourceSize: Qt.size(32, 32)
                            source: {
                                if (isGroupAction) return "qrc:/icons/group.svg"
                                if (type === 1 || type === 4) return "qrc:/icons/bin.svg"
                                if (type === 2 || type === 6) return "qrc:/icons/edit.svg"
                                return "qrc:/icons/info.svg"
                            }
                            visible: false
                        }
                        ColorOverlay {
                            anchors.fill: actionIcon; source: actionIcon
                            color: (type === 1 || type === 4) ? "#ef4444" :
                                   (type === 0 || type === 3) ? "#10b981" : "#3b82f6"
                        }
                    }

                    // Testo con WordWrap
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        Text {
                            text: description
                            color: "white"; font.pixelSize: 14; font.bold: true
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }
                        Text {
                            text: "Target: " + targetId
                            color: "#64748b"; font.pixelSize: 11
                        }
                    }

                    // Tasto Undo
                    Button {
                        id: undoBtn
                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 32
                        onClicked: syncModel.undo(index)
                        background: Rectangle {
                            color: undoBtn.hovered ? "#1e293b" : "transparent"
                            radius: 16
                        }
                        contentItem: Text {
                            text: "↺"
                            color: undoBtn.hovered ? "#3b82f6" : "#94a3b8"
                            font.pixelSize: 20; horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }
            }

            // Placeholder
            Text {
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Layout.fillWidth: true
                text: "Tutto sincronizzato.\nNessuna modifica pendente."
                color: "#475569"
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
                visible: syncModel.rowCount === 0
            }
        }

        // --- FOOTER ---
        RowLayout {
            Layout.fillWidth: true
            Layout.margins: 15
            spacing: 15
            Button {
                text: "Chiudi"; Layout.fillWidth: true; Layout.preferredHeight: 45
                onClicked: syncReviewDialog.reject()
            }
            Button {
                id: syncBtn
                text: "Invia al Cloud (" + syncModel.rowCount + ")"
                Layout.fillWidth: true; Layout.preferredHeight: 45
                enabled: syncModel.rowCount > 0
                onClicked: {
                    controller.commitSync()
                    syncReviewDialog.accept()
                }
            }
        }
    }
}

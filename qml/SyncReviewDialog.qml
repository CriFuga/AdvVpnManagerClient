import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects

Popup {
    id: syncPopup
    anchors.centerIn: Overlay.overlay
    width: Math.min(650, parent.width * 0.9)
    height: Math.min(550, parent.height * 0.8)
    modal: true
    focus: true

    enter: Transition {
        NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 200 }
        NumberAnimation { property: "scale"; from: 0.9; to: 1.0; duration: 200; easing.type: Easing.OutBack }
    }

    Overlay.modal: Rectangle {
        color: "#AA000000"
    }

    background: Rectangle {
        radius: 24
        color: Theme.cardBackground
        border.color: Theme.border
        border.width: 1
    }

    contentItem: ColumnLayout {
        spacing: 25
        anchors.margins: 10

        // Header con la tua icona Cloud
        RowLayout {
            spacing: 15
            Item {
                width: 40; height: 40
                Image {
                    id: cloudIcon
                    source: "qrc:/icons/cloud_on.svg"
                    anchors.fill: parent
                    sourceSize: Qt.size(40, 40)
                    visible: false
                }
                ColorOverlay {
                    anchors.fill: cloudIcon
                    source: cloudIcon
                    color: Theme.accent
                }
            }
            ColumnLayout {
                spacing: 2
                Text {
                    text: "Sincronizzazione Cloud"
                    font.pixelSize: 24; font.bold: true
                    color: Theme.textMain
                }
                Text {
                    text: controller.pendingChangesCount + " modifiche registrate nel buffer"
                    font.pixelSize: 14; color: Theme.textDim
                }
            }
        }

        ListView {
            id: syncListView
            Layout.fillWidth: true; Layout.fillHeight: true
            model: syncModel
            spacing: 12; clip: true

            delegate: Rectangle {
                width: syncListView.width; height: 75; radius: 16
                color: Theme.darkMode ? "#1e293b" : "#f1f5f9"
                border.color: Theme.border

                RowLayout {
                    anchors.fill: parent; anchors.margins: 15; spacing: 15

                    // Icona dinamica: usa bin.svg per le eliminazioni
                    Item {
                        width: 32; height: 32
                        Image {
                            id: actionIcon
                            source: model.type === 5 ? "qrc:/icons/bin.svg" : "qrc:/icons/edit.svg"
                            anchors.fill: parent
                            sourceSize: Qt.size(32, 32)
                            visible: false
                        }
                        ColorOverlay {
                            anchors.fill: actionIcon
                            source: actionIcon
                            color: model.type === 5 ? "#ef4444" : Theme.accent
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true; spacing: 2
                        Text {
                            text: model.description; color: Theme.textMain
                            font.bold: true; font.pixelSize: 14; elide: Text.ElideRight
                        }
                        Text {
                            text: "Target ID: " + model.targetId; color: Theme.textDim
                            font.pixelSize: 12
                        }
                    }

                    // Il tuo tasto Undo con l'icona undo.svg
                    VpnButton {
                        Layout.preferredWidth: 36; Layout.preferredHeight: 36
                        onClicked: syncModel.undo(index)
                        contentItem: Item {
                            Image {
                                id: undoImg
                                source: "qrc:/icons/undo.svg"
                                anchors.centerIn: parent
                                width: 18; height: 18
                                visible: false
                            }
                            ColorOverlay {
                                anchors.fill: undoImg; source: undoImg
                                color: Theme.textMain
                            }
                        }
                    }
                }
            }

            // Placeholder quando non ci sono modifiche
            ColumnLayout {
                anchors.centerIn: parent
                visible: syncListView.count === 0
                spacing: 10
                Image {
                    source: "qrc:/icons/check.svg"
                    Layout.alignment: Qt.AlignHCenter
                    sourceSize: Qt.size(48, 48)
                }
                Label {
                    text: "Tutto sincronizzato.\nNessuna modifica pendente."
                    horizontalAlignment: Text.AlignHCenter
                    color: Theme.textDim; font.pixelSize: 16
                }
            }
        }

        RowLayout {
            spacing: 15; Layout.fillWidth: true
            VpnButton {
                text: "Chiudi"; Layout.fillWidth: true; Layout.preferredHeight: 48
                onClicked: syncPopup.close()
            }
            VpnButton{
                text: "Discard"
                Layout.fillWidth: true; Layout.preferredHeight: 48
                enabled: controller.pendingChangesCount > 0
                onClicked: {
                    controller.discardChanges();
                    syncPopup.close();
                }
            }
            VpnButton {
                text: "Invia al Cloud (" + controller.pendingChangesCount + ")"
                Layout.fillWidth: true; Layout.preferredHeight: 48
                enabled: controller.pendingChangesCount > 0
                onClicked: {
                    controller.commitSync();
                    syncPopup.close();
                }
            }
        }
    }
}

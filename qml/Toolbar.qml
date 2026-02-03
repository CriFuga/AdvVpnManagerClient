import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects


Rectangle {
    id: root
    Layout.fillWidth: true
    Layout.preferredHeight: 70
    color: Theme.panel || "#ffffff"
    Behavior on color {
        ColorAnimation { duration: 400; easing.type: Easing.InOutQuad }
    }

    property string title: ""
    signal syncRequested()

    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        color: Theme.border || "#e2e8f0"
        Behavior on color { ColorAnimation { duration: 400 } }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 25
        anchors.rightMargin: 25
        spacing: 20

        // Title Area
        ColumnLayout {
            spacing: 2
            Layout.alignment: Qt.AlignVCenter
            Text {
                text: root.title
                font.pixelSize: 20
                font.bold: true
                color: Theme.textMain || "#0f172a"
            }
            Text {
                text: "Manage network assignments"
                font.pixelSize: 12
                color: Theme.textDim || "#64748b"
            }
        }

        Item { Layout.fillWidth: true }

        RowLayout {
            spacing: 15
            Layout.alignment: Qt.AlignVCenter

            Button {
                id: themeBtn
                Layout.preferredHeight: 42
                Layout.preferredWidth: 42
                onClicked: Theme.darkMode = !Theme.darkMode

                background: Rectangle {
                    color: themeBtn.hovered ? (Theme.darkMode ? "#2d3748" : "#f1f5f9") : "transparent"
                    radius: 10
                }

                contentItem: Item {
                    Image {
                        anchors.centerIn: parent
                        source: Theme.darkMode ? "qrc:/icons/light_mode.svg" : "qrc:/icons/dark_mode.svg"
                        mipmap: true
                        smooth: true
                        sourceSize: Qt.size(22, 22)
                        antialiasing: true

                        rotation: Theme.darkMode ? 180 : 0
                        Behavior on rotation {
                            NumberAnimation { duration: 600; easing.type: Easing.OutBack }
                        }
                    }
                }
            }

            VpnButton {
                text: "SYNC TO CLOUD"
                iconSource: "qrc:/icons/cloud_on.svg"
                onClicked: {
                    if (controller.pendingChangesCount > 0) {
                        syncReviewDialog.open()
                    } else {
                        console.log("Nessuna modifica da sincronizzare. Conteggio attuale: " + controller.pendingChangesCount)
                    }
                }
            }
        }
    }
}

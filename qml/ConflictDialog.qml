import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects

Rectangle {
    id: root

    anchors.fill: parent
    color: "#CC000000"
    visible: controller.conflictMessages.length > 0

    property var messages: controller.conflictMessages
    signal dismiss()

    Rectangle {
        id: dialogBox
        width: Math.min(parent.width * 0.9, 650)
        height: Math.min(parent.height * 0.8, 550)
        anchors.centerIn: parent
        radius: 24

        color: Theme.panel || "#1e293b"
        border.color: Theme.border || "#334155"
        border.width: 1

        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            color: "#80000000"
            radius: 20
            samples: 25
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 30
            spacing: 20

            RowLayout {
                spacing: 15
                Layout.fillWidth: true

                Item {
                    width: 32; height: 32
                    Image {
                        id: warnIcon
                        source: "qrc:/icons/warning.svg"
                        smooth: true
                        mipmap: true
                        anchors.fill: parent
                        sourceSize: Qt.size(32, 32)
                    }
                    ColorOverlay {
                        anchors.fill: warnIcon
                        source: warnIcon
                        color: "#ef4444"
                    }
                }

                Text {
                    text: "Conflicts Detected"
                    font.pixelSize: 22
                    font.bold: true
                    color: Theme.textMain || "#ffffff"
                    Layout.fillWidth: true
                }
            }

            Text {
                text: "The following IP addresses are already assigned"
                font.pixelSize: 14
                color: Theme.textDim || "#94a3b8"
                Layout.fillWidth: true
            }

            ListView {
                id: conflictList
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: controller.conflictMessages
                clip: true
                spacing: 10

                delegate: Rectangle {
                    width: conflictList.width
                    height: contentText.implicitHeight + 30
                    radius: 12
                    color: Theme.darkMode ? "#25ef4444" : "#08ef4444"
                    border.color: "#40ef4444"

                    Text {
                        id: contentText
                        anchors.centerIn: parent
                        width: parent.width - 40
                        text: modelData
                        wrapMode: Text.WordWrap
                        color: Theme.darkMode ? "#ff9999" : "#b91c1c"
                        font.pixelSize: 13
                        lineHeight: 1.2
                    }
                }
            }

            VpnButton {
                text: "Dismiss"
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 140
                Layout.preferredHeight: 45
                onClicked: root.dismiss()
            }
        }
    }
}

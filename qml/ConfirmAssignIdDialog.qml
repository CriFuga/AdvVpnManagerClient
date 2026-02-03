import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects

Dialog {
    id: control
    parent: Overlay.overlay
    anchors.centerIn: parent
    modal: true
    focus: true

    property string ipTarget: ""
    property string cnValue: ""
    signal confirmed(string ip, string cn)

    implicitWidth: 400
    implicitHeight: 320

    enter: Transition {
        NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 200; easing.type: Easing.OutCubic }
        NumberAnimation { property: "scale"; from: 0.9; to: 1.0; duration: 200; easing.type: Easing.OutBack }
    }

    background: Rectangle {
        color: Theme.panel
        radius: 20
        border.color: Theme.border
        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            color: "#60000000"
            radius: 20
        }
    }

    contentItem: ColumnLayout {
        anchors.fill: parent
        anchors.margins: 30
        spacing: 20

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 12

            Rectangle {
                width: 64; height: 64; radius: 32
                color: Theme.darkMode ? "#333b82f6" : "#dbeafe"
                Layout.alignment: Qt.AlignHCenter

                Text {
                    anchors.centerIn: parent
                    text: "ID"
                    color: "#3b82f6"
                    font.pixelSize: 24
                    font.bold: true
                }
            }

            Text {
                text: "Confirm Assignment"
                color: Theme.textMain
                font.pixelSize: 22
                font.bold: true
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8

            Text {
                text: "You are assigning the id:"
                color: Theme.textDim
                font.pixelSize: 14
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                text: control.cnValue
                color: Theme.accent
                font.pixelSize: 16
                font.bold: true
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideMiddle
            }

            Text {
                text: "to the IP: " + control.ipTarget
                color: Theme.textDim
                font.pixelSize: 13
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 15

            VpnButton {
                text: "Cancel"
                Layout.fillWidth: true
                Layout.preferredHeight: 45
                onClicked: control.close()
            }

            VpnButton {
                id: confirmBtn
                text: "Confirm"
                Layout.fillWidth: true
                Layout.preferredHeight: 45
                onClicked: {
                    control.confirmed(control.ipTarget, control.cnValue)
                    control.close()
                }
                background: Rectangle {
                    color: confirmBtn.hovered ? Qt.darker(Theme.accent, 1.1) : Theme.accent
                    radius: 12
                }
                contentItem: Text {
                    text: confirmBtn.text
                    color: "white"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
}

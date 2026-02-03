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

    property string groupName: ""
    signal confirmed()

    implicitWidth: 420
    implicitHeight: 320

    enter: Transition {
        NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 200; easing.type: Easing.OutCubic }
        NumberAnimation { property: "scale"; from: 0.9; to: 1.0; duration: 200; easing.type: Easing.OutBack }
    }
    exit: Transition {
        NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 150; easing.type: Easing.InCubic }
        NumberAnimation { property: "scale"; from: 1.0; to: 0.9; duration: 150; easing.type: Easing.InCubic }
    }

    background: Rectangle {
        color: Theme.panel
        radius: 20
        border.color: Theme.border
        border.width: 1

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

            Item {
                Layout.preferredWidth: 64
                Layout.preferredHeight: 64
                Layout.alignment: Qt.AlignHCenter

                Rectangle {
                    anchors.fill: parent
                    radius: 32
                    color: Theme.darkMode ? "#33ef4444" : "#fee2e2"
                }

                Image {
                    id: warningIcon
                    source: "qrc:/icons/warning.svg"
                    anchors.centerIn: parent
                    width: 32
                    height: 32
                    fillMode: Image.PreserveAspectFit
                    asynchronous: false
                    cache: true
                    mipmap: true
                    visible: false
                }

                ColorOverlay {
                    anchors.fill: warningIcon
                    source: warningIcon
                    color: "#ef4444"
                }
            }

            Text {
                text: "Delete Group"
                color: Theme.textMain
                font.pixelSize: 22
                font.bold: true
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }
        }


        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6

            Text {
                text: "Warning! You are about to delete the group:"
                color: Theme.textDim
                font.pixelSize: 14
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                text: control.groupName
                color: "#ef4444"
                font.pixelSize: 18
                font.bold: true
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
            }

            Text {
                text: "This action will remove all associated IPs."
                color: Theme.textDim
                font.pixelSize: 12
                font.italic: true
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
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
                Layout.preferredHeight: 45
                onClicked: control.close()

                contentItem: Text {
                    text: cancelBtn.text
                    color: Theme.textDim
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    color: "transparent"
                    radius: 12
                    border.color: Theme.border
                }
            }

            VpnButton {
                id: deleteBtn
                text: "Delete Group"
                Layout.fillWidth: true
                Layout.preferredHeight: 45
                onClicked: {
                    control.confirmed()
                    control.close()
                }

                background: Rectangle {
                    color: deleteBtn.hovered ? "#dc2626" : "#ef4444"
                    radius: 12
                }

                contentItem: Text {
                    text: deleteBtn.text
                    color: "white"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
}

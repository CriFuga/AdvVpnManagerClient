import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects

Dialog {
    id: control
    anchors.centerIn: parent

    property string oldIp: ""
    property string oldCn: ""
    property alias newIpText: ipInputField.text
    property alias newCnText: cnSuggestField.text

    signal itemUpdated(string oldIp, string newIp, string newCn)

    modal: true
    focus: true
    padding: 0
    header: null
    footer: null

    enter: Transition {
        NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 200; easing.type: Easing.OutCubic }
        NumberAnimation { property: "scale"; from: 0.9; to: 1.0; duration: 200; easing.type: Easing.OutBack }
    }

    exit: Transition {
        NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 150; easing.type: Easing.InCubic }
        NumberAnimation { property: "scale"; from: 1.0; to: 0.9; duration: 150; easing.type: Easing.InCubic }
    }

    // Funzione centralizzata per l'invio
    function submitUpdate() {
        let cleanIp = ipInputField.text.trim();
        let cleanCn = cnSuggestField.text.trim();

        if (ipInputField.acceptableInput) {
            // Se l'IP è cambiato, registra la modifica nel buffer
            if (cleanIp !== oldIp) {
                controller.updateIpRequest(oldIp, cleanIp);
            }

            // Se il CN (ID) è cambiato, registra anche quello
            if (cleanCn !== oldCn) {
                controller.sendIdUpdate(cleanIp, cleanCn);
            }

            control.close();
        }
    }

    background: Rectangle {
        implicitWidth: 400
        implicitHeight: 380
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
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    Layout.alignment: Qt.AlignHCenter

                    Item {
                        width: 32; height: 32
                        Image {
                            id: editIconHeader
                            source: "qrc:/icons/edit.svg"
                            anchors.fill: parent
                            sourceSize: Qt.size(32, 32)
                            visible: false
                        }
                        ColorOverlay {
                            anchors.fill: editIconHeader
                            source: editIconHeader
                            color: Theme.accent
                        }
                    }
                    Text {
                        text: "Edit Assignment"
                        color: Theme.textMain
                        font.pixelSize: 22
                        font.bold: true
                    }
                }
                Text {
                    text: "You are editing the item:: " + oldIp
                    color: Theme.textDim
                    font.pixelSize: 13
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6
                Label {
                    text: "IP Adress"
                    color: Theme.textDim
                    font.pixelSize: 12
                    font.bold: true
                }
                TextField {
                    id: ipInputField
                    Layout.fillWidth: true
                    Layout.preferredHeight: 42
                    color: Theme.textMain
                    font.pixelSize: 14
                    placeholderText: "IP Adress..."
                    placeholderTextColor: Theme.textDim
                    verticalAlignment: TextInput.AlignVCenter

                    validator: RegularExpressionValidator {
                        regularExpression: /^([0-9\.\-\/]+)$/
                    }

                    background: Rectangle {
                        color: Theme.background
                        radius: 8
                        border.color: ipInputField.activeFocus ? Theme.accent : Theme.border
                        border.width: ipInputField.activeFocus ? 2 : 1
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6
                Label {
                    text: "Associate ID"
                    color: Theme.textDim
                    font.pixelSize: 12
                    font.bold: true
                }
                AutoSuggestField {
                    id: cnSuggestField
                    Layout.fillWidth: true
                    Layout.preferredHeight: 42
                    suggestions: controller.availableCns
                    placeholderText: "Search ID..."
                    text: oldCn
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
                    id: modifyBtn
                    text: "Save Changes"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 42
                    enabled: ipInputField.acceptableInput &&
                             (ipInputField.text.trim() !== oldIp || cnSuggestField.text.trim() !== oldCn)

                    onClicked: control.submitUpdate()
                }
            }
        }
    }

    onOpened: {
        ipInputField.forceActiveFocus()
    }
}

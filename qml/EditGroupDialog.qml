import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects

Dialog {
    id: control
    anchors.centerIn: parent
    modal: true
    focus: true

    property string oldGroupName: ""
    property alias newNameText: groupInputField.text
    signal groupRenamed(string oldName, string newName)

    background: Rectangle {
        implicitWidth: 350
        implicitHeight: 250
        radius: 20
        color: Theme.panel
        border.color: Theme.border
        layer.enabled: true
        layer.effect: DropShadow { transparentBorder: true; color: "#40000000"; radius: 20 }
    }

    contentItem: ColumnLayout {
        anchors.fill: parent
        anchors.margins: 25
        spacing: 20

        Text {
            text: "Rename Group"
            color: Theme.textMain
            font.pixelSize: 20; font.bold: true
            Layout.fillWidth: true; horizontalAlignment: Text.AlignHCenter
        }

        ColumnLayout {
            spacing: 8; Layout.fillWidth: true
            Label { text: "New group name"; color: Theme.textDim; font.pixelSize: 12 }
            TextField {
                id: groupInputField
                Layout.fillWidth: true; Layout.preferredHeight: 42
                color: Theme.textMain
                background: Rectangle {
                    color: Theme.background; radius: 8
                    border.color: groupInputField.activeFocus ? Theme.accent : Theme.border
                }
                Keys.onReturnPressed: if(modifyBtn.enabled) control.accept()
            }
        }

        RowLayout {
            Layout.fillWidth: true; spacing: 15
            VpnButton { text: "Cancel"; Layout.fillWidth: true; onClicked: control.close() }
            VpnButton {
                id: modifyBtn
                text: "Save Changes"
                Layout.fillWidth: true
                enabled: groupInputField.text.trim() !== "" && groupInputField.text !== oldGroupName
                onClicked: control.accept()
            }
        }
    }

    onAccepted: control.groupRenamed(oldGroupName, groupInputField.text.trim())
    onOpened: groupInputField.forceActiveFocus()
}

import QtQuick 2.15

Item {
    Layout.fillWidth: true
    Layout.preferredHeight: 100

    Column {
        anchors.centerIn: parent
        spacing: 8
        Text {
            text: "ADV<b>VPN</b>"
            color: "white"
            font.pixelSize: 22
        }
        Rectangle {
            width: 30
            height: 3
            color: Theme.accent
            anchors.horizontalCenter: parent.horizontalCenter
            radius: 2
        }
    }
}

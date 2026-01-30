import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Button {
    id: btn
    property bool primary: false
    property string iconSource: ""
    property color accentColor: "#2563eb"

    implicitWidth: iconSource !== "" ? 160 : 100
    implicitHeight: 40

    background: Rectangle {
        color: btn.primary ? (btn.pressed ? Qt.darker(accentColor, 1.1) : (btn.hovered ? Qt.lighter(accentColor, 1.1) : accentColor))
                           : "transparent"
        radius: 10
        border.color: accentColor
        border.width: btn.primary ? 0 : 1.2
    }

    contentItem: RowLayout {
        spacing: 8
        Image {
            source: btn.iconSource
            visible: btn.iconSource !== ""
            sourceSize: Qt.size(18, 18)
            Layout.alignment: Qt.AlignVCenter
        }
        Text {
            text: btn.text
            color: btn.primary ? "white" : accentColor
            font.bold: true
            font.pixelSize: 12
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
}

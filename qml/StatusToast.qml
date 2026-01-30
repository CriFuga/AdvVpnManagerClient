import QtQuick 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    property alias text: label.text
    visible: false
    z: 9999
    radius: 25
    color: Theme.panel
    border.color: Theme.border
    border.width: 1

    width: layout.implicitWidth + 60
    height: 50

    anchors.bottom: parent.bottom
    anchors.bottomMargin: 40
    anchors.horizontalCenter: parent.horizontalCenter

    RowLayout {
        id: layout
        anchors.centerIn: parent
        Text {
            id: label
            color: Theme.textMain
            font.pixelSize: 14
            font.weight: Font.Medium
        }
    }
}

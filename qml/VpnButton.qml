import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects

Button {
    id: control

    property string iconSource: ""
    property bool primary: true
    property alias fontPixelSize: buttonText.font.pixelSize

    implicitWidth: 160
    implicitHeight: 42

    contentItem: Item {
        anchors.fill: parent
        RowLayout {
            anchors.centerIn: parent
            spacing: 8

            Image {
                source: control.iconSource
                sourceSize: Qt.size(18, 18)
                visible: control.iconSource !== ""
                smooth: true

                layer.enabled: true
                layer.effect: ColorOverlay {
                    color: control.pressed ? "#ffffff" : (Theme.accent || "#2563eb")
                }
            }

            Text {
                id: buttonText
                text: control.text
                color: control.pressed ? "#ffffff" : (Theme.accent || "#2563eb")
                font.bold: true
                font.pixelSize: 12
                Behavior on color { ColorAnimation { duration: 100 } }
            }
        }
    }

    background: Rectangle {
        radius: 10
        color: control.pressed ? (Theme.accent || "#2563eb") : (control.hovered ? "#082563eb" : "transparent")
        border.color: Theme.accent || "#2563eb"
        border.width: 2

        Behavior on color { ColorAnimation { duration: 150 } }
    }
}

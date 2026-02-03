import QtQuick 2.15
import Qt5Compat.GraphicalEffects

Item {
    id: root
    opacity: visible ? 1.0 : 0.0
    Behavior on opacity { NumberAnimation { duration: 400; easing.type: Easing.InOutQuad } }

    Column {
        id: contentArea
        anchors.centerIn: parent
        spacing: 20

        Item {
            width: 120; height: 120
            anchors.horizontalCenter: parent.horizontalCenter

            Image {
                id: placeholderIcon
                source: "qrc:/icons/group.svg"
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
                sourceSize: Qt.size(256, 256)
                opacity: Theme.darkMode ? 0.6 : 0.1
            }

            ColorOverlay {
                anchors.fill: placeholderIcon
                source: placeholderIcon
                color: "#ffffff"
                visible: Theme.darkMode
                opacity: placeholderIcon.opacity
            }
        }

        Text {
            text: "Select a group to manage network items"
            color: Theme.textDim || "#64748b"
            font.pixelSize: 18
            font.weight: Font.Medium
            anchors.horizontalCenter: parent.horizontalCenter
            renderType: Text.NativeRendering
        }
    }
}

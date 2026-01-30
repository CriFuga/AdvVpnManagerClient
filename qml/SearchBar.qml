import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects

Rectangle {
    id: root
    height: 40
    radius: 10
    color: Theme.darkMode ? "#0f172a" : "#f8fafc"
    border.color: Theme.accent || "#2563eb"
    border.width: 1.5

    signal searchUpdated(string searchText)

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 10

        Image {
            source: "qrc:/icons/search.svg"
            sourceSize: Qt.size(18, 18)
            layer.enabled: true
            layer.effect: ColorOverlay { color: Theme.accent || "#2563eb" }
        }

        TextField {
            id: input
            Layout.fillWidth: true
            placeholderText: "Search groups..."
            color: Theme.darkMode ? "#ffffff" : "#0f172a"
            placeholderTextColor: "#64748b"
            background: null
            font.pixelSize: 13
            leftPadding: 0
            verticalAlignment: TextInput.AlignVCenter

            onDisplayTextChanged: {
                root.searchUpdated(text)
            }
        }

    }
}


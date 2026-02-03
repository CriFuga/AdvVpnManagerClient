import QtQuick 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects

Rectangle {
    id: root
    property alias text: label.text
    property bool showRequested: false

    visible: opacity > 0
    z: 9999
    radius: 25

    color: Theme.darkMode ? "#1e293b" : "#ffffff"

    border.color: Theme.accent || "#2563eb"
    border.width: Theme.darkMode ? 1.5 : 2

    width: layout.implicitWidth + 60
    height: 50
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom

    layer.enabled: true
    layer.effect: DropShadow {
        transparentBorder: true
        color: Theme.darkMode ? "#80000000" : "#302563eb"
        radius: 15
        samples: 20
        verticalOffset: 4
    }

    RowLayout {
        id: layout
        anchors.centerIn: parent
        spacing: 12

        Image {
            id: infoIcon
            source: "qrc:/icons/info.svg"
            sourceSize: Qt.size(20, 20)
            smooth: true

            layer.enabled: true
            layer.effect: ColorOverlay {
                color: Theme.accent || "#2563eb"
            }
        }

        Text {
            id: label
            color: Theme.darkMode ? "#ffffff" : (Theme.accent || "#2563eb")
            font.pixelSize: 14
            font.weight: Font.DemiBold
        }
    }

    Behavior on color { ColorAnimation { duration: 300 } }
    Behavior on border.color { ColorAnimation { duration: 300 } }

    states: [
        State {
            name: "visible"
            when: root.showRequested
            PropertyChanges { target: root; opacity: 1; anchors.bottomMargin: 40 }
        },
        State {
            name: "hidden"
            when: !root.showRequested
            PropertyChanges { target: root; opacity: 0; anchors.bottomMargin: 10 }
        }
    ]
    state: "hidden"
    Behavior on opacity { NumberAnimation { duration: 250 } }
    Behavior on anchors.bottomMargin {
        NumberAnimation { duration: 450; easing.type: Easing.OutBack }
    }
}

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects

ItemDelegate {
    id: delegateRoot
    height: 85
    width: parent ? parent.width : 0
    property string cn: ""
    property string ipValue: ""

    onClicked: {
        delegateRoot.ListView.view.currentIndex = index
        delegateRoot.forceActiveFocus()
    }

    background: Rectangle {
        radius: 12
        color: Theme.cardBackground
        border.color: (delegateRoot.ListView.isCurrentItem || delegateRoot.hovered)
                      ? Theme.accent : Theme.border
        border.width: delegateRoot.ListView.isCurrentItem ? 2 : 1
    }

    contentItem: RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        spacing: 20


        Rectangle {
            id: typeIcon
            width: 44; height: 44; radius: 22

            color: {
                if (cn === "") return Theme.darkMode ? "#1e293b" : "#f1f5f9"
                if (kind === "net") return Theme.darkMode ? "#1e3a8a" : "#dbeafe"
                if (kind === "range") return Theme.darkMode ? "#581c87" : "#f3e8ff"
                return Theme.darkMode ? "#064e3b" : "#d1fae5"
            }

            border.color: {
                if (cn === "") return Theme.border
                if (kind === "net") return "#3b82f6"
                if (kind === "range") return "#a855f7"
                return "#10b981"
            }
            border.width: 2
            Layout.alignment: Qt.AlignVCenter

            Text {
                anchors.centerIn: parent
                text: {
                    if (kind === "addr") return "IP"
                    return kind.toUpperCase()
                }
                font.bold: true
                font.pixelSize: text.length > 2 ? 10 : 13
                color: typeIcon.border.color
            }
        }


        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 4

            Label {
                text: ipValue
                color: Theme.textMain
                font.bold: true; font.pixelSize: 16
            }


            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 30

                RowLayout {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    visible: cn !== ""
                    spacing: 6

                    Text {
                        text: "✓"
                        color: "#10b981"
                        font.pixelSize: 12
                    }
                    Label {
                        text: cn
                        color: Theme.darkMode ? "#10b981" : "#059669"
                        font.pixelSize: 13; font.weight: Font.Medium
                        elide: Text.ElideRight
                    }
                }


                AutoSuggestField {
                    width: 250
                    Layout.preferredWidth: 200
                    visible: cn === ""
                    placeholderText: "Assign ID..."
                    font.pixelSize: 12
                    suggestions: controller.availableCns
                    onSuggestionPicked: (val) => {
                                            assignCnDialog.ipTarget = ipValue
                                            assignCnDialog.cnValue = val
                                            assignCnDialog.open()
                                        }
                }
            }
        }

        RowLayout {
            id: actionButtons
            spacing: 8
            Layout.alignment: Qt.AlignVCenter
            Layout.rightMargin: 15

            property bool isShown: delegateRoot.hovered || delegateRoot.ListView.isCurrentItem

            opacity: isShown ? 1.0 : 0.0

            transform: Translate {
                x: actionButtons.isShown ? 0 : 20

                Behavior on x {
                    NumberAnimation { duration: 250; easing.type: Easing.OutBack }
                }
            }

            Behavior on opacity {
                NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
            }

            VpnButton {
                id: editBtn
                Layout.preferredWidth: 34
                Layout.preferredHeight: 34

                onClicked: {
                    delegateRoot.ListView.view.currentIndex = index
                    editItemDialog.oldIp = ipValue
                    editItemDialog.newIpText = ipValue
                    editItemDialog.oldCn = cn
                    editItemDialog.newCnText = cn
                    editItemDialog.open()
                }

                background: Rectangle {
                    color: editBtn.hovered ? (Theme.darkMode ? "#223b82f6" : "#e0e7ff") : "transparent"
                    radius: 17
                }

                contentItem: Item {
                    anchors.fill: parent
                    Image {
                        id: editIcon
                        source: "qrc:/icons/edit.svg"
                        anchors.centerIn: parent
                        width: 16; height: 16
                        fillMode: Image.PreserveAspectFit
                        sourceSize: Qt.size(16, 16)
                        visible: false
                    }
                    ColorOverlay {
                        anchors.fill: editIcon
                        source: editIcon
                        color: editBtn.hovered ? Theme.accent : Theme.textDim
                    }
                }
            }

            VpnButton {
                id: deleteBtn
                Layout.preferredWidth: 34
                Layout.preferredHeight: 34
                onClicked: {
                    deleteIpDialog.messageText = ipValue
                    deleteIpDialog.open()
                }

                background: Rectangle {
                    color: deleteBtn.hovered ? (Theme.darkMode ? "#22ff4444" : "#fee2e2") : "transparent"
                    radius: 17
                }

                contentItem: Item {
                    anchors.fill: parent
                    Image {
                        id: binIcon
                        source: "qrc:/icons/bin.svg"
                        anchors.centerIn: parent
                        width: 16; height: 16
                        fillMode: Image.PreserveAspectFit
                        sourceSize.width: 16
                        sourceSize.height: 16
                        visible: false
                    }
                    ColorOverlay {
                        anchors.fill: binIcon
                        source: binIcon
                        color: deleteBtn.hovered ? "#ef4444" : Theme.textDim
                    }
                }
            }
        }
    }
}

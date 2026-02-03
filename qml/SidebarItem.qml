import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects

Item {
    id: itemRoot
    height: 50
    focus: true

    property string groupName: ""
    property int itemCount: 0
    property bool isSelected: false
    property bool isEditingMode: false
    property string tempName: ""
    property bool isModified: false

    signal renameRequested(string oldName, string newName)
    signal clicked()
    signal removeRequested()

    onIsEditingModeChanged: {
        if (!isEditingMode) {
            let cleanNewName = tempName.trim();
            if (cleanNewName !== "" && cleanNewName !== groupName) {
                itemRoot.renameRequested(groupName, cleanNewName);
            }
            isModified = false;
        } else {
            tempName = groupName;
            isModified = false;
            editField.forceActiveFocus();
        }
    }

    Rectangle {
        id: bgRect
        anchors.fill: parent
        anchors.margins: 4
        radius: 8

        color: {
            if (isModified /*|| groupName === tempName*/) return "#065f46";
            if (isSelected) return "#1F3A5F";
            return "transparent";
        }

        border.color: isModified ? "#10b981" : (isSelected ? "#3B82F6" : "transparent")
        border.width: (isModified || isSelected) ? 1 : 0

        MouseArea {
            id: itemMouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                if (!isEditingMode) {
                    itemRoot.clicked();
                } else {
                    itemRoot.forceActiveFocus();
                }
            }
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: 10

            Label {
                text: groupName
                visible: !isEditingMode
                Layout.fillWidth: true
                color: isSelected ? "#EAF2FF" : "#CBD5E1"
                font.bold: isSelected
                font.pixelSize: 14
                elide: Text.ElideRight
            }

            TextField {
                id: editField
                visible: isEditingMode
                Layout.fillWidth: true
                text: tempName
                color: "white"
                font.pixelSize: 14
                verticalAlignment: Text.AlignVCenter
                selectByMouse: true
                focus: isEditingMode

                background: Rectangle {
                    color: "#0f172a"
                    border.color: isModified ? "#10b981" : Theme.accent
                    border.width: 1
                    radius: 4
                }

                onTextChanged: {
                    if (isEditingMode) tempName = text
                }

                onAccepted: {

                    if (tempName.trim() !== groupName) {
                        isModified = true;
                    }
                    itemRoot.forceActiveFocus();
                }

                Keys.onPressed: (event) => {
                                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                        if (tempName.trim() !== groupName) {
                                            isModified = true;
                                        }
                                        itemRoot.forceActiveFocus();
                                        event.accepted = true;
                                    }
                                    if (event.key === Qt.Key_Escape) {
                                        tempName = groupName;
                                        isModified = false;
                                        itemRoot.forceActiveFocus();
                                        event.accepted = true;
                                    }
                                }
            }

            Row {
                spacing: 12
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                visible: !isEditingMode

                Rectangle {
                    width: countText.width + 12
                    height: 20
                    radius: 10
                    color: isSelected ? "#3B82F6" : "#334155"
                    visible: itemCount > 0

                    Text {
                        id: countText
                        anchors.centerIn: parent
                        text: itemCount
                        color: "#ffffff"
                        font.pixelSize: 11
                        font.bold: true
                    }
                }

                Item {
                    width: 20
                    height: 20
                    visible: isSelected

                    Image {
                        id: binImg
                        source: "qrc:/icons/bin.svg"
                        anchors.fill: parent
                        fillMode: Image.PreserveAspectFit
                        visible: false
                    }

                    ColorOverlay {
                        anchors.fill: binImg
                        source: binImg
                        color: binMouseArea.containsMouse ? "#EF4444" : (isSelected ? "#60A5FA" : "#94A3B8")
                    }

                    MouseArea {
                        id: binMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            deleteGroupDialog.groupName = groupName
                            deleteGroupDialog.open();
                        }
                    }
                }
            }
        }
    }
}

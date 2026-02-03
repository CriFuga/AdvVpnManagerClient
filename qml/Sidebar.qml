import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects

Rectangle {
    id: root
    property alias currentIndex: groupView.currentIndex
    property string currentGroupName: ""
    property bool isEditing: false

    signal groupSelected(int proxyIndex)

    Layout.preferredWidth: 280
    Layout.fillHeight: true
    Layout.minimumWidth: 200
    Layout.maximumWidth: 600
    color: Theme.sidebarBg || "#1e293b"

    AddGroupDialog {
        id: addGroupDialog
        onGroupAdded: (name) => controller.addGroupRequest(name)
    }

    EditGroupDialog {
        id: editGroupDialog
        onGroupRenamed: (oldName, newName) => {
                            controller.renameGroupRequest(oldName, newName);
                            root.isEditing = false
                        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 80
            Column {
                anchors.centerIn: parent
                spacing: 8
                Text {
                    text: "ADV<b>VPN</b>"
                    color: "#ffffff"
                    font.pixelSize: 22
                }
                Rectangle {
                    width: 30; height: 3; radius: 2
                    color: Theme.accent
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }

        SearchBar {
            id: searchBar
            Layout.fillWidth: true
            Layout.margins: 15
            onSearchUpdated: (searchText) => groupModel.setFilterFixedString(searchText)
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 20
            Layout.rightMargin: 15
            Layout.bottomMargin: 10

            Label {
                text: "GROUPS"
                font.pixelSize: 11
                font.weight: Font.Bold
                color: Theme.darkMode ? "#64748b" : "#94a3b8"
                Layout.fillWidth: true
            }

            Button {
                id: editGroupsBtn
                Layout.preferredWidth: 28; Layout.preferredHeight: 28
                onClicked: {
                    if (root.isEditing) {
                        root.isEditing = false
                    } else {
                        root.isEditing = true
                    }
                }

                background: Rectangle {
                    color: editGroupsBtn.hovered ? (root.isEditing ? "#059669" : "#3B82F6") : "transparent"
                    radius: 6
                }

                contentItem: Item {
                    Image {
                        id: editIcon
                        anchors.centerIn: parent
                        source: root.isEditing ? "qrc:/icons/check.svg" : "qrc:/icons/edit.svg"
                        sourceSize: Qt.size(16, 16)
                        smooth: true
                    }
                    ColorOverlay {
                        anchors.fill: editIcon; source: editIcon
                        color: editGroupsBtn.hovered ? "white" : (root.isEditing ? Theme.success : "#3B82F6")
                    }
                }
            }

            Button {
                id: addGroupBtn
                Layout.preferredWidth: 26; Layout.preferredHeight: 26
                onClicked: addGroupDialog.open()
                visible: !root.isEditing
                background: Rectangle {
                    color: addGroupBtn.hovered ? "#3B82F6" : "transparent"
                    radius: 6
                    border.color: addGroupBtn.hovered ? "transparent" : "#334155"
                }
                contentItem: Text {
                    text: "+"
                    color: addGroupBtn.hovered ? "white" : "#3B82F6"
                    font.pixelSize: 18; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            Layout.leftMargin: 30
            Layout.rightMargin: 30
            color: Theme.darkMode ? "#334155" : "#e2e8f0"
            radius: 1
        }

        Item { Layout.preferredHeight: 10 }

        ListView {
            id: groupView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: groupModel
            spacing: 4

            // --- LOGICA DI SINCRONIZZAZIONE INDICI ---

            // 1. Quando cambia l'elemento selezionato, salviamo il nome per il futuro
            onCurrentIndexChanged: {
                if (currentIndex >= 0) {
                    var currentModelIndex = model.index(currentIndex, 0);
                    root.currentGroupName = model.data(currentModelIndex, Qt.DisplayRole) || "";
                } else {
                    root.currentGroupName = "";
                }
            }

            // 2. Quando il numero di elementi cambia (es. dopo un Undo), cerchiamo il gruppo per nome
            onCountChanged: {
                if (root.currentGroupName !== "") {
                    for (var i = 0; i < count; i++) {
                        // model è il groupProxy, quindi cerchiamo tra gli elementi visibili
                        if (model.data(model.index(i, 0), Qt.DisplayRole) === root.currentGroupName) {
                            currentIndex = i;
                            console.log("🔄 Riallineamento: " + root.currentGroupName + " ritrovato all'indice: " + i);
                            return;
                        }
                    }
                }
            }

            // --- ANIMAZIONI ---
            add: Transition {
                NumberAnimation { properties: "opacity"; from: 0; to: 1; duration: 250 }
                NumberAnimation { properties: "x"; from: -20; to: 0; duration: 250; easing.type: Easing.OutQuad }
            }

            remove: Transition {
                NumberAnimation { properties: "opacity"; to: 0; duration: 200 }
                NumberAnimation { properties: "scale"; to: 0.9; duration: 200 }
            }

            displaced: Transition {
                NumberAnimation { properties: "y"; duration: 250; easing.type: Easing.OutQuad }
            }

            // --- DELEGATE ---
            delegate: SidebarItem {
                width: groupView.width
                groupName: model.name || ""
                itemCount: model.itemCount || 0
                isSelected: groupView.currentIndex === index
                isEditingMode: root.isEditing

                onClicked: {
                    if (!root.isEditing) {
                        groupView.currentIndex = index
                        root.groupSelected(index) // Comunica al controller l'indice del proxy
                    }
                }

                onRenameRequested: (oldName, newName) => {
                                       controller.renameGroupRequest(oldName, newName);
                                       console.log("Rinomino " + oldName + " in " + newName)
                                   }

                onRemoveRequested: {
                    console.log("Elimino gruppo: " + groupName);
                    controller.removeGroupRequest(groupName);
                }
            }
        }
    }

    MouseArea {
        id: resizeHandle
        width: 6; anchors.right: parent.right; anchors.top: parent.top; anchors.bottom: parent.bottom
        cursorShape: Qt.SizeHorCursor; z: 10; hoverEnabled: true
        Rectangle {
            anchors.fill: parent
            color: Theme.accent; opacity: (parent.containsMouse || parent.pressed) ? 0.5 : 0.0
        }
        onPositionChanged: {
            if (pressed) {
                var globalX = mapToItem(window.contentItem, mouseX, mouseY).x
                if (globalX >= root.Layout.minimumWidth && globalX <= root.Layout.maximumWidth) {
                    root.Layout.preferredWidth = globalX
                }
            }
        }
    }
}

import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt5Compat.GraphicalEffects

TextField {
    id: control

    property var suggestions: []
    property alias popupOpened: popup.visible
    property alias listModel: suggestModel

    signal suggestionPicked(string value)

    color: Theme.textMain
    placeholderTextColor: Theme.textDim
    font.pixelSize: 12
    leftPadding: 10
    rightPadding: clearButton.visible ? 35 : 10
    selectByMouse: true
    selectionColor: Theme.accent

    onTextChanged: {
        suggestModel.clear()
        let list = Array.from(suggestions || [])

        if (list.length > 0 && text.length > 0 && activeFocus) {
            var found = false
            let input = text.toLowerCase()

            for (var i = 0; i < list.length; i++) {
                let val = String(list[i])
                if (val.toLowerCase().includes(input)) {
                    suggestModel.append({ "value": val })
                    found = true
                }
            }
            popup.visible = found
            if (found) suggestList.currentIndex = 0
        } else {
            popup.visible = false
        }
    }

    Keys.onPressed: (event) => {
                        if (popup.visible) {
                            if (event.key === Qt.Key_Down) {
                                suggestList.currentIndex = (suggestList.currentIndex + 1) % suggestList.count
                                event.accepted = true
                            } else if (event.key === Qt.Key_Up) {
                                suggestList.currentIndex = (suggestList.currentIndex - 1 + suggestList.count) % suggestList.count
                                event.accepted = true
                            } else if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                                if (suggestList.currentIndex !== -1) {
                                    let val = suggestModel.get(suggestList.currentIndex).value
                                    control.text = val
                                    control.suggestionPicked(val)
                                    popup.close()
                                }
                                event.accepted = true
                            } else if (event.key === Qt.Key_Escape) {
                                popup.close()
                                event.accepted = true
                            }
                        }
                    }

    background: Rectangle {
        radius: 6
        color: Theme.darkMode ? "#1e293b" : "#f8fafc"
        border.color: control.activeFocus ? Theme.accent : Theme.border
        border.width: 1

        Item {
            id: clearButton
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: 30; height: 30
            visible: control.text.length > 0

            Text {
                anchors.centerIn: parent
                text: "✕"
                font.pixelSize: 10
                color: Theme.textDim
                opacity: mouseXClear.containsMouse ? 1.0 : 0.6
            }

            MouseArea {
                id: mouseXClear
                anchors.fill: parent
                hoverEnabled: true
                onPressed: (mouse) => mouse.accepted = true
                onReleased: (mouse) => {
                                if (containsMouse) {
                                    control.text = ""
                                    control.forceActiveFocus()
                                    popup.close()
                                }
                            }
            }
        }
    }

    ListModel { id: suggestModel }

    Popup {
        id: popup
        parent: Overlay.overlay

        function updatePosition() {
            var globalPos = control.mapToItem(null, 0, 0)
            popup.x = globalPos.x
            popup.y = globalPos.y + control.height + 2
        }

        onAboutToShow: updatePosition()
        width: control.width

        padding: 0
        focus: false
        closePolicy: Popup.CloseOnEscape

        background: Rectangle {
            radius: 8
            color: Theme.panel
            border.color: Theme.border
            layer.enabled: true
            layer.effect: DropShadow {
                transparentBorder: true
                color: "#60000000"
                radius: 15
                verticalOffset: 4
            }
        }

        contentItem: ListView {
            id: suggestList
            implicitHeight: Math.min(count * 34, 170)
            model: suggestModel
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            ScrollBar.vertical: ScrollBar {
                width: 4
                policy: parent.contentHeight > parent.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
            }

            delegate: ItemDelegate {
                width: popup.width
                height: 34
                highlighted: ListView.isCurrentItem

                contentItem: Text {
                    text: model.value
                    color: Theme.textMain
                    font.pixelSize: 12
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 12
                    elide: Text.ElideRight
                }

                background: Rectangle {
                    color: highlighted ? (Theme.darkMode ? "#2d3748" : "#f1f5f9") : "transparent"
                    radius: 6
                    anchors.fill: parent
                    anchors.margins: 2
                }

                onClicked: {
                    let val = model.value
                    control.text = val
                    control.suggestionPicked(val)
                    popup.close()
                }
            }
        }
    }
}

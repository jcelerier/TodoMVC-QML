import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2 as QC
import QtQml.Models 2.3
import QtQuick.Controls.Material 2.1

QC.ApplicationWindow { id: root
    visible: true

    width: 640
    height: 480
    background: Rectangle {
        color: "#eee"
    }

    Text { id: todo
        text: "Todo"
        font.pointSize: 48
        font.family: "Helvetica Neue"
        font.bold: true
        font.underline: true
        anchors.horizontalCenter: parent.horizontalCenter
        color: Material.accent
    }

    Item { id: newItem
        anchors.top: todo.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: 0.8 * parent.width
        height: 50
        QC.TextField {
            placeholderText: qsTr("What will I do today... ?")
            anchors.fill: parent
            onAccepted: {
                if(text.length > 0) {
                  todoModel.append({ "todo": text, "done": 0 })
                  text = ""
                }
            }
        }
    }

    DelegateModel { id: filterModel
        model: ListModel { id: todoModel
        }

        groups: [
            DelegateModelGroup { name: "active"; includeByDefault: true },
            DelegateModelGroup { id: completed; name: "completed" }
        ]

        delegate: Item { id: item
            height: 50
            Row { id: row
                QC.CheckDelegate{ id: check
                    checkState: done ? Qt.Checked : Qt.Unchecked
                    anchors.verticalCenter: parent.verticalCenter
                    onCheckedChanged: {
                        done = 1
                        item.DelegateModel.inActive = !done
                        item.DelegateModel.inCompleted = done
                    }
                }
                QC.TextField {
                    anchors.verticalCenter: parent.verticalCenter
                    text: todo
                    font.strikeout: check.checked
                    color: check.checked ? "#aaa" : "#222"
                }
                QC.Button { id: cross
                    anchors.verticalCenter: parent.verticalCenter
                    opacity: 0
                    Behavior on opacity { PropertyAnimation { duration: 100 } }
                    background: Item { }
                    contentItem: Text {
                        font.pointSize: 24
                        text: "✖"
                        color: cross.down ? Qt.lighter(Material.accent) : Material.accent
                        Behavior on color { ColorAnimation { duration: 100 } }
                    }
                    onClicked: todoModel.remove(index)
                }
            }

            MouseArea {
                anchors.fill: row
                onEntered: cross.opacity = 1.0
                onExited: cross.opacity = 0.0
                hoverEnabled: true
                z: -1
            }
        }
    }

    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.top: newItem.bottom
        visible: todoModel.count > 0

        ListView {
            clip: true
            model: filterModel
            height: Math.min(contentHeight + 20, 250)
            width: 0.8 * root.width
            anchors.margins: 20
            spacing: 10
        }

        QC.Frame { id: frame
            clip: true
            anchors.margins: 50
            height: 1.1 * col.height
            width: 0.8 * root.width
            Column {
                id: col
                width: parent.width
                QC.Label {
                    text: todoModel.count + " item" + (todoModel.count == 1 ? "" : "s") + " left"
                }

                Row {
                    width: parent.width
                    QC.RadioButton { text: "All"
                        onCheckedChanged:  filterModel.filterOnGroup = ""
                        checked: true
                    }
                    QC.RadioButton { text: "Completed"
                        onCheckedChanged:  filterModel.filterOnGroup = "completed"
                    }
                    QC.RadioButton { text: "Active"
                        onCheckedChanged:  filterModel.filterOnGroup = "active"
                    }
                }

                QC.Button {
                    text: "Clear completed"
                    width: parent.width
                    onClicked: {
                        while(completed.count > 0)
                            todoModel.remove(completed.get(0).itemsIndex)
                    }
                }
            }
        }
    }
}

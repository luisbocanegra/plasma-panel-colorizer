import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

// A component to create a list of color pickers
// color (hex) | ColorButton | randomize | move up | move down | delete | add new
// ...
// text field with colors | update list above

ColumnLayout {
    id: root
    property var colorsList: []
    signal colorsChanged(newColors: var)
    property bool ready: false
    signal removeColor(index: int)

    onRemoveColor: index => {
        colorsListModel.remove(index);
        updateColorsList();
    }

    ListModel {
        id: colorsListModel
    }

    ListModel {
        id: colorsListModelTmp
        ListElement {
            color: "#ff0000"
        }
    }

    Connections {
        target: colorsListModel
        function onCountChanged(count, ready) {
            if (!ready)
                return;
            console.log("model count changed:", count);
            updateColorsList();
        }
    }

    onColorsListChanged: {
        initColorsListModel();
    }

    function initColorsListModel() {
        ready = false;
        colorsListModel.clear();
        const colors = colorsList;
        for (let i in colors) {
            colorsListModel.append({
                "color": colors[i]
            });
        }
        ready = true;
    }

    function getRandomColor() {
        const h = Math.random();
        const s = Math.random();
        const l = Math.random();
        const a = 1.0;
        console.log(h, s, l);
        return Qt.hsla(h, s, l, a);
    }

    function updateColorsList() {
        console.log("updateColorsList()");
        let colors_list = [];
        for (let i = 0; i < colorsListModel.count; i++) {
            let c = colorsListModel.get(i).color;
            colors_list.push(c);
        }
        colorsList = colors_list;
        colorsChanged(colorsList);
    }

    Component.onCompleted: {
        initColorsListModel();
    }

    GroupBox {
        visible: listColorRadio.checked
        ColumnLayout {
            Layout.alignment: Qt.AlignTop
            Repeater {
                id: customColorsRepeater
                model: ready ? colorsListModel : []
                delegate: RowLayout {

                    TextMetrics {
                        id: metrics
                        text: (model.length + 1).toString()
                    }

                    Label {
                        text: (index + 1).toString() + "."
                        Layout.preferredWidth: metrics.width
                    }

                    TextMetrics {
                        id: colorMetrics
                        text: "#FFFFFF"
                    }

                    TextArea {
                        text: modelData
                        font.capitalization: Font.AllUppercase
                        Kirigami.SpellCheck.enabled: false
                        Layout.preferredWidth: colorMetrics.width * 1.4
                    }

                    ColorButton {
                        showAlphaChannel: false
                        dialogTitle: i18n("Widget background") + "(" + index + ")"
                        color: modelData
                        showCurentColor: false
                        onAccepted: color => {
                            colorsListModel.set(index, {
                                "color": color.toString()
                            });
                            updateColorsList();
                        }
                    }

                    Button {
                        icon.name: "randomize-symbolic"
                        onClicked: {
                            colorsListModel.set(index, {
                                "color": getRandomColor().toString()
                            });
                            updateColorsList();
                        }
                    }

                    Button {
                        icon.name: "arrow-up"
                        enabled: index > 0
                        onClicked: {
                            let prevIndex = index - 1;
                            let prev = colorsListModel.get(prevIndex).color;
                            colorsListModel.set(prevIndex, colorsListModel.get(index));
                            colorsListModel.set(index, {
                                "color": prev
                            });
                            updateColorsList();
                        }
                    }

                    Button {
                        icon.name: "arrow-down"
                        enabled: index < colorsListModel.count - 1
                        onClicked: {
                            let nextIndex = index + 1;
                            let next = colorsListModel.get(nextIndex).color;
                            colorsListModel.set(nextIndex, colorsListModel.get(index));
                            colorsListModel.set(index, {
                                "color": next
                            });
                            updateColorsList();
                        }
                    }

                    Button {
                        icon.name: "edit-delete-remove"
                        onClicked: {
                            root.removeColor(index);
                        }
                    }

                    Button {
                        icon.name: "list-add-symbolic"
                        onClicked: {
                            colorsListModel.insert(index + 1, {
                                "color": getRandomColor().toString()
                            });
                            updateColorsList();
                        }
                    }
                }
            }

            RowLayout {
                visible: colorsListModel.count === 0
                Item {
                    Layout.fillWidth: true
                }
                Button {
                    icon.name: "list-add-symbolic"
                    onClicked: {
                        colorsListModel.insert(0, {
                            "color": getRandomColor().toString()
                        });
                        updateColorsList();
                    }
                }
            }

            RowLayout {
                TextArea {
                    id: customColors
                    text: colorsList?.join(" ") || []
                    Layout.preferredWidth: 300
                    Layout.fillWidth: true
                    wrapMode: TextEdit.WordWrap
                    font.capitalization: Font.AllUppercase
                    Kirigami.SpellCheck.enabled: false
                }
                Button {
                    id: btn
                    icon.name: "view-refresh-symbolic"
                    onClicked: {
                        colorsList = customColors.text.split(" ");
                        colorsChanged(colorsList);
                    }
                }
            }
        }
    }
}

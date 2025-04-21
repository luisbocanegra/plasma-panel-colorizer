// pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

// A component to create a list of color pickers
// color (hex) | ColorButton | randomize | position | delete | add new
// ...
// text field with colors | update list above

ColumnLayout {
    id: root
    property var stopsList: []
    signal colorsChanged(stopsList: var)
    property bool ready: false
    signal removeColor(index: int)

    onRemoveColor: index => {
        stopsListModel.remove(index);
        updateColorsList();
    }

    ListModel {
        id: stopsListModel
    }

    ListModel {
        id: stopsListModelTmp
        ListElement {
            color: "#ff0000"
            position: 0.0
        }
    }

    Connections {
        target: stopsListModel
        function onCountChanged(count, ready) {
            if (!ready)
                return;
            console.log("model count changed:", count);
            updateColorsList();
        }
    }

    onStopsListChanged: {
        initColorsListModel();
    }

    function initColorsListModel() {
        if (stopsListModel.count !== 0) {
            return;
        }
        ready = false;
        const stops = stopsList;
        for (let stop of stops) {
            stopsListModel.append({
                "color": stop.color,
                "position": stop.position
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
        for (let i = 0; i < stopsListModel.count; i++) {
            colors_list.push({
                "color": stopsListModel.get(i).color,
                "position": stopsListModel.get(i).position
            });
        }
        stopsList = colors_list;
        colorsChanged(stopsList);
    }

    Component.onCompleted: {
        initColorsListModel();
    }

    GroupBox {
        ColumnLayout {
            Layout.alignment: Qt.AlignTop
            Repeater {
                id: customColorsRepeater
                model: stopsListModel
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
                        text: model.color
                        font.capitalization: Font.AllUppercase
                        Kirigami.SpellCheck.enabled: false
                        Layout.preferredWidth: colorMetrics.width * 1.4
                        onTextChanged: {
                            if (text !== model.color) {
                                stopsListModel.set(index, {
                                    "color": text
                                });
                                updateColorsList();
                            }
                        }
                    }

                    ColorButton {
                        showAlphaChannel: true
                        dialogTitle: i18n("Widget background") + "(" + index + ")"
                        color: model.color
                        showCurentColor: false
                        onAccepted: color => {
                            stopsListModel.set(index, {
                                "color": color.toString()
                            });
                            updateColorsList();
                        }
                    }

                    Button {
                        icon.name: "randomize-symbolic"
                        onClicked: {
                            stopsListModel.set(index, {
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
                            let prev = stopsListModel.get(prevIndex).color;
                            stopsListModel.set(prevIndex, stopsListModel.get(index));
                            stopsListModel.set(index, {
                                "color": prev
                            });
                            updateColorsList();
                        }
                    }

                    Button {
                        icon.name: "arrow-down"
                        enabled: index < stopsListModel.count - 1
                        onClicked: {
                            let nextIndex = index + 1;
                            let next = stopsListModel.get(nextIndex).color;
                            stopsListModel.set(nextIndex, stopsListModel.get(index));
                            stopsListModel.set(index, {
                                "color": next
                            });
                            updateColorsList();
                        }
                    }

                    SpinBoxDecimal {
                        Layout.preferredWidth: backgroundRoot.Kirigami.Units.gridUnit * 5
                        value: model.position
                        // Component.onCompleted: value = parseFloat(model.position)
                        from: 0
                        to: 1
                        onValueChanged: {
                            if (value !== model.position) {
                                stopsListModel.set(index, {
                                    "position": value
                                });
                                updateColorsList();
                            }
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
                            stopsListModel.insert(index + 1, {
                                "color": getRandomColor().toString(),
                                "position": 0.0
                            });
                            updateColorsList();
                        }
                    }
                }
            }

            RowLayout {
                visible: stopsListModel.count === 0
                Item {
                    Layout.fillWidth: true
                }
                Button {
                    icon.name: "list-add-symbolic"
                    onClicked: {
                        stopsListModel.insert(0, {
                            "color": getRandomColor().toString(),
                            "position": 0.0
                        });
                        updateColorsList();
                    }
                }
            }

            RowLayout {
                TextArea {
                    id: customColors
                    text: stopsList?.map(s => s.color + ":" + s.position).join(" ") || []
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
                        stopsList = customColors.text.split(" ").map(s => {
                            console.log(s.split(":"));
                            return {
                                "color": s.split(":")[0],
                                "position": parseFloat(s.split(":")[1])
                            };
                        });
                        stopsListModel.clear();
                        initColorsListModel();
                        updateColorsList();
                    }
                }
            }
        }
    }
}

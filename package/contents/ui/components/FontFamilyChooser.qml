pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kitemmodels as KItemModels

ColumnLayout {
    id: root
    property string selectedFont: "Noto Sans"
    signal fontSelected(string font)

    ListModel {
        id: fontModel
        Component.onCompleted: {
            const fonts = Qt.fontFamilies();
            for (const font of fonts) {
                append({
                    "name": font
                });
            }
        }
    }

    KItemModels.KSortFilterProxyModel {
        id: fontsFilteredModel
        sourceModel: fontModel
        filterRoleName: "name"
        filterRowCallback: (sourceRow, sourceParent) => {
            return sourceModel.data(sourceModel.index(sourceRow, 0, sourceParent), filterRole).toLowerCase().includes(searchField.text.toLowerCase());
        }
    }

    Kirigami.SearchField {
        id: searchField
        placeholderText: "Search fonts"
        Layout.fillWidth: true
        onTextChanged: fontsFilteredModel.setFilterFixedString(text)
    }

    ScrollView {
        Layout.fillWidth: true
        Layout.fillHeight: true
        ListView {
            id: view
            width: parent.width
            clip: true
            height: parent.height
            model: fontsFilteredModel
            reuseItems: false
            delegate: RadioDelegate {
                id: delegate
                required property string modelData
                required property int index
                width: view.width
                text: delegate.modelData
                checked: delegate.modelData === root.selectedFont
                onCheckedChanged: {
                    if (checked) {
                        root.selectedFont = modelData;
                        root.fontSelected(modelData);
                    }
                }
            }
            Component.onCompleted: {
                Qt.callLater(() => {
                    let index = -1;
                    for (let i = 0; i < fontsFilteredModel.rowCount(); ++i) {
                        const modelIndex = fontsFilteredModel.index(i, 0);
                        if (fontsFilteredModel.data(modelIndex, Qt.DisplayRole) === root.selectedFont) {
                            index = i;
                            break;
                        }
                    }

                    if (index !== -1) {
                        view.positionViewAtIndex(index, ListView.Beginning);
                    } else {
                        const modelIndex = fontsFilteredModel.index(0, 0);
                        if (modelIndex) {
                            root.selectedFont = fontsFilteredModel.data(modelIndex, Qt.DisplayRole);
                        }
                        view.positionViewAtIndex(0, ListView.Beginning);
                    }
                });
            }
        }
    }
}

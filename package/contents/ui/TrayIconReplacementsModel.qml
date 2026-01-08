pragma ComponentBehavior: Bound
import QtQuick

Item {
    id: root
    property ListModel model: ListModel {}
    property bool isLoading: true

    signal updated

    function initModel(configString) {
        model.clear();
        let items = [];

        try {
            items = JSON.parse(configString);
        } catch (e) {
            console.error(e.message, "\n", e.stack);
        }

        for (let item of items) {
            // update format
            if (!item.match) {
                item.match = item.hash ?? "";
                delete item.hash;
            }
            model.append(item);
        }
        root.isLoading = false;
    }

    function addItem() {
        model.append({
            "description": "",
            "match": "",
            "icon": "",
            "enabled": true
        });
        updated();
    }

    function appendRule(rule) {
        model.append(rule);
        updated();
    }

    function insertRule(index, rule) {
        model.insert(index, rule);
        updated();
    }

    function clear() {
        model.clear();
        updated();
    }

    function removeItem(index) {
        model.remove(index, 1);
        updated();
    }

    function updateItem(index, property, value) {
        model.setProperty(index, property, value);
        updated();
    }

    function moveItem(oldIndex, newIndex) {
        model.move(oldIndex, newIndex, 1);
        updated();
    }

    function ruleExists(match) {
        let exists = false;

        for (let i = 0; i < model.count; i++) {
            const item = model.get(i);
            if (item.match === match) {
                return true;
            }
        }
        return false;
    }

    function disableAll() {
        for (let i = 0; i < model.count; i++) {
            const item = model.get(i);
            item.enabled = false;
        }
        updated();
    }

    function enableAll() {
        for (let i = 0; i < model.count; i++) {
            const item = model.get(i);
            item.enabled = true;
        }
        updated();
    }

    function toggleAll() {
        for (let i = 0; i < model.count; i++) {
            const item = model.get(i);
            item.enabled = !item.enabled;
        }
        updated();
    }

    function disableAllOthers(index) {
        for (let i = 0; i < model.count; i++) {
            const item = model.get(i);
            if (i === index) {
                item.enabled = true;
            } else {
                item.enabled = false;
            }
        }
        updated();
    }

    function sortRules() {
        let rules = [];
        let sorted = [];

        for (let i = 0; i < model.count; i++) {
            const item = model.get(i);
            rules.push({
                "description": item.description,
                "match": item.match,
                "icon": item.icon,
                "enabled": item.enabled
            });
        }

        sorted = rules.sort((a, b) => {
            const dA = a.description.toLocaleLowerCase();
            const dB = b.description.toLocaleLowerCase();
            if (dA < dB) {
                return -1;
            }
            if (dA > dB) {
                return 1;
            }
            return 0;
        });

        model.clear();
        for (const rule of sorted) {
            model.append(rule);
        }
        updated();
    }
}

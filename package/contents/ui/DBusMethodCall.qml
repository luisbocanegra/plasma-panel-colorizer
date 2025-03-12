import QtQuick

Item {
    id: root

    property string busType
    property string service: ""
    property string objectPath: ""
    property string iface: ""
    property string method: ""
    property var arguments: []
    property var signature: null
    property var inSignature: null
    property bool useGdbus: false

    function call(callback) {
        if (dbusLoader.item && typeof dbusLoader.item.call === "function")
            dbusLoader.item.call(callback);
        else
            console.error("No valid DBus implementation loaded.");
    }

    onArgumentsChanged: {
        if (dbusLoader.status === Loader.Ready)
            dbusLoader.item.arguments = root.arguments;
    }

    Loader {
        id: dbusLoader

        source: root.useGdbus ? "DBusFallback.qml" : "DBusPrimary.qml"
        onStatusChanged: {
            if (status === Loader.Error)
                dbusLoader.source = "DBusFallback.qml";
        }
        onLoaded: {
            dbusLoader.item.service = root.service;
            dbusLoader.item.objectPath = root.objectPath;
            dbusLoader.item.iface = root.iface;
            dbusLoader.item.method = root.method;
            dbusLoader.item.arguments = root.arguments;
            dbusLoader.item.signature = root.signature;
            dbusLoader.item.inSignature = root.inSignature;
        }
    }
}

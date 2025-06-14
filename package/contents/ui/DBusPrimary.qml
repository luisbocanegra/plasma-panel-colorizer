pragma ComponentBehavior: Bound
pragma ValueTypeBehavior: Addressable

import QtQuick
import org.kde.plasma.workspace.dbus as DBus

QtObject {
    id: root
    property string busType: DBus.BusType.Session
    property string service: ""
    property string objectPath: ""
    property string iface: ""
    property string method: ""
    property var arguments: []
    property var signature: null
    property var inSignature: null

    property DBus.dbusMessage msg: {
        "service": root.service,
        "path": root.objectPath,
        "iface": root.iface,
        "member": root.method,
        "arguments": root.arguments,
        "signature": root.signature,
        "inSignature": root.inSignature
    }

    function call(callback) {
        const reply = DBus.SessionBus.asyncCall(root.msg) as DBus.DBusPendingReply;
        if (callback) {
            reply.finished.connect(() => {
                // some values are nested, idk why but make it match DBusFallback version
                if (reply?.value?.value ?? null) {
                    const replyFlatValue = JSON.parse(JSON.stringify(reply));
                    replyFlatValue.value = replyFlatValue.value.value;
                    callback(replyFlatValue);
                } else {
                    callback(reply);
                }
                // Make sure to destroy after the reply is finished otherwise it may get leaked because the connected signal
                // holds a reference and prevents garbage collection.
                // https://discuss.kde.org/t/high-memory-usage-from-plasmashell-is-it-a-memory-leak/29105
                reply.destroy();
            });
        }
    }
}

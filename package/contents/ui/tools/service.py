#!/usr/bin/env python
"""
D-Bus service to interact with the panel
"""
import sys
import dbus
import dbus.service
from dbus.mainloop.glib import DBusGMainLoop
from gi.repository import GLib

DBusGMainLoop(set_as_default=True)

CONTAINMENT_ID = sys.argv[1]
PANEL_ID = sys.argv[2]
SERVICE_NAME = "luisbocanegra.panel.colorizer.c" + CONTAINMENT_ID + ".w" + PANEL_ID
SHARED_INTERFACE = "luisbocanegra.panel.colorizer.all"
PATH = "/preset"


class Service(dbus.service.Object):
    """D-Bus service

    Args:
        dbus (dbus.service.Object): D-Bus object
    """

    def __init__(self, bus: dbus.Bus):
        self._loop = GLib.MainLoop()
        self._last_preset = ""
        self._property = ""
        self._bus = bus
        super().__init__()

    def run(self):
        """run"""
        DBusGMainLoop(set_as_default=True)
        self._bus.add_signal_receiver(
            self.on_shared_preset_signal,
            dbus_interface=SHARED_INTERFACE,
            signal_name="preset",
        )
        self._bus.add_signal_receiver(
            self.on_shared_property_signal,
            dbus_interface=SHARED_INTERFACE,
            signal_name="property",
        )
        bus_name = dbus.service.BusName(SERVICE_NAME, dbus.SessionBus())
        dbus.service.Object.__init__(self, bus_name, PATH)

        print("Service running...")
        self._loop.run()
        print("Service stopped")

    @dbus.service.method(SERVICE_NAME, in_signature="s", out_signature="s")
    def preset(self, m="") -> str:
        """Set and get the last applied preset

        Args:
            m (str, optional): Preset. Defaults to "".

        Returns:
            str: "saved" or current Preset
        """
        if m:
            if m != self._last_preset:
                self._last_preset = m
                self.preset_changed(m)
            return "saved"
        return self._last_preset

    @dbus.service.method(SERVICE_NAME, in_signature="s", out_signature="s")
    def property(self, m=""):
        """Set a specific property using dot notation
        e.g `'stockPanelSettings.visible {"enabled": true, "value": false}'`
        """
        if m:
            if m != self._property:
                self._property = m
                self.property_changed(m)
            return "saved"
        return self._property

    def on_shared_preset_signal(self, preset_name: str):
        """Handle the shared signal to set the preset

        Args:
            preset_name (str): The preset name from the signal
        """
        self.preset(preset_name)

    def on_shared_property_signal(self, edited_property: str):
        """Handle the shared signal to set the preset

        Args:
            edited_property (str): The property from the signal
        """
        self.property(edited_property)

    @dbus.service.method(SERVICE_NAME, in_signature="", out_signature="")
    def quit(self):
        """Stop the service"""
        print("Shutting down")
        self._loop.quit()

    @dbus.service.signal(SERVICE_NAME, signature="s")
    def preset_changed(self, preset: str):
        """To inform the widget of new preset

        Args:
            preset (str): Preset name
        """

    @dbus.service.signal(SERVICE_NAME, signature="s")
    def property_changed(self, property: str):
        """To inform the widget of new property

        Args:
            property (str): Property string
        """


if __name__ == "__main__":
    # Keep a single instance of the service
    session_bus = dbus.SessionBus()
    try:
        session_bus.get_object(SERVICE_NAME, PATH)
        print("Service is already running")
    except dbus.exceptions.DBusException:
        Service(session_bus).run()

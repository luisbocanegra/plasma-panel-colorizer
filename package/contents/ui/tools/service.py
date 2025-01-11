#!/usr/bin/env python
"""
D-Bus service to interact with the current panel
"""

import sys
import dbus
import dbus.service
from dbus.mainloop.glib import DBusGMainLoop
from gi.repository import GLib

DBusGMainLoop(set_as_default=True)
bus = dbus.SessionBus()

CONTAINMENT_ID = sys.argv[1]
PANEL_ID = sys.argv[2]
SERVICE_NAME = "luisbocanegra.panel.colorizer.c" + CONTAINMENT_ID + ".w" + PANEL_ID
PATH = "/preset"


class Service(dbus.service.Object):
    """D-Bus service

    Args:
        dbus (dbus.service.Object): D-Bus object
    """

    def __init__(self):
        self._loop = GLib.MainLoop()
        self._last_preset = ""
        self._pending_witch = False
        super().__init__()

    def run(self):
        """run"""
        DBusGMainLoop(set_as_default=True)
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
                print(f"last_last_preset: '{m}'")
                self._last_preset = m
                self._pending_witch = True
            return "saved"
        return self._last_preset

    @dbus.service.method(SERVICE_NAME, in_signature="", out_signature="b")
    def pending_switch(self) -> bool:
        """Wether there is a pending preset switch

        Returns:
            bool: Pending
        """
        return self._pending_witch

    @dbus.service.method(SERVICE_NAME, in_signature="", out_signature="")
    def switch_done(self):
        """Void the pending switch"""
        self._pending_witch = False

    @dbus.service.method(SERVICE_NAME, in_signature="", out_signature="")
    def quit(self):
        """Stop the service"""
        print("Shutting down")
        self._loop.quit()


if __name__ == "__main__":
    # Keep a single instance of the service
    try:
        bus.get_object(SERVICE_NAME, PATH)
        print("Service is already running")
    except dbus.exceptions.DBusException:
        Service().run()

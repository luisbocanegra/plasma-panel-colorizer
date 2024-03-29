# Changelog

## v0.4.0 Preset management & auto-loading

### New features

- Margins control to unify heights & extra margins for widgets
- Contrast correction for all color modes
- New widget background line mode
- Include tray widgets in force icon color
- Preset management
- Support for app tray icon colorization
- Preset auto-loading on floating panel / Maximized window
- System color option for custom color modes
- Spacing control
- Widget background margin

### Bug fixes

- Allow blacklisting the System Tray widget
- Fix unreadable BadgeOverlay
- Fix colors not updating for window buttons widget
- Fix color animation not working sometimes
- Don't rotate colors in static mode

### Other

- Only reload window buttons widget when fg colors change
- Use list of current widgets for blacklist/force/margins
- Show last preset loaded

## v0.3.0 Tons of new features

### New features

- Foreground (text & icons) customization
- Apply fg color to Window Buttons widget
- option to use a fixed custom panel side padding
- Custom panel background color
- Control real panel background opacity
- Option to fully remove panel background
- Add outline and shadow control
- Force Kirigami.Icon color to specific plasmoids using isMask

### Bug fixes

- Listen for widgets added/removed from the panel
- Don't change fg color in tray expanded representation
- Reduce CPU usage only changing fg color for PlasmoidItem children
- Fix notification applet appearing artifact
- Don't change opacity when disabled
- Continue after error caused by panel being edited

### Other

- Split configuration sections into tabs
- Use color picker for color fields
- Add mouse wheel area to floating text fields

## v0.2.0 Hide widget

- Added option to show the widget only when panel is in panel editing mode.
- System tray position was removed since it wasn't working.

## v0.1.0 First public release (beta)

First usable release all features should work but expect some bugs here and there.

Plasma 6 only but may be ported to plasma 5 if there's interest (PRs welcome)

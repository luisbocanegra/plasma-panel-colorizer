# Changelog

## v0.5.2 Bugfix release (mostly)

### Bug fixes

- Fix transparent outline ugliness by drawing it inside background area
- Restore now removes all customization https://github.com/luisbocanegra/plasma-panel-colorizer/issues/36
- Fix panel background color set not saving https://github.com/luisbocanegra/plasma-panel-colorizer/issues/42
- Fix broken system colors when switching color schemes https://github.com/luisbocanegra/plasma-panel-colorizer/issues/41
- Fix blacklisted color
- Fix default appearance restore
- Ignore global enable from presets
- Fix restoring hidden panel after global disable
- Fix blacklisted color
- Remove outline if background is disabled
- Disable/hide controls based on category/global disabled status
- Disable blacklist on global disable
- Fix per widget margins layout & visibility

### Improvements

- Improve preset auto-loading - Allow loading a preset when a window is touching the panel https://github.com/luisbocanegra/plasma-panel-colorizer/issues/44
- Split margin from background and move to separate Layout tab
- **Don't apply any customization by default** https://github.com/luisbocanegra/plasma-panel-colorizer/issues/36

### Other

- Switch to RGBA for background opacity

## v0.5.1 Bugfix release

### Bug fixes

- Added button to restore default block/margin/force recolor rules to fix rules not being deleted even after removing the matched widgets.

    **Only required if you updated or have presets from version 0.4.0 or older**

    Instructions to fix all broken presets have been provided [here](https://github.com/luisbocanegra/plasma-panel-colorizer?tab=readme-ov-file#fix-blacklistmarginforce-recolor-not-working-after-updating-to-version-050)

- Fixed missing color options for panel background

### Other

- Added click support to increase/decrease value in floating text fields

## v0.5.0 Text/icons shadow

### New features

- Configurable icons/text shadow
- Added option to fix custom badges text
- Allow picking any System (Kirigami.Theme) color

### Bug fixes

- Fixed contrast correction for some color modes
- Fixed original panel opacity requiring custom background to work
- Don't remove widget rules when they are not in the panel being configured

### Other

- Only show a single instance of each widget when configuring
- Now available in AUR [plasma6-applets-panel-colorizer](https://aur.archlinux.org/packages/plasma6-applets-panel-colorizer)

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

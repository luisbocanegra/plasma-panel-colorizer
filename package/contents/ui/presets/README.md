# Presets

| Preset Name | Preview |
|-------------|---------|
| Black | ![Black](Black/preview.png) |
| Black Color Lines | ![Black Color Lines](Black%20Color%20Lines/preview.png) |
| Black Gray Lines | ![Black Gray Lines](Black%20Gray%20Lines/preview.png) |
| Bliss | ![Bliss](Bliss/preview.png) |
| Bliss Light | ![Bliss Light](Bliss%20Light/preview.png) |
| Blur Widgets | ![Blur Widgets](Blur%20Widgets/preview.png) |
| Blur Widgets 2 | ![Blur Widgets 2](Blur%20Widgets%202/preview.png) |
| Carbon | ![Carbon](Carbon/preview.png) |
| ChromeOS | ![ChromeOS](ChromeOS/preview.png) |
| Default | ![Default](Default/preview.png) |
| Dock | ![Dock](Dock/preview.png) |
| Eclipse | ![Eclipse](Eclipse/preview.png) |
| Fake Floating | ![Fake Floating](Fake%20Floating/preview.png) |
| Fusion | ![Fusion](Fusion/preview.png) |
| Fusion 2 | ![Fusion 2](Fusion%202/preview.png) |
| Fusion 3 | ![Fusion 3](Fusion%203/preview.png) |
| Neon Lights | ![Neon Lights](Neon%20Lights/preview.png) |
| OG | ![OG](OG/preview.png) |
| Orbit | ![Orbit](Orbit/preview.png) |
| Outline | ![Outline](Outline/preview.png) |
| Outline Accent | ![Outline Accent](Outline%20Accent/preview.png) |
| Outline Colors | ![Outline Colors](Outline%20Colors/preview.png) |
| Pulse | ![Pulse](Pulse/preview.png) |
| Rounded Widgets | ![Rounded Widgets](Rounded%20Widgets/preview.png) |
| Rounded Widgets Floating | ![Rounded Widgets Floating](Rounded%20Widgets%20Floating/preview.png) |
| Rubik | ![Rubik](Rubik/preview.png) |
| Skeuomorphic 2 | ![Skeuomorphic 2](Skeuomorphic%202/preview.png) |
| Skeuomorphic white | ![Skeuomorphic white](Skeuomorphic%20white/preview.png) |
| Skittles | ![Skittles](Skittles/preview.png) |
| Sky | ![Sky](Sky/preview.png) |
| Sleek | ![Sleek](Sleek/preview.png) |
| Solid | ![Solid](Solid/preview.png) |
| Translucent | ![Translucent](Translucent/preview.png) |
| Transparent | ![Transparent](Transparent/preview.png) |
| White | ![White](White/preview.png) |

## Adding or updating built-in presets

Presets go inside `package/contents/ui/presets/`

Preset folder structure:

```sh
PresetName/
├── settings.json
└── preview.png
```

Preset `settings.json` must be edited only from the widget settings, to update an existing preset you need to make a copy of it first. The preview should match the style you get after applying it (except for the widgets that are in the panel of course).

When your preset is ready, copy the `settings.json` and `preview.png` to preset directory from `~/.config/panel-colorizer/presets/PresetName` to `package/contents/ui/presets/PresetName`.

After adding or renaming a preset run `./gen-presets-list-doc.sh` from the project root directory, this will update `package/contents/ui/presets/README.md` with the new preset(s).

***This file was auto-generated using `./gen-presets-list-doc.sh`***

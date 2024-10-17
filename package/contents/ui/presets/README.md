# Adding or updating built-in presets

Presets go inside `package/contents/ui/presets/`

Preset folder structure:

```sh
PresetName/
├── settings.json
└── preview.png
```

Preset `settings.json` must be edited only from the widget settings, to update an existing preset you need to make a copy of it first.

After you made your changes copy the `settings.json` and `preview.png` to preset directory in `package/contents/ui/presets/PresetName`.

Presets must have a descriptive name, and the preview should match the style you get after applying it, (except for the widgets that are in the panel of course)

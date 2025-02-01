#!/bin/env bash

# This script generates a list of all presets in the presets directory
# and writes it to the file package/contents/ui/presets/README.md

if [ ! -d "package" ]; then
  echo "Please run this script from the root of the repository"
  exit 1
fi

PRESETS_DIR="package/contents/ui/presets"
PRESETS_README="$PRESETS_DIR/README.md"

echo -e "# Presets\n" >"$PRESETS_README"

echo "| Preset Name | Preview |" >>"$PRESETS_README"
echo "|-------------|---------|" >>"$PRESETS_README"

find "$PRESETS_DIR" -mindepth 1 -prune -type d -print0 | sort -z | while IFS= read -r -d '' preset; do
  name=$(basename "$preset")
  echo "| $name | ![$name](${name// /%20}/preview.png) |" >>"$PRESETS_README"
done

cat <<EOF >>"$PRESETS_README"

## Adding or updating built-in presets

Presets go inside \`package/contents/ui/presets/\`

Preset folder structure:

\`\`\`sh
PresetName/
├── settings.json
└── preview.png
\`\`\`

Preset \`settings.json\` must be edited only from the widget settings, to update an existing preset you need to make a copy of it first. The preview should match the style you get after applying it (except for the widgets that are in the panel of course).

When your preset is ready, copy the \`settings.json\` and \`preview.png\` to preset directory from \`~/.config/panel-colorizer/presets/PresetName\` to \`$PRESETS_DIR/PresetName\`.

After adding or renaming a preset run \`./gen-preset-previews-doc.sh\` from the project root directory, this will update \`$PRESETS_README\` with the new preset(s).

***This file was generated using \`./gen-preset-previews-doc.sh\`***
EOF

echo "Done! Check $PRESETS_README"

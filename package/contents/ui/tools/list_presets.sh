#!/usr/bin/env bash

PRESETS_DIR="$1"
BUILTIN="$2"

find "$PRESETS_DIR" -mindepth 1 -prune -type d -print0 | while IFS= read -r -d '' preset; do
  has_preview=0
  if [[ -f "$preset/preview.png" ]]; then
    has_preview=1
  fi
  if [[ -n $BUILTIN ]]; then
    echo "$preset:$has_preview:b"
  else
    echo "$preset:$has_preview:u"
  fi
done | sort

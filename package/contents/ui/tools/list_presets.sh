#!/usr/bin/env bash

PRESETS_DIR="$1"
BUILTIN="$2"

find "$PRESETS_DIR" -mindepth 1 -prune -type d -print0 | while IFS= read -r -d '' preset; do
  if [[ -n $BUILTIN ]]; then
    echo "b:$preset"
  else
    echo "u:$preset"
  fi
done | sort

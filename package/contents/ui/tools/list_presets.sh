#!/usr/bin/env bash

PRESETS_DIR="$1"

find "$PRESETS_DIR" -mindepth 1 -prune -type d -print0 | while IFS= read -r -d '' preset; do echo b:"$preset"; done | sort

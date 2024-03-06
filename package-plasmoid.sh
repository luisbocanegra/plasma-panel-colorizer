#!/bin/sh

if [ -d "build" ]; then
    rm -rf build
fi

# package plasmoid, skip installing
cmake -B build -S . -DINSTALL_PLASMOID=OFF -DPACKAGE_PLASMOID=ON
cmake --build build
